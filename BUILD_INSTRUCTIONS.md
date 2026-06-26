# Prometheus Build Instructions for WSL/Ubuntu with UBI10 Docker Image

## Overview

This document provides complete instructions for building Prometheus from source on WSL/Ubuntu and creating a UBI10-based Docker image.

## Prerequisites Installed

✅ **Go 1.21.5** - Installed at `~/go/bin/go`
✅ **Node.js v24.16.0** - Already installed via nvm
✅ **npm 11.13.0** - Package manager for Node.js
✅ **Yarn 1.22.22** - JavaScript package manager
✅ **Build tools** - make, git, curl, tar, bzip2

## Build Scripts Created

### 1. `install-prerequisites.sh`
Installs Go 1.21.5 and verifies all build dependencies.

**Usage:**
```bash
./install-prerequisites.sh
source ~/.bashrc  # Apply environment changes
```

### 2. `build-prometheus-fixed.sh`
Builds Prometheus binaries and React UI with Node.js compatibility fix.

**Usage:**
```bash
./build-prometheus-fixed.sh
```

**What it does:**
- Downloads Go dependencies
- Installs Node.js dependencies for React app
- Builds React UI with `NODE_OPTIONS=--openssl-legacy-provider` (fixes Node.js 17+ compatibility)
- Generates Go assets from React build
- Compiles `prometheus` and `promtool` binaries

## Build Output

Successfully built binaries:
- `/home/vaibhav/git/prometheus/prometheus` - Main Prometheus server
- `/home/vaibhav/git/prometheus/promtool` - CLI tool for validation

**Verify builds:**
```bash
./prometheus --version
./promtool --version
```

## Running Prometheus Locally

```bash
./prometheus --config.file=documentation/examples/prometheus.yml
```

Access Prometheus at: http://localhost:9090

## UBI10 Docker Image

### Dockerfile: `Dockerfile.ubi10`

A multi-stage Dockerfile that:
1. **Builder stage** (UBI9 with dev tools):
   - Installs Go, Node.js, npm, yarn, and build tools
   - Builds React UI with Node.js compatibility fix
   - Compiles Prometheus binaries
   - Bundles npm licenses

2. **Runtime stage** (UBI9 minimal):
   - Minimal Red Hat Universal Base Image
   - Copies only runtime artifacts
   - Runs as `nobody` user (UID 65534)
   - Exposes port 9090
   - Data directory: `/prometheus`

### Build Docker Image

```bash
# Build the UBI10-based image
docker build -f Dockerfile.ubi10 -t prometheus-ubi10:latest .

# Run the container
docker run -p 9090:9090 -v prometheus-data:/prometheus prometheus-ubi10:latest
```

### Image Specifications

- **Base Image**: registry.access.redhat.com/ubi9/ubi-minimal:latest
- **Architecture**: linux/amd64
- **User**: nobody (65534)
- **Exposed Port**: 9090
- **Volume**: /prometheus
- **Estimated Size**: ~330MB (vs ~130MB for busybox-based image)

## Key Differences from Original Dockerfile

| Aspect | Original (busybox) | UBI10 Version |
|--------|-------------------|---------------|
| Base Image | quay.io/prometheus/busybox | registry.access.redhat.com/ubi9/ubi-minimal |
| Size | ~130MB | ~330MB |
| C Library | musl libc | glibc |
| Package Manager | None | microdnf |
| User Management | BusyBox style | Standard Linux |
| SELinux | Not compatible | Compatible |
| Enterprise Support | No | Yes (Red Hat) |

## Dependencies Summary

### Build-time Dependencies
- Go 1.13+ (installed: 1.21.5)
- Node.js 10+ (installed: 24.16.0)
- Yarn (installed: 1.22.22)
- make, git, curl, tar, bzip2
- gcc, gcc-c++ (for cgo if needed)

### Runtime Dependencies
- glibc (provided by UBI)
- Basic filesystem utilities
- nobody user/group

### Go Module Dependencies (from go.mod)
- github.com/prometheus/client_golang v1.2.0
- github.com/prometheus/common v0.8.0
- github.com/prometheus/alertmanager v0.18.0
- Cloud provider SDKs (AWS, Azure, GCP)
- Kubernetes client libraries
- Service discovery libraries (Consul, Zookeeper, etc.)

### Node.js Dependencies (from package.json)
- React 16.7.0
- TypeScript 3.3.3
- Bootstrap 4.2.1
- react-scripts 3.2.0
- Various testing and linting tools

## Troubleshooting

### Node.js Compatibility Issue

**Problem:** Node.js 17+ uses OpenSSL 3.0 which breaks older webpack versions.

**Error:**
```
Error: error:0308010C:digital envelope routines::unsupported
```

**Solution:** Set environment variable before building:
```bash
export NODE_OPTIONS=--openssl-legacy-provider
```

This is already included in `build-prometheus-fixed.sh`.

### Missing Go Binary

If `go` command is not found after installation:
```bash
export PATH=$HOME/go/bin:$PATH
source ~/.bashrc
```

### Permission Issues in Docker

If you encounter permission issues, ensure the `nobody` user has proper ownership:
```bash
chown -R nobody:nobody /etc/prometheus /prometheus
```

## Next Steps

1. **Test the Docker image:**
   ```bash
   docker build -f Dockerfile.ubi10 -t prometheus-ubi10:latest .
   docker run -p 9090:9090 prometheus-ubi10:latest
   ```

2. **Push to registry:**
   ```bash
   docker tag prometheus-ubi10:latest your-registry/prometheus-ubi10:latest
   docker push your-registry/prometheus-ubi10:latest
   ```

3. **Deploy to Kubernetes/OpenShift:**
   - Use the UBI10 image in your deployment manifests
   - Configure persistent volumes for `/prometheus`
   - Set up service discovery and alerting

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Red Hat Universal Base Images](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)
- [Go Modules Reference](https://go.dev/ref/mod)
- [React Build Documentation](https://create-react-app.dev/docs/production-build/)

## Build Environment

- **OS**: Ubuntu 26.04 LTS (WSL2)
- **Kernel**: 6.18.33.1-microsoft-standard-WSL2
- **Architecture**: x86_64
- **Go Version**: 1.21.5
- **Node Version**: 24.16.0
- **Build Date**: 2026-06-25
