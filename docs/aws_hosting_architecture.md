# Kapuletu AWS Hosting Architecture & Flow

This document details the complete architectural design and flow for hosting the Kapuletu application entirely on AWS. It serves as the master blueprint for the infrastructure team to accurately map and implement these requirements using Terraform.

## 1. Architectural Overview & Philosophy

Kapuletu uses a **Serverless-First, Multi-Tiered Architecture** on AWS. This approach ensures high scalability (handling burst traffic from webhooks seamlessly), high availability, and strong security boundaries, while minimizing idle compute costs.

The backend functionality (including FastAPI endpoints, Twilio/WhatsApp webhook ingestion, and Postmark integrations) will be deployed as serverless functions behind a managed API gateway, securely communicating with private databases within a Virtual Private Cloud (VPC).

---

## 2. Comprehensive List of AWS Services

To support all endpoints and backend processes, the following AWS services will be provisioned via Terraform:

### Compute & API Layer
*   **Amazon API Gateway:** The unified "front door" for all incoming traffic. It handles request routing, rate limiting, and CORS. It exposes all Kapuletu REST endpoints (both for client apps and third-party webhooks).
*   **AWS Lambda:** The core serverless compute engine. It executes the Python/FastAPI backend logic. Functions will be split logically (e.g., webhook processing, user management, ledger queries).

### Database & Storage Layer
*   **Amazon RDS (PostgreSQL):** The primary relational database for standard application state (user profiles, settings, non-financial metadata). Deployed in private subnets with Multi-AZ in production.
*   **Amazon QLDB (Quantum Ledger Database):** The immutable, cryptographically verifiable ledger. Used exclusively as the source-of-truth for all financial transactions.
*   **Amazon S3 (Simple Storage Service):** Used for object storage, specifically for storing parsed receipts, generated reports, and Terraform's backend state.

### Security, Identity, & Networking
*   **Amazon VPC (Virtual Private Cloud):** The network boundary. Contains public subnets (for NAT Gateway) and private subnets (for Lambda and RDS).
*   **Amazon Cognito:** Manages user identity and access management. Issues JWT tokens that API Gateway uses to authorize user-facing endpoints.
*   **AWS Secrets Manager:** Securely stores database credentials, Twilio API tokens, Postmark API keys, and webhook signing secrets.
*   **AWS IAM (Identity and Access Management):** Enforces least privilege. Provides explicit Execution Roles for Lambda functions (e.g., allowing Lambda to write to RDS and read from Secrets Manager).

### Observability & CI/CD
*   **Amazon CloudWatch:** Collects logs from API Gateway and Lambda, monitors metrics, and triggers alarms on errors.
*   **AWS OIDC (OpenID Connect):** Allows GitHub Actions to securely deploy Terraform changes and Lambda code without long-lived access keys.

---

## 3. System Interconnections & Data Flow

To ensure accurate Terraform setup, the interconnections between these services must be strictly defined. Here are the core flows:

### Flow A: Client Application Request (Authenticated)
*Example: A user requests their transaction history.*
1.  **Client** authenticates via **Cognito** and receives a JWT token.
2.  **Client** makes an HTTP request with the token to the **API Gateway**.
3.  **API Gateway** natively validates the JWT token with **Cognito**.
4.  If valid, **API Gateway** proxies the request to the designated **Lambda** function.
5.  **Lambda** assumes its IAM Execution Role and queries the **VPC-bound RDS** (for profile data) and **QLDB** (for transaction history).
6.  **Lambda** returns the consolidated response through **API Gateway** to the **Client**.

### Flow B: Webhook Ingestion (Unauthenticated / Signature Validated)
*Example: Twilio/WhatsApp sends an incoming transaction SMS to the backend.*
1.  **Twilio** sends a POST request to the `/ingestion/webhook` endpoint on **API Gateway**.
2.  **API Gateway** routes the request directly to the Ingestion **Lambda** (no Cognito validation here).
3.  The **Lambda** function queries **Secrets Manager** to retrieve the Twilio Validation Secret to verify the request signature.
4.  Upon validation, **Lambda** parses the financial data.
5.  **Lambda** writes the core transaction to the immutable **QLDB** ledger and updates the associated metadata in **RDS**.
6.  **Lambda** triggers a request to **Postmark** (using the API key from Secrets Manager) to send a receipt email.
7.  **Lambda** responds to the Webhook with a 200 OK (and optionally TwiML for an SMS reply).

---

## 4. Terraform Implementation Mapping

To translate this architecture into the `kapuletu-infra` repository, the Terraform modules should be structured to handle the dependencies logically:

1.  **`networking` module:**
    *   Provisions the VPC, Internet Gateway, NAT Gateways, Public/Private Subnets, and Security Groups.
    *   *Output:* Subnet IDs and VPC ID.
2.  **`secrets_manager` module:**
    *   Provisions secret placeholders for DB passwords and API keys.
3.  **`rds` module:**
    *   Provisions the PostgreSQL instance in the Private Subnets.
    *   *Depends on:* `networking` (needs subnets) and `secrets_manager` (for master password).
4.  **`qldb` module:**
    *   Provisions the serverless Quantum Ledger.
5.  **`cognito` module:**
    *   Provisions User Pools and Identity Pools for client authentication.
    *   *Output:* User Pool ARNs (needed by API Gateway).
6.  **`lambda` module:**
    *   Provisions the serverless functions, attaching them to the VPC Private Subnets.
    *   *Depends on:* `networking` (VPC config), `rds`, `qldb` (needs access permissions via IAM).
7.  **`api_gateway` module:**
    *   Provisions the REST or HTTP API. Configures routes mapping to the Lambdas.
    *   Configures Cognito Authorizers for secure routes.
    *   *Depends on:* `lambda` and `cognito`.
8.  **`iam` module (Global/Implicit):**
    *   Creates specific roles for Lambda functions, ensuring they can write to CloudWatch, access the VPC (AWSLambdaVPCAccessExecutionRole), read from Secrets Manager, and access RDS/QLDB.

## 5. Next Steps for Infrastructure Setup
1.  **Finalize Endpoint Schema:** Ensure all FastAPI endpoints are mapped either to a single "Monolithic" Lambda (easier for FastAPI using Mangum) or split into micro-Lambdas.
2.  **Populate Variables:** Define the exact CIDR blocks for the VPC and instance sizes for RDS in `environments/*/terraform.tfvars`.
3.  **Module Development:** Begin writing the Terraform code in the `modules/` directory, following the dependency chain (Network -> DB -> IAM -> Compute -> API).
