# RHOAI 3.5 Demo Cluster Configuration Backup

Cluster: `api.ocp.pvtxr.sandbox3461.opentlc.com`  
OCP: 4.22.12 | RHOAI: 3.5.2 | GPU: 2× NVIDIA L4 (g6.2xlarge)

## What's in this repo

| Directory | Contents |
|-----------|----------|
| `01-rbac/` | OpenShift Groups (5) + ServiceAccounts (5) |
| `02-models/` | LLMInferenceService definitions (gpt-oss-20b, qwen3-8b-fp8) |
| `03-maas/` | MaaSSubscriptions (5) + MaaSAuthPolicies (5) |
| `04-playground/` | llama-stack-config ConfigMap + OGXServer patch script |
| `05-ols/` | OLSConfig (OpenShift Lightspeed) |
| `06-demo/` | demo-gpu-pending pod (OLS demo) |
| `secrets/` | Templates only — never committed with real values |
| `goose/` | Goose agent config (API key redacted) |
| `docs/` | Runbooks for GUI steps |

## Quick Restore

```bash
# 1. Login to cluster
oc login --token=<token> --server=https://api.<cluster>:6443

# 2. Run interactive restore
bash deploy.sh
```

Estimated restore time: **35-40 minutes** (mostly model loading).

## Models

| Model | Image | GPU |
|-------|-------|-----|
| gpt-oss-20b | `oci://registry.redhat.io/rhelai1/modelcar-gpt-oss-20b:1.5` | L4 us-east-2a |
| qwen3-8b-fp8 | `oci://registry.redhat.io/rhelai1/modelcar-qwen3-8b-fp8-dynamic:1.5` | L4 us-east-2b |

## Subscriptions

| Subscription | Group | Model | Quota |
|-------------|-------|-------|-------|
| gpt-oss-demo-subscription | gpt-demo-users | gpt-oss-20b | 500 tokens/hr |
| gpt-oss-prod-subscription | gpt-prod-users | gpt-oss-20b | 1.5M tokens/hr |
| goose-subscription | goose-users | gpt-oss-20b | 500k tokens/hr |
| ols-subscription | ols-users | gpt-oss-20b | 500k tokens/hr |
| qwen-subscription | qwen-users | qwen3-8b-fp8 | 100k tokens/hr |
