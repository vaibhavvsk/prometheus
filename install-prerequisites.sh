#!/bin/bash
# Prometheus Build Prerequisites Installation Script for WSL/Ubuntu
# This script installs Go and other dependencies without requiring sudo

set -e

echo "=== Installing Prometheus Build Prerequisites ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install Go in user space
GO_VERSION="1.21.5"
GO_INSTALL_DIR="$HOME/go"
GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"

echo -e "${YELLOW}[1/4] Installing Go ${GO_VERSION}...${NC}"
if [ -d "$GO_INSTALL_DIR" ]; then
    echo "Go directory already exists at $GO_INSTALL_DIR"
    read -p "Remove and reinstall? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$GO_INSTALL_DIR"
    else
        echo "Skipping Go installation"
    fi
fi

if [ ! -d "$GO_INSTALL_DIR" ]; then
    cd /tmp
    echo "Downloading Go ${GO_VERSION}..."
    wget -q --show-progress https://go.dev/dl/${GO_TARBALL}
    echo "Extracting Go..."
    tar -C $HOME -xzf ${GO_TARBALL}
    rm ${GO_TARBALL}
    echo -e "${GREEN}✓ Go installed to $GO_INSTALL_DIR${NC}"
fi

# Set up environment variables
export PATH=$HOME/go/bin:$PATH
export GOPATH=$HOME/go-workspace
export GO111MODULE=on

# Add to bashrc if not already present
if ! grep -q "export PATH=\$HOME/go/bin:\$PATH" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Go environment" >> ~/.bashrc
    echo "export PATH=\$HOME/go/bin:\$PATH" >> ~/.bashrc
    echo "export GOPATH=\$HOME/go-workspace" >> ~/.bashrc
    echo "export GO111MODULE=on" >> ~/.bashrc
    echo -e "${GREEN}✓ Added Go to ~/.bashrc${NC}"
fi

# Verify Go installation
echo ""
echo -e "${YELLOW}[2/4] Verifying Go installation...${NC}"
$HOME/go/bin/go version
echo -e "${GREEN}✓ Go is working${NC}"

# Verify Node.js and npm
echo ""
echo -e "${YELLOW}[3/4] Verifying Node.js and npm...${NC}"
node --version
npm --version
echo -e "${GREEN}✓ Node.js and npm are installed${NC}"

# Verify Yarn
echo ""
echo -e "${YELLOW}[4/4] Verifying Yarn...${NC}"
if ! command -v yarn &> /dev/null; then
    echo "Installing Yarn..."
    npm install -g yarn
fi
yarn --version
echo -e "${GREEN}✓ Yarn is installed${NC}"

# Summary
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Prerequisites installed:"
echo "  ✓ Go ${GO_VERSION} at $GO_INSTALL_DIR"
echo "  ✓ Node.js $(node --version)"
echo "  ✓ npm $(npm --version)"
echo "  ✓ Yarn $(yarn --version)"
echo ""
echo "Environment variables set:"
echo "  PATH=$HOME/go/bin:\$PATH"
echo "  GOPATH=$HOME/go-workspace"
echo "  GO111MODULE=on"
echo ""
echo -e "${YELLOW}IMPORTANT: Run 'source ~/.bashrc' or restart your terminal to apply changes${NC}"
echo ""
echo "Next steps:"
echo "  1. cd /home/vaibhav/git/prometheus"
echo "  2. Run: ./build-prometheus.sh"
