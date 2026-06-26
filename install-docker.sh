#!/bin/bash
# Docker Installation Script for WSL/Ubuntu
# Installs Docker and configures non-root access

set -e

echo "=== Installing Docker on WSL/Ubuntu ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running in WSL
if ! grep -qi microsoft /proc/version; then
    echo -e "${RED}Warning: This script is designed for WSL. Proceed with caution.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${YELLOW}[1/6] Updating package index...${NC}"
sudo apt-get update

echo -e "${YELLOW}[2/6] Installing prerequisites...${NC}"
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo -e "${YELLOW}[3/6] Adding Docker's official GPG key...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo -e "${YELLOW}[4/6] Setting up Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${YELLOW}[5/6] Installing Docker Engine...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${YELLOW}[6/6] Configuring non-root access...${NC}"

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null 2>&1; then
    sudo groupadd docker
    echo "Created docker group"
fi

# Add current user to docker group
sudo usermod -aG docker $USER
echo "Added $USER to docker group"

# Start Docker service (for WSL2)
echo ""
echo -e "${YELLOW}Starting Docker service...${NC}"
sudo service docker start

# Verify installation
echo ""
echo -e "${YELLOW}Verifying Docker installation...${NC}"
sudo docker run hello-world

echo ""
echo "=== Docker Installation Complete ==="
echo ""
echo -e "${GREEN}✓ Docker Engine installed${NC}"
echo -e "${GREEN}✓ Docker Compose plugin installed${NC}"
echo -e "${GREEN}✓ User '$USER' added to docker group${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: To use Docker without sudo, you need to:${NC}"
echo "  1. Log out and log back in (or restart WSL)"
echo "  2. Or run: newgrp docker"
echo ""
echo "To start Docker service in WSL, run:"
echo "  sudo service docker start"
echo ""
echo "To auto-start Docker on WSL startup, add to ~/.bashrc:"
echo "  if ! pgrep -x dockerd > /dev/null; then"
echo "    sudo service docker start > /dev/null 2>&1"
echo "  fi"
echo ""
echo "Verify Docker works without sudo:"
echo "  docker run hello-world"
