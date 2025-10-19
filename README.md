# Homelab GitOps with Talos

GitOps-driven homelab infrastructure running on Talos Linux.

## Quick Start
```bash
# Prerequisites: Talos cluster running, kubectl configured

# 1. Clone repository
git clone https://github.com/myfri09/homelab
cd homelab

# 2. Make scripts executable
chmod +x bootstrap/*.sh

# 3. Run bootstrap
make bootstrap

# 4. Wait for infrastructure to deploy (~5 minutes)
kubectl get pods -A -w

# 5. Initialize Vault (after it's running)
make vault-init

# 6. Update vault tokens in:
# - apps/overlays/homarr/vault-token-secret.yaml
# - apps/overlays/linkding/vault-token-secret.yaml

# 7. Apply the updated secrets
kubectl apply -f apps/overlays/homarr/vault-token-secret.yaml
kubectl apply -f apps/overlays/linkding/vault-token-secret.yaml

# 8. Check status
make status
```

## Access URLs

- ArgoCD: http://argocd.myfri09.lan (password: `make get-password`)
- Vault: http://vault.myfri09.lan
- Dashboard: http://dashboard.myfri09.lan
- Homarr: http://homarr.myfri09.lan
- Linkding: http://linkding.myfri09.lan

## DNS Configuration

Add these entries to your DNS server or /etc/hosts:
argocd.myfri09.lan
vault.myfri09.lan
dashboard.myfri09.lan
homarr.myfri09.lan
linkding.myfri09.lan

Replace 10.0.0.240 with the actual IP assigned by MetalLB (check with `make get-metallb-ip`)

## Useful Commands
```bash
make help           # Show all commands
make status         # Check application status
make sync           # Force sync all apps
make port-forward   # Access ArgoCD locally
make logs           # View ArgoCD logs
make test-apps      # Test application endpoints
```

## Directory Structure
.
├── apps/
│   ├── base/          # Base application configs
│   └── overlays/      # Environment overlays
├── bootstrap/         # Bootstrap scripts
├── clusters/         # Cluster configurations
├── infrastructure/   # Infrastructure components
└── Makefile         # Automation commands
