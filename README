

This is a serverless AWS application to calculate and manage compatibility scores between users, built with API Gateway, Lambda, SQS, DynamoDB, and deployed using Terraform. This project demonstrates a scalable, highly available architecture with robust observability.

Overview

This application allows users to submit compatibility data (names, ages, score), retrieve, update, or delete results via a REST API. The backend processes requests asynchronously, stores data in DynamoDB, and ensures reliability with features like reserved concurrency, provisioned concurrency and dead-letter queues. Observability is provided through CloudWatch logs, metrics, alarms, and a dashboard.





# Run this script to package and upload the lambda functions to S3

chmod +x terraform/scripts/package_lambda.sh
./terraform/scripts/package_lambda.sh functions/calculateCompatibility
./terraform/scripts/package_lambda.sh functions/processCompatibility
./terraform/scripts/package_lambda.sh functions/getCompatibility
./terraform/scripts/package_lambda.sh functions/updateCompatibility
./terraform/scripts/package_lambda.sh functions/deleteCompatibility

terraform init
terraform plan
terraform apply
