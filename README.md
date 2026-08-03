# Setup

## 1. Install required tools

Run the setup script:

```bash
./scripts/setup.sh
```

Important: You will need to logout/login in order to be added to the "docker" group


### Prerequisites

Before starting the service, create the required credentials.
The './scripts/setup.sh' script will execute a './scripts/setup-accounts.sh' script in order to create the needed credentials.

---

### GitHub fine-grained PAT

Already executed with './scripts/setup-accounts.sh'.
Jenkins needs a GitHub token to clone the repository.

```text
https://github.com/settings/personal-access-tokens/new?name=Azure%20Infrastructure%20Lab&description=Token%20for%20Jenkins%20Pipeline&expires_in=30&contents=read
```

Create the token and save it securely.

---

### Azure Service Principal

Already executed with './scripts/setup-accounts.sh'.
Terraform uses an Azure Service Principal to authenticate with Azure.

### Create Service Principal
```bash
az login

az account show

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

## 2. Add the credentials to Docker environment

Create:

```text
docker/.env
```

Add:

```env
GITHUB_USERNAME=<github_username>
GITHUB_TOKEN=<github_token>

AZURE_CLIENT_ID=<client_id>
AZURE_CLIENT_SECRET=<client_secret>
AZURE_TENANT_ID=<tenant_id>
AZURE_SUBSCRIPTION_ID=<subscription_id>
```

---

## 3. Start and Setup the services with Docker

Will build an image for Jenkins and Vault and do the initial setup.

```bash
cd docker
./docker-start.sh
```

### 3.1 Access the web services

Open:

```text
Jenkins: http://localhost:8080
Vault:   http://localhost:8200/
```

- For Jenkins, use the default credentials:
```text
Username: admin
Password: admin
```
Change the password.
Configuration file:
```text
docker/jenkins/casc/jenkins.yaml
```

- For Vault:
Check the content on:
```text
docker/vault/secrets/root-token
```

---

## 4. Pipeline Jenkins

The project includes a Jenkins Pipeline that automates the deployment of the Terraform infrastructure.
It uses Hashicorp Vault to store passwords and certificates.

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


---
# TREE SCHEMA

```bash
.
├── ansible
├── docker
│   ├── jenkins
│   │   ├── casc
│   │   └── jobs
│   └── vault
│       ├── config
│       ├── init
│       ├── logs
│       └── secrets
├── scripts
└── terraform
    ├── environments
    │   ├── dev
    │   └── prod
    └── modules
        ├── nsg
        ├── nsg_rule
        ├── resource_group
        ├── sql_database
        ├── subnet
        ├── virtual_network
        └── vm
```
