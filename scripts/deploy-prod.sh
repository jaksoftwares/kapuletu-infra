#!/bin/bash
# Deployment script for the Kapuletu Production infrastructure.
# WARNING: This script will modify live production resources. Use with caution.

set -e

ENV="prod"
echo "Deploying Kapuletu Infrastructure to $ENV..."

cd "$(dirname "$0")/../environments/$ENV"

terraform init
terraform plan -out=tfplan
terraform apply tfplan
rm tfplan

echo "Deployment to $ENV complete."
