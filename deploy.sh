#!/bin/bash
# Interactive restore script for RHOAI demo cluster
# NOTE: If deploying on a different cluster, update the hardcoded cluster domain
# 'sandbox3461.opentlc.com' in the following files before running:
#   - 05-ols/olsconfig.yaml (MaaS URL)
#   - 04-playground/llama-stack-config.yaml (MaaS URLs)
#   - goose/config.yaml (OPENAI_HOST)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pause() {
  echo ""
  echo ">>> $1"
  read -p "Press Enter when done..." _
}

echo "========================================"
echo " RHOAI Demo Cluster Restore"
echo " Estimated time: ~40 minutes"
echo "========================================"
echo ""

echo "[Step 1/10] Creating groups and service accounts..."
oc apply -f "$SCRIPT_DIR/01-rbac/"
echo "Done."

echo ""
echo "[Step 2/10] Applying LLMInferenceService definitions..."
oc apply -f "$SCRIPT_DIR/02-models/"

pause "[Step 2 cont.] WAIT: Both models must reach Ready status before continuing.
        RHOAI Dashboard → Models as a Service → verify gpt-oss-20b and qwen3-8b-fp8 are Ready.
        This takes 15-20 minutes (model loading)."

echo "[Step 3/10] Creating MaaS resources (ModelRefs, Subscriptions, AuthPolicies)..."
oc apply -f "$SCRIPT_DIR/03-maas/"
echo "Done."

pause "[Step 4/10] MANUAL - Add models to playground:
        1. RHOAI Dashboard → AI Asset Endpoints
        2. Click 'Add to playground' for: redhataigpt-oss-20b (use case: chat)
        3. Click 'Add to playground' for: redhataiqwen3-8b-fp8-dynamic (use case: chat on playground)
        NOTE: This overwrites llama-stack-config — we will fix it in the next step."

echo "[Step 5/10] Applying correct playground ConfigMap (overrides dashboard defaults)..."
oc apply -f "$SCRIPT_DIR/04-playground/llama-stack-config.yaml"
echo "Done."

pause "[Step 6/10] MANUAL - Generate 5 API keys in RHOAI dashboard.
        See docs/03-api-key-generation.md for exact steps.
        Then fill in: secrets/api-keys.env (copy from secrets/api-keys.env.template)"

echo "[Step 7/10] Creating secrets from API keys..."
bash "$SCRIPT_DIR/secrets/apply-secrets.sh"
echo "Done."

echo "[Step 8/10] Patching OGXServer with API token secrets..."
bash "$SCRIPT_DIR/04-playground/patch-ogxserver.sh"
echo "Done."

echo "[Step 9/10] Enabling HuggingFace downloads for RAG (embedding model)..."
bash "$SCRIPT_DIR/04-playground/enable-hf-downloads.sh"
echo "Done."

echo "[Step 10/10] Applying OLS and MCP server resources..."
oc apply -f "$SCRIPT_DIR/05-ols/"
oc apply -f "$SCRIPT_DIR/07-mcp/openshift-mcp-server-config.yaml"
oc apply -f "$SCRIPT_DIR/07-mcp/mcpserver.yaml"
echo "Done."

pause "MANUAL - Update Goose config:
        1. Edit goose/config.yaml - replace <GOOSE_API_KEY> with the actual goose-key value
        2. cp goose/config.yaml ~/.config/goose/config.yaml"

echo ""
echo "========================================"
echo " Optional: Create OLS demo pod"
echo " oc apply -f 06-demo/demo-gpu-pending.yaml"
echo ""
echo " MANUAL: Re-create RedHatSA system prompt"
echo " See docs/04-playground-prompt.md"
echo "========================================"
echo ""
echo " Restore complete!"
echo "========================================"
