#!/bin/bash

#
# 'Debian GNU/Linux 13.5 (trixie)'
#
set -euo pipefail

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    unzip \
    zip \
    git \
    jq \
    tree \
    make \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client \
    ansible

echo "Installing Azure CLI"
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo "Installing Terraform"
wget -qO- https://apt.releases.hashicorp.com/gpg \
| gpg --dearmor \
> /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo \
"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" \
> /etc/apt/sources.list.d/hashicorp.list

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y terraform

echo "Installing terraform-docs"
TERRAFORM_DOCS_VERSION="0.21.0"

curl -Lo terraform-docs.tar.gz \
https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz

tar -xzf terraform-docs.tar.gz

mv terraform-docs /usr/local/bin/

rm terraform-docs.tar.gz


echo "Installing Checkov"
python3 -m venv /opt/checkov-venv

/opt/checkov-venv/bin/pip install --upgrade pip
/opt/checkov-venv/bin/pip install checkov

ln -sf /opt/checkov-venv/bin/checkov /usr/local/bin/checkov

chmod +x /usr/local/bin/checkov


echo "Installing TFLint..."
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
mv tflint /usr/local/bin/


echo
echo "======================================"
echo "Installed versions"
echo "======================================"

git --version
terraform version
az version | head
ansible --version | head -n 1
terraform-docs --version
checkov --version
tflint --version

apt-get clean
rm -rf /var/lib/apt/lists/*
