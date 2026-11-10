#!/bin/bash
# Patches OGXServer env vars to reference the API key secrets.
# Run AFTER secrets/apply-secrets.sh and after models are deployed.
set -euo pipefail

echo "Patching OGXServer with API token secrets..."

IDX1=$(oc get ogxserver lsd-genai-playground -n models-as-a-service -o json | \
  python3 -c "import sys,json; e=json.load(sys.stdin)['spec']['workload']['overrides']['env']; \
  print(next((i for i,x in enumerate(e) if x['name']=='VLLM_API_TOKEN_1'), None))")

IDX2=$(oc get ogxserver lsd-genai-playground -n models-as-a-service -o json | \
  python3 -c "import sys,json; e=json.load(sys.stdin)['spec']['workload']['overrides']['env']; \
  print(next((i for i,x in enumerate(e) if x['name']=='VLLM_API_TOKEN_2'), None))")

if [ "$IDX1" = "None" ] || [ "$IDX2" = "None" ]; then
  echo "ERROR: VLLM_API_TOKEN_1 or VLLM_API_TOKEN_2 not found in OGXServer."
  echo "Make sure you have added both models to playground via AI Asset Endpoints first."
  exit 1
fi

oc patch ogxserver lsd-genai-playground -n models-as-a-service --type=json -p="[
  {\"op\":\"replace\",\"path\":\"/spec/workload/overrides/env/${IDX1}\",\"value\":{\"name\":\"VLLM_API_TOKEN_1\",\"valueFrom\":{\"secretKeyRef\":{\"name\":\"playground-demo-secret\",\"key\":\"apitoken\"}}}},
  {\"op\":\"replace\",\"path\":\"/spec/workload/overrides/env/${IDX2}\",\"value\":{\"name\":\"VLLM_API_TOKEN_2\",\"valueFrom\":{\"secretKeyRef\":{\"name\":\"qwen-secret\",\"key\":\"apitoken\"}}}}
]"

echo "OGXServer patched. Waiting for pod rollout..."
oc rollout status deployment/lsd-genai-playground -n models-as-a-service --timeout=120s
echo "Done."
