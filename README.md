# DevOps Code Challenge

## Overview
This project includes a **React frontend** and an **Express backend**, deployed using **AWS ECS (Fargate)**. Infrastructure is provisioned using **Terraform**, and **Jenkins** automates the CI/CD pipeline.

## Architecture
- **Terraform** provisions AWS resources.
- **Amazon ECS (Fargate)** runs frontend and backend services.
- **Amazon ECR** stores container images.
- **Application Load Balancer (ALB)** exposes services.
- **Jenkins** handles CI/CD.

## Prerequisites
Ensure you have the following installed:
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Jenkins](https://www.jenkins.io/download/)
- Node.js (v16 recommended)

## Repository Structure
```
repo/
│── terraform/                # Terraform configuration files
│── backend/                  # Backend service
│   ├── Dockerfile            # Backend Dockerfile
│   ├── index.js              # Express server
│   ├── config.js             # Backend config
│── frontend/                 # Frontend service
│   ├── Dockerfile            # Frontend Dockerfile
│   ├── src/config.js         # Frontend API config
│── Jenkinsfile.backend       # Jenkins pipeline for backend
│── Jenkinsfile.frontend      # Jenkins pipeline for frontend
│── README.md                 # Documentation
```

## Infrastructure Setup (Terraform)
1. Navigate to the Terraform directory:
   ```sh
   cd terraform
   ```
2. Initialize Terraform:
   ```sh
   terraform init
   ```
3. Plan the deployment:
   ```sh
   terraform plan
   ```
4. Apply the changes:
   ```sh
   terraform apply -auto-approve
   ```

## Building & Pushing Docker Images
1. **Login to AWS ECR**
   ```sh
   aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com
   ```
2. **Build & Push Backend Image**
   ```sh
   cd backend
   docker build -t backend-app .
   docker tag backend-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/backend-app:latest
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/backend-app:latest
   ```
3. **Build & Push Frontend Image**
   ```sh
   cd frontend
   docker build -t frontend-app .
   docker tag frontend-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/frontend-app:latest
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/frontend-app:latest
   ```

## CI/CD with Jenkins
Jenkins pipelines are set up to automate deployments.

### Backend Deployment
1. Navigate to **Jenkins Dashboard**.
2. Select **backend-service** job.
3. Click **Build Now**.

### Frontend Deployment
1. Navigate to **Jenkins Dashboard**.
2. Select **frontend-service** job.
3. Click **Build Now**.

## Accessing the Application
- **Frontend ALB URL**: `http://<frontend-alb-url>`

## Troubleshooting
### **ALB Returns 504 Gateway Timeout**
- Ensure ECS tasks are running (`aws ecs list-tasks --cluster <cluster-name>`).
- Verify security groups allow traffic.
- Check health status of target groups.

### **CORS Issues**
- Update `backend/config.js` and `frontend/src/config.js` to allow appropriate origins.

## Cleanup
To destroy all resources:
```sh
cd terraform
terraform destroy -auto-approve
```

---
**Author**: <your name>  
**Last Updated**: March 2025
