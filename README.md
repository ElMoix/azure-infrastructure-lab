# Setup

## 1. Install required tools

Run the setup script:

```bash
chmod +x scripts/setup.sh

./scripts/setup.sh
```

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

Navigate to the Docker directory:

```bash
cd docker
```

Build the custom Jenkins image:

```bash
docker compose build
```

---

## 2. Start Jenkins container

Start Jenkins:

```bash
docker compose up -d
```

Verify:

```bash
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

Change this password before using this setup in a real environment.

Configuration file:

```text
docker/jenkins/casc/jenkins.yaml
```

---

# Rebuild Jenkins after changes

If you modify:

- Dockerfile
- setup-docker.sh
- plugins.txt
- jenkins.yaml

Run:

```bash
docker compose down

docker compose build --no-cache

docker compose up -d
```
