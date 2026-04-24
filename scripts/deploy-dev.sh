#!/bin/bash
# Deployment script for the Kapuletu Development infrastructure.
# Ensures that Terraform is initialized and applied for the 'dev' environment.

set -e # Exit immediately if a command exits with a non-zero status.

ENV="dev"
echo "Deploying Kapuletu Infrastructure to $ENV..."

# Navigate to the environment-specific directory
cd "$(dirname "$0")/../environments/$ENV"

# Standard Terraform workflow
terraform init
terraform plan -out=tfplan
terraform apply tfplan
rm tfplan # Clean up the plan file after application

echo "Deployment to $ENV complete."
