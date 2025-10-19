#!/bin/bash
set -euo pipefail

VAULT_NAMESPACE="vault"
VAULT_POD=$(kubectl get pods -n $VAULT_NAMESPACE -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$VAULT_POD" ]; then
  echo "Vault pod not found. Is Vault installed?"
  exit 1
fi

echo "Initializing Vault..."
kubectl exec -n $VAULT_NAMESPACE $VAULT_POD -- vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json >vault-keys.json

VAULT_TOKEN=$(jq -r '.root_token' vault-keys.json)

echo "Unsealing Vault..."
for i in {0..2}; do
  KEY=$(jq -r ".unseal_keys_b64[$i]" vault-keys.json)
  kubectl exec -n $VAULT_NAMESPACE $VAULT_POD -- vault operator unseal $KEY
done

echo "Configuring Vault..."
kubectl exec -n $VAULT_NAMESPACE $VAULT_POD -- sh -c "
  export VAULT_TOKEN=$VAULT_TOKEN
  
  vault secrets enable -path=secret kv-v2
  
  vault auth enable kubernetes
  
  vault write auth/kubernetes/config \
    kubernetes_host=https://kubernetes.default.svc:443
  
  vault policy write external-secrets - <<EOF
path \"secret/*\" {
  capabilities = [\"read\", \"list\"]
}
EOF
  
  vault write auth/kubernetes/role/external-secrets \
    bound_service_account_names=external-secrets \
    bound_service_account_namespaces=external-secrets-system \
    policies=external-secrets \
    ttl=24h
"

echo "Creating application secrets..."
kubectl exec -n $VAULT_NAMESPACE $VAULT_POD -- sh -c "
  export VAULT_TOKEN=$VAULT_TOKEN
  
  # Homarr secrets
  vault kv put secret/homarr \
    SECRET_ENCRYPTION_KEY='$(openssl rand -hex 32)' \
    JWT_SECRET='$(openssl rand -hex 32)'
  
  # Linkding secrets
  vault kv put secret/linkding \
    SECRET_ENCRYPTION_KEY='$(openssl rand -hex 32)'
"

echo "Vault initialized and configured!"
echo "Root token: $VAULT_TOKEN"
echo "Save vault-keys.json securely!"
