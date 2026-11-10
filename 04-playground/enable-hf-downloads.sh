#!/bin/bash
# Enables HuggingFace model downloads in OGX playground pod.
# Required for RAG to work (downloads granite-embedding-125m-english).
set -euo pipefail

echo "Finding HF offline env var indices in OGXServer..."

for VAR in HF_HUB_OFFLINE TRANSFORMERS_OFFLINE HF_DATASETS_OFFLINE; do
  IDX=$(oc get ogxserver lsd-genai-playground -n models-as-a-service -o json | \
    python3 -c "import sys,json; e=json.load(sys.stdin)['spec']['workload']['overrides']['env']; \
    print(next((i for i,x in enumerate(e) if x['name']=='${VAR}'), -1))")
  if [ "$IDX" -ge 0 ]; then
    oc patch ogxserver lsd-genai-playground -n models-as-a-service --type=json \
      -p="[{\"op\":\"replace\",\"path\":\"/spec/workload/overrides/env/${IDX}\",\"value\":{\"name\":\"${VAR}\",\"value\":\"0\"}}]" > /dev/null
    echo "  Set ${VAR}=0 (index ${IDX})"
  else
    echo "  ${VAR} not found in OGXServer env — skipping"
  fi
done

echo "HF downloads enabled. Playground pod will restart and download embedding model (~500MB)."
echo "Wait ~60 seconds before testing RAG."
