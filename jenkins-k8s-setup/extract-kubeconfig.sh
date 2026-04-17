#!/bin/bash
# extract-kubeconfig.sh
#
# Generates a namespace-scoped kubeconfig for the jenkins-sa ServiceAccount.
# The resulting kubeconfig gives access ONLY to the "testing" namespace.
#
# Prerequisites:
#   - kubectl configured with cluster-admin (or sufficient) access
#   - All manifests applied: namespace.yaml, jenkins-rbac.yaml, jenkins-sa-secret.yaml
#
# Usage:
#   chmod +x extract-kubeconfig.sh
#   ./extract-kubeconfig.sh
#   # Output: jenkins-testing-kubeconfig.yaml (store this as a Jenkins credential)

set -euo pipefail

NAMESPACE="testing"
SA_NAME="jenkins-sa"
SECRET_NAME="jenkins-sa-token"
OUTPUT_FILE="jenkins-testing-kubeconfig.yaml"

echo "[*] Applying manifests..."
kubectl apply -f namespace.yaml
kubectl apply -f jenkins-rbac.yaml
kubectl apply -f jenkins-sa-secret.yaml

echo "[*] Waiting for token to be populated..."
kubectl wait --for=jsonpath='{.data.token}' \
  secret/"${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --timeout=30s

echo "[*] Extracting token and CA..."
TOKEN=$(kubectl get secret "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  -o jsonpath='{.data.token}' | base64 --decode)

CA_DATA=$(kubectl get secret "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  -o jsonpath='{.data.ca\.crt}')

# Retrieve the cluster's API server URL from the current context
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

echo "[*] Building kubeconfig -> ${OUTPUT_FILE}"
cat > "${OUTPUT_FILE}" <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: ${CLUSTER_NAME}
    cluster:
      certificate-authority-data: ${CA_DATA}
      server: ${SERVER}
contexts:
  - name: jenkins-testing
    context:
      cluster: ${CLUSTER_NAME}
      namespace: ${NAMESPACE}
      user: ${SA_NAME}
current-context: jenkins-testing
users:
  - name: ${SA_NAME}
    user:
      token: ${TOKEN}
EOF

echo "[+] Done. Kubeconfig written to: ${OUTPUT_FILE}"
echo "    Store its contents as a 'Secret file' or 'Secret text' credential in Jenkins."
echo ""
echo "    NOTE: This token grants access ONLY to the '${NAMESPACE}' namespace."
echo "          Jenkins cannot list/modify any other namespace or cluster resource."