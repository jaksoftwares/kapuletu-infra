# Kapuletu Enterprise Infrastructure (DevOps Review & Documentation)

This repository serves as the backbone for the Kapuletu fintech ecosystem. It provides a highly secure, scalable, and automated AWS environment using Terraform.

## 🏗 System Architecture Overview

The infrastructure is designed using a **Multi-Account/Multi-Environment Strategy**. This ensures that development work never impacts production and allows for strict security boundaries.

### 1. Networking (The Foundation)
*   **VPC Isolation**: Each environment resides in its own VPC.
*   **Subnet Strategy**: 
    *   **Public Subnets**: For API Gateways and NAT Gateways.
    *   **Private Subnets**: For Lambda functions and RDS instances (Zero direct internet exposure).
*   **Security Groups**: Implements a "Zero Trust" model where only necessary traffic is allowed between components.

### 2. Data & Persistence
*   **RDS (PostgreSQL)**: 
    *   `Dev/Staging`: Single instance for cost-efficiency.
    *   `Prod`: Multi-AZ deployment for high availability and failover support.
*   **QLDB (Immutable Ledger)**: Provides a cryptographically verifiable transaction log, essential for fintech auditability.
*   **S3**: Versioned buckets for document storage and reporting.

### 3. Serverless Backend
*   **Lambda**: Orchestrates the business logic. Functions are VPC-joined for secure database access.
*   **API Gateway**: RESTful endpoints with built-in Cognito authorization.
*   **Cognito**: Manages user identity, authentication, and JWT-based session security.

---

## 📂 Codebase Structure & Functionality

### `/global`
Contains the Terraform bootstrap configuration. It defines where the "source of truth" (state) lives.
*   `backend.tf`: Configures S3 + DynamoDB locking.
*   `versions.tf`: Locks the Terraform engine and AWS provider versions to prevent breaking changes.

### `/environments`
The entry point for deployments. Each folder (`dev`, `staging`, `prod`) contains:
*   `main.tf`: The orchestrator that instantiates modules with environment-specific parameters.
*   `terraform.tfvars`: The actual configuration values (e.g., instance sizes, CIDR blocks).

### `/modules`
Highly parameterized, reusable infrastructure code. These are "lego blocks" that can be updated once and reflected across all environments.

---

## 🔁 CI/CD Workflow (GitHub Actions)

We use **OIDC (OpenID Connect)** for authentication, eliminating the need for long-lived AWS Access Keys.

1.  **Develop Branch**: Triggers `terraform-dev.yml`. Performs `plan` and `apply` to the Dev environment.
2.  **Staging Branch**: Triggers `terraform-staging.yml`. Deploys to the Staging account for QA.
3.  **Main Branch**: Triggers `terraform-prod.yml`. Requires manual approval/review before `terraform apply` hits production.

---

## 🛠 Operational Manual

### Initializing a New Environment
1.  Navigate to the environment folder: `cd environments/dev`
2.  Initialize: `terraform init`
3.  Deploy: `terraform apply`

### Security Best Practices
*   **Never commit `.tfstate` files**: Managed automatically via S3.
*   **Never hardcode secrets**: Use the `secrets_manager` module and reference the ARNs in your code.
*   **Least Privilege**: All IAM roles are scoped to the minimum permissions required for the resource to function.
