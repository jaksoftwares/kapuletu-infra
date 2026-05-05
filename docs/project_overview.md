# Kapuletu Infrastructure: Project Overview

## What is this Codebase About?

This repository (`kapuletu-infra`) is the **Infrastructure as Code (IaC)** blueprint for the entire Kapuletu fintech ecosystem. 

Instead of manually logging into the AWS Console and clicking buttons to create servers, databases, and networks (which is error-prone and hard to track), we define our entire cloud architecture using **Terraform**. This codebase serves as the single source of truth for how the Kapuletu platform is hosted and secured in the cloud.

When code from this repository is deployed, it communicates with AWS to automatically build, modify, or tear down the cloud resources exactly as they are defined in the files.

## What Does it Actually Do?

This codebase provisions and connects all the foundational pieces required to run the Kapuletu backend API and services. Specifically, it automates the creation of:

### 1. The Network (The Foundation)
It builds a secure, private network (Virtual Private Cloud or VPC) in AWS. It creates:
- **Public Subnets**: Where traffic from the internet enters (e.g., API Gateways).
- **Private Subnets**: Highly secure areas disconnected from the public internet where our sensitive databases and core application logic reside.

### 2. Data & Storage (The Memory)
It spins up the storage engines required by Kapuletu:
- **Amazon RDS (PostgreSQL)**: The primary relational database used for storing user profiles, business logic states, and standard application data.
- **Amazon QLDB (Quantum Ledger Database)**: A specialized, cryptographically immutable ledger. This is used specifically for tracking financial transactions, ensuring that once a transaction is recorded, it can never be secretly altered or deleted.
- **Amazon S3**: Secure file storage used for saving documents, receipts, and Terraform's own configuration state.

### 3. Compute & APIs (The Brain)
It provisions the serverless environment where Kapuletu's backend code runs:
- **API Gateway**: Acts as the "front door" for the mobile/web apps to communicate with the backend.
- **AWS Lambda**: Serverless compute instances that execute the Kapuletu backend code. We use Lambda so we don't have to manage or pay for idle servers; they scale up instantly when a request comes in and spin down when finished.

### 4. Security & Identity (The Bouncers)
It enforces strict security measures across the platform:
- **Amazon Cognito**: Handles user authentication, sign-ups, logins, and issues secure tokens (JWTs) so users can access the APIs.
- **AWS IAM (Identity and Access Management)**: Enforces "Least Privilege". This codebase creates specific roles (e.g., ensuring a Lambda function can read from RDS but cannot delete an S3 bucket).
- **AWS Secrets Manager**: A secure vault for storing sensitive things like database passwords and third-party API keys (like Twilio or Postmark).

### 5. Multi-Environment Segregation
This codebase is designed to build the exact same architecture multiple times across different isolated environments:
- **Dev**: For developers to test their daily changes.
- **Staging**: A pre-production replica used for Quality Assurance (QA).
- **Prod**: The live environment containing real users and real money. 

By having this codebase, if we ever needed to spin up a completely new environment (e.g., a sandbox for a partner), we could do it in minutes simply by running this Terraform code, guaranteeing it is an exact replica of production.

## Summary

In short, if the Kapuletu backend application code (Node.js/Python/etc.) is the "engine" of the car, this `kapuletu-infra` codebase is the factory that builds the chassis, the wheels, the roads, and the security systems that allow the engine to run safely at scale.
