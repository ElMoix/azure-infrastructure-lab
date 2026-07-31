# Setup

## 1. Install required tools

Run the setup script:

```bash
./scripts/setup.sh
```

Important: You will need to logout/login in order to be added to the "docker" group


## Prerequisites

Before starting Jenkins, create the required credentials.

---

## GitHub Personal Access Token

Jenkins needs a GitHub token to clone the repository.

### Create GitHub Token

Go to:

```text
GitHub
 -> Settings
 -> Developer settings
 -> Personal access tokens
 -> Tokens (classic)
 -> Generate new token
```

Create the token and save it securely.

---

### Configure GitHub credentials

Create a file:

```text
docker/.env
```

Add:

```env
GITHUB_USERNAME=<github_username>
GITHUB_TOKEN=<github_personal_access_token>
```

This file is loaded by Docker Compose and injected into Jenkins Configuration as Code.

---

## Azure Service Principal

Terraform uses an Azure Service Principal to authenticate with Azure.

### Login into Azure

```bash
az login
```

Check the active subscription:

```bash
az account show
```

---

### Create Service Principal

Create the Service Principal:

```bash
az ad sp create-for-rbac \
  --name azure-infrastructure-lab \
  --role Contributor \
  --scopes /subscriptions/<subscription_id>
```

The output will be similar to:

```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "password": "xxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Save these values:

```text
clientId  -> appId
clientSecret -> password
tenantId -> tenant
subscriptionId -> Azure subscription ID
```

---

### Add Azure credentials to Docker environment

Update:

```text
docker/.env
```

Add:

```env
AZURE_CLIENT_ID=<client_id>
AZURE_CLIENT_SECRET=<client_secret>
AZURE_TENANT_ID=<tenant_id>
AZURE_SUBSCRIPTION_ID=<subscription_id>
```

The complete file:

```env
GITHUB_USERNAME=<github_username>
GITHUB_TOKEN=<github_token>

AZURE_CLIENT_ID=<client_id>
AZURE_CLIENT_SECRET=<client_secret>
AZURE_TENANT_ID=<tenant_id>
AZURE_SUBSCRIPTION_ID=<subscription_id>
```

---

# Jenkins Setup with Docker

## 1. Build the Jenkins Docker image

```bash
cd docker
docker compose build
```

---

## 2. Start Jenkins container

```bash
docker compose up -d
docker ps
```

Expected container:

```text
azure-lab-jenkins
```

---

## 3. Access Jenkins

Open:

```text
http://localhost:8080
```

Login with Jenkins credentials.
Default credentials:

```text
Username: admin
Password: admin
```

Change the password.
Configuration file:

```text
docker/jenkins/casc/jenkins.yaml
```

---

## 4. Pipeline Jenkins

The project includes a Jenkins Pipeline that automates the deployment of the Terraform infrastructure.

### Supported environments

- `dev`
- `prod`

### Pipeline workflow

1. Initialize and validate the Terraform configuration.
2. Run a Checkov security scan.
3. Generate the Terraform execution plan.
4. Wait for manual approval.
5. Apply the infrastructure changes.

### Deployment options

Infrastructure components can be enabled or disabled through pipeline parameters, for example:

- Azure Virtual Machine
- Azure SQL Database

