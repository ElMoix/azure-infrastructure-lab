# azure-infrastructure-lab

## Deployment

1. Run the setup script (utilities, az-cli, terraform, ansible).

   ```bash
   bash ./scripts/setup.sh
   ```

2. Create an Azure Free Account.

3. Sign in to Azure.

   ```bash
   az login
   ```

4. Verify that the correct subscription is selected.

   ```bash
   az account show
   ```

5. Change to the Terraform directory.

   ```bash
   cd ./terraform
   ```

6. Generate an SSH key pair.

    ```bash
   ssh-keygen -t ed25519 -C "elmoix@azure-lab"
   ```

7. Initialize the Terraform working directory.

   ```bash
   terraform init
   ```

8. Review the execution plan (RG, VNet, Subnet, NSG, Public IP, NIC and VM).

   ```bash
   terraform plan
   ```

9. Deploy the infrastructure.

   ```bash
   terraform apply
   ```

10. Confirm that the Resource Group has been created.

   ```bash
   az group list -o table
   ```

## Destroy the infrastructure

To avoid unnecessary charges, destroy all deployed resources when you finish.

```bash
terraform destroy
```

