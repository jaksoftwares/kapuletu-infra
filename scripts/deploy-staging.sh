#!/bin/bash
# Deployment script for the Kapuletu Staging infrastructure.
# Used for QA and pre-production verification.

set -e

ENV="staging"
echo "Deploying Kapuletu Infrastructure to $ENV..."

cd "$(dirname "$0")/../environments/$ENV"

terraform init
terraform plan -out=tfplan
terraform apply tfplan
rm tfplan

echo "Deployment to $ENV complete."
