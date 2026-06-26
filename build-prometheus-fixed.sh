#!/bin/bash
# Prometheus Build Script with Node.js compatibility fix
# Builds Prometheus binaries and React UI

set -e

echo "=== Building Prometheus (with Node.js compatibility fix) ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set up Go environment
export PATH=$HOME/go/bin:$PATH
export GOPATH=$HOME/go-workspace
export GO111MODULE=on

# Fix for Node.js 17+ compatibility with older webpack
export NODE_OPTIONS=--openssl-legacy-provider

# Verify we're in the right directory
if [ ! -f "go.mod" ] || [ ! -f "Makefile" ]; then
    echo -e "${RED}Error: Must be run from Prometheus repository root${NC}"
    exit 1
fi

# Verify Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}Error: Go is not installed or not in PATH${NC}"
    echo "Please run ./install-prerequisites.sh first"
    exit 1
fi

echo -e "${YELLOW}[1/6] Verifying prerequisites...${NC}"
echo "Go version: $(go version)"
echo "Node version: $(node --version)"
echo "Yarn version: $(yarn --version)"
echo "Node options: $NODE_OPTIONS"
echo -e "${GREEN}✓ Prerequisites verified${NC}"
echo ""

# Download Go dependencies
echo -e "${YELLOW}[2/6] Downloading Go dependencies...${NC}"
go mod download
echo -e "${GREEN}✓ Go dependencies downloaded${NC}"
echo ""

# Install Node.js dependencies for React app
echo -e "${YELLOW}[3/6] Installing Node.js dependencies...${NC}"
cd web/ui/react-app
yarn install --frozen-lockfile
cd ../../..
echo -e "${GREEN}✓ Node.js dependencies installed${NC}"
echo ""

# Build React app with Node.js compatibility fix
echo -e "${YELLOW}[4/6] Building React UI (with legacy OpenSSL provider)...${NC}"
cd web/ui/react-app
PUBLIC_URL=. yarn build
rm -rf ../static/react
mv build ../static/react
cd ../../..
echo -e "${GREEN}✓ React UI built${NC}"
echo ""

# Generate Go assets from React build
echo -e "${YELLOW}[5/6] Generating Go assets...${NC}"
cd web/ui
go generate -x -v
cd ../..
echo -e "${GREEN}✓ Go assets generated${NC}"
echo ""

# Build Prometheus binaries
echo -e "${YELLOW}[6/6] Building Prometheus binaries...${NC}"
echo "This may take a few minutes..."

# Build prometheus
go build -o prometheus ./cmd/prometheus
echo -e "${GREEN}✓ Built: prometheus${NC}"

# Build promtool
go build -o promtool ./cmd/promtool
echo -e "${GREEN}✓ Built: promtool${NC}"

echo ""
echo "=== Build Complete ==="
echo ""
echo "Binaries created:"
echo "  $(pwd)/prometheus"
echo "  $(pwd)/promtool"
echo ""
echo "Verify builds:"
echo "  ./prometheus --version"
echo "  ./promtool --version"
echo ""
echo "To run Prometheus:"
echo "  ./prometheus --config.file=documentation/examples/prometheus.yml"
