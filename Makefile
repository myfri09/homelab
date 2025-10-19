.PHONY: help bootstrap destroy status sync logs vault-init

CLUSTER_NAME ?= homelab
NAMESPACE ?= argocd

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Bootstrap the entire homelab
	@echo "Bootstrapping homelab..."
	@bash bootstrap/bootstrap.sh

vault-init: ## Initialize Vault
	@echo "Initializing Vault..."
	@bash bootstrap/init-vault.sh

destroy: ## Destroy all ArgoCD applications (careful!)
	@echo "WARNING: This will destroy all applications!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ] || exit 1
	kubectl delete application --all -n $(NAMESPACE)

status: ## Check status of all applications
	@echo "=== ArgoCD Applications ==="
	@kubectl get applications -n $(NAMESPACE)
	@echo ""
	@echo "=== Non-Running Pods ==="
	@kubectl get pods --all-namespaces | grep -v Running | grep -v Completed || echo "All pods running!"

sync: ## Force sync all applications
	@kubectl get applications -n $(NAMESPACE) -o name | xargs -I {} kubectl patch {} -n $(NAMESPACE) --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'

logs: ## Tail ArgoCD controller logs
	@kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/name=argocd-application-controller -f

port-forward: ## Port forward ArgoCD UI
	@echo "ArgoCD UI will be available at http://localhost:8080"
	@kubectl port-forward svc/argocd-server -n $(NAMESPACE) 8080:80

get-password: ## Get ArgoCD admin password
	@echo -n "ArgoCD admin password: "
	@kubectl -n $(NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""

get-metallb-ip: ## Get MetalLB IP assignment
	@echo "=== MetalLB IP Assignments ==="
	@kubectl get svc -A | grep LoadBalancer

test-apps: ## Test application endpoints
	@echo "Testing application endpoints..."
	@curl -s -o /dev/null -w "ArgoCD: %{http_code}\n" http://argocd.myfri09.lan || true
	@curl -s -o /dev/null -w "Homarr: %{http_code}\n" http://homarr.myfri09.lan || true
	@curl -s -o /dev/null -w "Linkding: %{http_code}\n" http://linkding.myfri09.lan || true
	@curl -s -o /dev/null -w "Vault: %{http_code}\n" http://vault.myfri09.lan || true
	@curl -s -o /dev/null -w "Dashboard: %{http_code}\n" http://dashboard.myfri09.lan || true
