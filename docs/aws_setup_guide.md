# AWS Infrastructure Setup & Credentials Guide

This document provides a comprehensive guide for the manual setup required in AWS before Terraform can take over, as well as the credentials, variables, and configurations required to deploy the Kapuletu fintech ecosystem.

## 1. AWS Account Strategy
For a secure, enterprise-grade deployment, we strongly recommend a **Multi-Account Strategy** managed via AWS Organizations:
- **Management Account**: Used for consolidated billing and SCP (Service Control Policies).
- **Dev Account**: Used for active development and continuous integration.
- **Staging Account**: A clone of production for QA and final testing.
- **Prod Account**: Hosts live user data and production workloads with strict access controls.

## 2. Pre-Requisite: Bootstrapping the Terraform Backend

Before running `terraform init` in any environment, you must manually create the resources that will hold the Terraform state. This is to prevent a chicken-and-egg problem where Terraform tries to create the bucket it needs to store its own state.

### Required Resources per Account (Dev, Staging, Prod):
1. **S3 Bucket (State Storage):**
   - **Name**: `kapuletu-terraform-state-[env]-[region]-[random-id]` (must be globally unique)
   - **Versioning**: Enabled (Critical for state recovery)
   - **Encryption**: Enabled (SSE-S3 or KMS)
   - **Public Access**: Block All Public Access

2. **DynamoDB Table (State Locking):**
   - **Table Name**: `kapuletu-terraform-locks-[env]`
   - **Partition Key**: `LockID` (String)

*Note: Update `global/backend.tf` or the backend configuration block in each environment to reference these created resources.*

## 3. GitHub Actions CI/CD Setup (OIDC)

The Kapuletu infrastructure uses **OpenID Connect (OIDC)** to securely authenticate GitHub Actions with AWS, eliminating the need to store long-lived AWS Access Keys as GitHub Secrets.

### Steps to configure OIDC in AWS:
1. Go to AWS IAM -> Identity Providers -> Add Provider.
2. Select **OpenID Connect**.
3. **Provider URL**: `https://token.actions.githubusercontent.com`
4. **Audience**: `sts.amazonaws.com`
5. Click **Add Provider**.
6. Create an **IAM Role** (e.g., `kapuletu-[env]-github-actions-role`) and assign the newly created OIDC provider as a trusted entity.
7. Attach the necessary permissions to this role. The role needs enough permissions to provision VPCs, RDS, Lambda, API Gateway, etc. (often `AdministratorAccess` scoped to the account for CI/CD, or a strictly bounded custom policy).
8. **Trust Relationship Policy Example**:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
           },
           "StringLike": {
             "token.actions.githubusercontent.com:sub": "repo:<YOUR_GITHUB_ORG>/kapuletu-infra:ref:refs/heads/<BRANCH_NAME>"
           }
         }
       }
     ]
   }
   ```

## 4. Required Credentials & GitHub Secrets

Once OIDC is configured, you must set the following variables in your GitHub Repository so that GitHub Actions can securely access them.

### GitHub Repository Variables (Global)
**Where to set this:** In your GitHub Repository, go to `Settings` -> `Secrets and variables` -> `Actions` -> `Variables` tab.
- `AWS_REGION`: The default AWS region (e.g., `us-east-1`). **Where to get this:** Decide based on your AWS infrastructure location (e.g., N. Virginia is `us-east-1`).

### GitHub Repository Environments
**Where to set this:** In your GitHub Repository, go to `Settings` -> `Environments`. Create three environments (`dev`, `staging`, `prod`). Click on each environment and add the following under `Environment variables` (or `Environment secrets` if you prefer).
- `AWS_OIDC_ROLE_ARN`: The ARN of the IAM role created in Step 3 (e.g., `arn:aws:iam::123456789012:role/kapuletu-dev-github-actions-role`).
  **Where to get this:** In the AWS Console, navigate to `IAM` -> `Roles` -> Select the Role you created in Step 3 -> Copy the `ARN` value at the top of the Summary page.

## 5. Required Terraform Variables (`terraform.tfvars`)

For each environment in the repository (`environments/dev/`, `environments/staging/`, `environments/prod/`), you must create a `terraform.tfvars` file locally on your machine. **Never commit `terraform.tfvars` to version control.**

**Where to get these values:** 
- Most of these values (like `vpc_cidr` or `db_instance_class`) come from your infrastructure planning or architectural design documents.
- If you are setting up the environment for the first time, coordinate with the DevOps Lead to establish the correct CIDR blocks and instance sizes.

### Example `environments/dev/terraform.tfvars` (Local File):

```hcl
# Core Setup
aws_region  = "us-east-1"
environment = "dev"

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# Database (RDS)
db_instance_class    = "db.t3.micro"
db_name              = "kapuletu_dev"
# Note: db_password should NOT be here. It should be generated by Terraform and stored in AWS Secrets Manager, or passed via an environment variable `TF_VAR_db_password` in CI/CD.

# Cognito
user_pool_name = "kapuletu-users-dev"

# QLDB
qldb_ledger_name = "kapuletu-ledger-dev"
```

## 6. AWS Secrets Manager Setup

Sensitive data such as database master passwords, third-party API keys (e.g., Twilio, Postmark), and webhook secrets must be managed securely.

**Where to configure this in AWS:**
Log into the AWS Console -> Navigate to `Secrets Manager` -> Click `Store a new secret` -> Select `Other type of secret` -> Enter key-value pairs or plain text.

1. **Database Passwords**: Can be randomly generated by Terraform's `random_password` resource and stored directly into AWS Secrets Manager. No manual intervention needed.
2. **Third-Party API Keys**: Must be manually added to AWS Secrets Manager in the respective account before deploying the backend application.
   - Example Secret Name: `/kapuletu/dev/twilio_api_key`
     **Where to get this:** Log into the [Twilio Console](https://console.twilio.com/) -> Scroll down to `Account Info` -> Copy the `Auth Token` (and optionally `Account SID`).
   - Example Secret Name: `/kapuletu/dev/postmark_api_key`
     **Where to get this:** Log into the [Postmark Console](https://account.postmarkapp.com/) -> Go to `Servers` -> Select your Server -> Go to `API Tokens` tab -> Copy the token.
   The Lambda functions and ECS tasks will dynamically fetch these secrets at runtime using their execution roles.

## 7. Domain & SSL/TLS Setup (Route53 & ACM)

1. **Domain Registration**: Register your domain (e.g., `kapuletu.com`) in Route53 in the Management/Prod account.
2. **Hosted Zones**: Create sub-zone delegations for Dev and Staging (`dev.kapuletu.com`, `staging.kapuletu.com`).
3. **SSL Certificates**: Request SSL certificates in **AWS Certificate Manager (ACM)** for the domains.
   - Remember to request certificates in `us-east-1` if using CloudFront or regional API Gateways depending on the architecture.
   - Terraform can automate DNS validation if the Hosted Zone exists in the same AWS account.

## Summary Checklist Before Running Terraform:
- [ ] AWS Accounts Provisioned.
- [ ] S3 State Bucket & DynamoDB Lock Table created.
- [ ] `backend.tf` updated with correct bucket/table names.
- [ ] GitHub Actions OIDC configured in IAM.
- [ ] GitHub Repository Variables/Secrets populated.
- [ ] Domain Hosted Zones created.
- [ ] `terraform.tfvars` populated locally for each environment.
