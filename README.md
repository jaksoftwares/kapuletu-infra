# Kapuletu Infrastructure Repository

Welcome to the **Kapuletu Enterprise Infrastructure** repository. This codebase is designed by Senior DevOps Engineers to provide a production-grade, highly available, and secure AWS environment for a serverless fintech application.

## 🌟 Key Features

*   **Multi-Environment Isolation**: Separate AWS accounts for `dev`, `staging`, and `prod`.
*   **Modular Architecture**: Reusable, parameterized Terraform modules for networking, databases, IAM, and more.
*   **Zero-Trust Networking**: Public/Private subnet isolation with strictly defined security groups.
*   **High Availability**: Multi-AZ RDS deployments for production.
*   **Automated CI/CD**: OIDC-based GitHub Actions pipelines for seamless deployments without static credentials.
*   **Financial Integrity**: QLDB integration for immutable transaction logging.

---

## 🏗 Repository Structure

```text
kapuletu-infra/
├── .github/workflows/      # OIDC-based CI/CD pipelines
├── environments/           # Environment entry points (Dev, Staging, Prod)
│   ├── dev/                # Remote state + Dev parameters
│   ├── staging/            # Remote state + Staging parameters
│   └── prod/               # Remote state + Prod parameters (High Availability)
├── modules/                # Reusable Infrastructure Components
│   ├── networking/         # VPC, Subnets, NAT/IGW
│   ├── rds/                # PostgreSQL (Multi-AZ in Prod)
│   ├── iam/                # Scoped Roles & OIDC Providers
│   ├── api_gateway/        # REST API with Cognito JWT Auth
│   ├── cognito/            # Identity & Access Management
│   ├── lambda/             # Serverless Business Logic
│   ├── qldb/               # Immutable Transaction Ledger
│   ├── s3/                 # Versioned Document Storage
│   ├── secrets_manager/    # Automated Secret Management
│   └── monitoring/         # CloudWatch Alarms & Log Groups
├── scripts/                # Local deployment automation
└── ARCHITECTURE.md         # Detailed technical deep-dive
```

---

## 🚀 Getting Started

### 1. Prerequisites
*   Terraform `>= 1.0.0`
*   AWS CLI configured with appropriate credentials
*   The following S3 Buckets created for remote state:
    *   `kapuletu-terraform-state-dev`
    *   `kapuletu-terraform-state-staging`
    *   `kapuletu-terraform-state-prod`

### 2. Manual Deployment (Local)
To deploy the development environment manually:
```bash
# Navigate to dev
cd environments/dev

# Initialize backend and modules
terraform init

# Review changes
terraform plan

# Apply changes
terraform apply
```

Alternatively, use our helper scripts:
```bash
chmod +x scripts/*.sh
./scripts/deploy-dev.sh
```

### 3. CI/CD Deployment
This repository is configured to deploy automatically via GitHub Actions:
*   **Develop**: Push to `develop` branch.
*   **Staging**: Push to `staging` branch.
*   **Production**: Push to `main` branch.

---

## 🔐 Security & Compliance
*   **OIDC Authentication**: We do not store `AWS_ACCESS_KEY_ID`. GitHub Actions authenticates via AWS IAM Identity Providers.
*   **Secret Management**: DB passwords and API keys are stored in AWS Secrets Manager, never in plain text.
*   **Encryption**: All S3 buckets and RDS instances have encryption at rest enabled.
*   **Auditability**: QLDB provides a cryptographically verifiable history of all transactions.

---

## 📈 Monitoring & Observability
Every environment is pre-configured with:
*   **CloudWatch Log Groups**: For centralized logging of Lambda and API Gateway.
*   **Automated Alarms**:
    *   Lambda execution errors.
    *   API Gateway 5xx response rates.
    *   RDS CPU Utilization thresholds.

---
© 2024 Kapuletu Enterprise | Designed for Excellence.
