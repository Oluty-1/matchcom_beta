# Matchcom_Beta

This is a serverless AWS application to calculate and manage compatibility scores between users, built with API Gateway, Lambda, SQS, DynamoDB, and deployed using Terraform. This project demonstrates a scalable, highly available architecture with robust observability.

## Overview

This application allows users to submit compatibility data (names, ages, score), retrieve, update, or delete results via a REST API. The backend processes requests asynchronously, stores data in DynamoDB, and ensures reliability with features like reserved concurrency, provisioned concurrency and dead-letter queues. Observability is provided through CloudWatch logs, metrics, alarms, and a dashboard.

### Here's an overview of what the architecture is like

![Matchcom](https://github.com/user-attachments/assets/929ba89a-272c-4323-b84f-a0315f7f20f3)



### And here's the frontend to interract with the application:
https://matchcom.netlify.app/ 

The flow of deployment is as follows
Zip


## Flow of Operation

Frontend: A web interface (in frontend/) sends HTTP requests to the API.

API Gateway: Handles REST endpoints (/compatibility, /compatibility/{id}) for POST, GET, PUT, DELETE, and OPTIONS.

### Components of Architecture
1 Lambda Functions:
  - CalculateCompatibilityFunction: Validates POST requests and sends data to SQS.
  - ProcessCompatibilityFunction: Writes SQS messages to DynamoDB.
  - GetCompatibilityFunction: Retrieves results from DynamoDB.
  - UpdateCompatibilityFunction: Updates existing results.
  - DeleteCompatibilityFunction: Deletes results.

2 SQS: CompatibilityQueue-prod with CompatibilityDLQ-prod for asynchronous processing and fault tolerance.
3 DynamoDB: CompatibilityResults-prod stores compatibility data.
4 CloudWatch: Logs structured JSON, extracts latency metrics, and provides a dashboard (CompatibilityLambdaDashboard-prod) with error and concurrency alarms.


### Reliability Strategy
- Provisioned concurrency (5) for low-latency Lambda execution.
- Reserved concurrency (10) to manage resource usage.
- Dead-letter queue for failed SQS messages.

### Observability Strategy:
- Structured logs with level, operation, status, and latency.
- CloudWatch metric filter for latency (Compatibility-Monitoring namespace).
- Alarms for error rates (>5%) and concurrency (>8 executions).
- Dashboard visualizing Lambda, SQS, and DynamoDB metrics.
- X-Ray tracing for request debugging.


### The Flow of Deployment is as Follows:
- Build
- Package & zip
- Upload to s3
- Creat Lambda and Point to s3



For local deployment

Run this script to package and upload the lambda functions to S3

chmod +x terraform/scripts/package_lambda.sh
./terraform/scripts/package_lambda.sh functions/calculateCompatibility
./terraform/scripts/package_lambda.sh functions/processCompatibility
./terraform/scripts/package_lambda.sh functions/getCompatibility
./terraform/scripts/package_lambda.sh functions/updateCompatibility
./terraform/scripts/package_lambda.sh functions/deleteCompatibility

terraform init
terraform plan
terraform apply
