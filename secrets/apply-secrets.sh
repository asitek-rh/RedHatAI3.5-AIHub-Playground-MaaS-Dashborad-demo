#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/api-keys.env" ]; then
  echo "ERROR: api-keys.env not found. Copy api-keys.env.template and fill in values."
  exit 1
fi

source "$SCRIPT_DIR/api-keys.env"

echo "Creating API key secrets in models-as-a-service..."

oc create secret generic playground-demo-secret \
  --from-literal=apitoken="$PLAYGROUND_DEMO_KEY" \
  -n models-as-a-service --dry-run=client -o yaml | oc apply -f -

oc create secret generic playground-prod-secret \
  --from-literal=apitoken="$PLAYGROUND_PROD_KEY" \
  -n models-as-a-service --dry-run=client -o yaml | oc apply -f -

oc create secret generic goose-secret \
  --from-literal=apitoken="$GOOSE_KEY" \
  -n models-as-a-service --dry-run=client -o yaml | oc apply -f -

oc create secret generic qwen-secret \
  --from-literal=apitoken="$QWEN_KEY" \
  -n models-as-a-service --dry-run=client -o yaml | oc apply -f -

echo "Creating OLS secret in openshift-lightspeed..."

oc create secret generic gpt-oss-maas-key \
  --from-literal=apitoken="$OLS_KEY" \
  -n openshift-lightspeed --dry-run=client -o yaml | oc apply -f -

echo "All secrets created."
