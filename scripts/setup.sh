#!/bin/bash

#
# 'Ubuntu 22.04.5 LTS'
#
set -euo pipefail

RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'
BLUE='\e[34m'
NC='\e[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

echo -e "\n${BLUE}1. Retrieving OS info${NC}"
echo -e "${GREEN}$ cat /etc/os-release${NC}"
cat /etc/os-release
echo -e "\n${GREEN}$ cat /etc/lsb-release${NC}"
cat /etc/lsb-release
echo -e "\n${GREEN}$ cat /proc/version${NC}"
cat /proc/version

# TIP:
# If you're running inside WSL, 'az login' may fail to open the default Windows browser
# and show a 'gio: Operation not supported' error.
# Install 'wslu' and set the BROWSER environment variable to 'wslview':
#
#   sudo apt install wslu
#   export BROWSER=wslview

echo -e "\n${BLUE}2. Updating system${NC}"
sudo apt update
sudo apt upgrade -y

echo -e "\n${BLUE}3. Installing common packages${NC}"
sudo apt install -y \
    curl \
    wget \
    unzip \
    zip \
    git \
    jq \
    tree \
    make \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    python3-venv \
    openssh-client


# Update branch in Jenkinsfile and config
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "${REPO_ROOT}")"
CURRENT_BRANCH="$(git branch --show-current)"
CONFIG_FILE="${REPO_ROOT}/docker/jenkins/jobs/${REPO_NAME}/config.xml"
JENKINSFILE="${REPO_ROOT}/Jenkinsfile"
sed -i "s|<name>\\*/.*</name>|<name>*/${CURRENT_BRANCH}</name>|" "${CONFIG_FILE}"
sed -i "s|branch: '[^']*'|branch: '${CURRENT_BRANCH}'|" "${JENKINSFILE}"


echo -e "\n${BLUE}4. Installing Azure CLI${NC}"
if command -v az >/dev/null 2>&1; then
    echo -e "${GREEN}Azure CLI is already installed, not installing it again.${NC}"
else
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

echo -e "\n${BLUE}5. Installing Terraform${NC}"
if command -v terraform >/dev/null 2>&1; then
    echo -e "${GREEN}Terraform is already installed, not installing it again.${NC}"
else
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
    echo \
    "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com \
    $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update
    sudo apt install -y terraform
fi

echo -e "\n${BLUE}6. Installing Ansible${NC}"
if command -v ansible >/dev/null 2>&1; then
    echo -e "${GREEN}Ansible is already installed, not installing it again.${NC}"
else
    sudo apt install -y ansible
fi

echo -e "\n${BLUE}7. Installing Docker${NC}"

if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}Docker is already installed, not installing it again.${NC}"
else
    sudo install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update

    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    if groups "$USER" | grep -q docker; then
        echo -e "${GREEN}User already belongs to docker group.${NC}"
    else
        sudo usermod -aG docker "$USER"
        echo -e "${YELLOW}Docker group added. Logout/login required.${NC}"
    fi
fi


echo -e "\n${BLUE}8. Installing terraform-docs${NC}"
if command -v terraform-docs >/dev/null 2>&1; then
    echo -e "${GREEN}terraform-docs is already installed, not installing it again.${NC}"
else
    TERRAFORM_DOCS_VERSION="0.21.0"

    curl -Lo terraform-docs.tar.gz \
    https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz

    tar -xzf terraform-docs.tar.gz

    sudo mv terraform-docs /usr/local/bin/

    rm terraform-docs.tar.gz
fi

echo
echo -e "${YELLOW}==========================================="
echo -e "Installed versions"
echo -e "===========================================${NC}"
echo -e "\n${GREEN}$ git --version${NC}"
git --version

echo -e "\n${GREEN}$ terraform version${NC}"
terraform version

echo -e "\n${GREEN}$ az version${NC}"
az version | head

echo -e "\n${GREEN}$ ansible --version${NC}"
ansible --version | head -n 1

echo -e "\n${GREEN}$ terraform-docs --version${NC}"
terraform-docs --version

echo -e "\n${GREEN}$ docker --version${NC}"
docker --version

echo -e "\n${GREEN}$ docker compose version${NC}"
docker compose version

echo
echo
echo -e "\n${BLUE}8. Configuring accounts${NC}"
bash "$(dirname "$0")/setup-accounts.sh"
