# Red Hat AI 3.5 — Demo Guide

**Cluster**: `https://console-openshift-console.apps.ocp.pvtxr.sandbox3461.opentlc.com`  
**RHOAI version**: 3.5.2 | **OCP**: 4.22.12 | **GPU**: 2× NVIDIA L4 on g6.2xlarge (AWS)

---

## Demo Overview

This demo showcases Red Hat AI 3.5 running on OpenShift, covering:

| # | Scenario | Component | Key Message |
|---|----------|-----------|-------------|
| 1 | Model deployment via MaaS | Models as a Service | Enterprise-grade LLM serving with governance |
| 2 | Subscription quota demo | MaaS + Authorino/Kuadrant | Token-level access control per consumer |
| 3 | Multi-model GenAI Studio | OGX Playground | Side-by-side model comparison with RAG and MCP |
| 4 | AI-assisted cluster admin | OpenShift Lightspeed (OLS) | AI with cluster introspection and tool use |
| 5 | AI coding agent | Goose | External agent using Red Hat AI via MaaS |
| 6 | Cluster MCP server | OpenShift MCP | Governed tool access for AI agents |

---

## Deployed Models

| Model | Endpoint | GPU Node |
|-------|----------|----------|
| `redhataigpt-oss-20b` | `maas.apps.ocp.pvtxr.sandbox3461.opentlc.com/models-as-a-service/redhataigpt-oss-20b` | us-east-2a (L4) |
| `redhataiqwen3-8b-fp8-dynamic` | `maas.apps.ocp.pvtxr.sandbox3461.opentlc.com/models-as-a-service/redhataiqwen3-8b-fp8-dynamic` | us-east-2b (L4) |

---

## Demo 1: Models as a Service (MaaS)

### Key points
- Models are published through a central MaaS gateway with Authorino authentication and Kuadrant rate limiting
- Each consumer (playground, Goose, OLS) has a **dedicated subscription** with its own token quota
- API keys (`sk-oai-*`) are generated in the RHOAI dashboard and scoped to exactly one subscription

### Show
1. **RHOAI Dashboard → Models as a Service** — show deployed models with Ready status
2. **Gen AI Studio → API Keys** — show 5 subscriptions, each with a dedicated API key
3. **Gen AI Studio → API Keys → Subscriptions tab** — show quota limits per subscription

### Subscriptions configured
| Subscription | Consumer | Quota |
|-------------|----------|-------|
| `gpt-oss-demo-subscription` | Playground demo chat | 500 tokens/hr (deliberately small) |
| `gpt-oss-prod-subscription` | Playground prod chat | 1.5M tokens/hr |
| `goose-subscription` | Goose agent | 500k tokens/hr |
| `ols-subscription` | OpenShift Lightspeed | 500k tokens/hr |
| `qwen-subscription` | Qwen playground chat | 100k tokens/hr |

---

## Demo 2: Subscription Quota Demo

### Setup
In the playground, two chats are open side by side. Both use gpt-oss-20b, but through different subscriptions with different token budgets.

### Steps
1. Open **Gen AI Studio → Playground**
2. Open two chat panels (compare mode)
3. Chat 1: model `maas-vllm-inference-1` (gpt-oss-20b, demo subscription — 500 tokens/hr)
4. Chat 2: model `maas-vllm-inference-2` (qwen3-8b-fp8, qwen subscription — 100k tokens/hr)
5. Send multiple questions to Chat 1 to exhaust the 500 token demo quota
6. When the quota is hit, Chat 1 returns an error — Chat 2 continues unaffected

### Key message
> "Same infrastructure, same model, different governance. The platform enforces token budgets per consumer at the gateway level — no application code changes needed."

---

## Demo 3: GenAI Studio Playground

### 3a. Basic chat comparison

1. Open Playground with two models side by side
2. Ask the same question to both models simultaneously
3. Compare responses — note Qwen3 shows thinking steps (reasoning model), gpt-oss-20b responds directly
4. Point out the per-message metrics (TTFT, tokens/sec, total tokens)

### 3b. RAG (Retrieval-Augmented Generation)

**Setup**: Upload a document to the Knowledge tab → RAG enabled

1. Ask a question the model can't answer from training data (post-cutoff information)
2. Without RAG: model answers from training data (may hallucinate or admit uncertainty)
3. Enable RAG and upload a relevant document
4. Ask the same question with "Use RAG" in the prompt
5. Model answers with citation `[1] cited, 1 retrieved` — grounded in the uploaded document

**Key message**: RAG makes models domain-specific without fine-tuning.

**Note**: The prompt must explicitly mention RAG ("Use RAG to answer") or it will fall back to training data.

### 3c. MCP tools in Playground

1. In the MCP tab, enable **OpenShift-MCP-Server**
2. Ask: *"List pods in the models-as-a-service namespace"*
3. Model calls the OCP MCP tool → returns real cluster data
4. Ask follow-up: *"Are there any pods in error state?"*

**Key message**: Models can access live cluster data through governed MCP tool calls.

### 3d. Saved system prompt (RedHatSA)

Load the **RedHatSA** system prompt from the Prompt tab before demoing to give the model appropriate SA context.

---

## Demo 4: OpenShift Lightspeed (OLS)

**Access**: OCP Console → top-right Lightspeed icon (or floating icon bottom-right)

### 4a. Scoped knowledge — off-topic refusal
1. Ask: *"Who is the president of Poland?"*
2. OLS refuses: *"I'm sorry, but I can't help with that."*
3. **Key message**: OLS is intentionally scoped to OCP topics only — it's safe for production use by operators

### 4b. Cluster introspection with tools
1. Click **Troubleshooting** mode (bottom of OLS panel)
2. Ask: *"I have a pod named demo-gpu-pending in models-as-a-service namespace stuck in Pending state. Can you investigate why?"*
3. OLS uses `pods_list_in_namespace` and `events_list` tools → returns real cluster diagnostic data
4. OLS diagnoses: GPU resource constraint, missing taint toleration

### 4c. YAML review
1. In the Troubleshooting section, click **Upload from computer**
2. Upload a YAML file from `docs/` (the broken deployment YAML with 3 intentional errors)
3. Ask: *"Review this Deployment YAML and identify any issues"*
4. OLS identifies: wrong image tag, CPU limits < requests, readiness probe on wrong port

### OLS backend
- Model: `redhataigpt-oss-20b` via MaaS `ols-subscription`
- Configuration: `type: rhoai_vllm`, max iterations: 20, tool inspection disabled

---

## Demo 5: Goose Agent

**Goose** is an open-source AI coding agent connecting to gpt-oss-20b via MaaS.

### Setup verification
```bash
goose session
# Should show: openai redhataigpt-oss-20b
```

### Demo flow
1. Start a Goose session in the terminal
2. Ask Goose to perform an OCP-related task:
   - *"What pods are running in the models-as-a-service namespace?"*
   - *"Show me the subscription quotas configured in the cluster"*
   - *"Check if there are any pods in error state"*
3. Goose uses tool calls to gather information and responds

### Key message
> "Same model, different client. Goose is an external open-source agent using the Red Hat AI MaaS endpoint with the same governance (token quota, API key auth) as the playground and OLS."

---

## Demo 6: OpenShift MCP Server

**What it is**: A Kubernetes-native MCP server that exposes OCP cluster resources as tools to AI agents. Deployed in `models-as-a-service` namespace.

### Configuration
- Image: `registry.redhat.io/openshift-mcp-beta/openshift-mcp-server-rhel9:0.2`
- Mode: `read_only = true` (safe for demos — no write access)
- Toolsets: `core, config`
- Service account: `mcp-viewer` with `view` ClusterRole

### Show in Playground
1. MCP tab → enable OpenShift-MCP-Server
2. The model gains access to live cluster introspection tools
3. Demonstrate real-time cluster data retrieval without leaving the chat interface

### Key message
> "AI agents connect to cluster resources through a governed protocol gateway — authentication, rate limiting, and read-only enforcement are built in."

---

## Observability

### MaaS Dashboard
**RHOAI Dashboard → Gen AI Studio → Subscriptions tab**

Shows per-subscription:
- Total tokens consumed
- Request count
- Error rate
- Rate limit violations

### Model metrics
**OCP Console → Observe → Dashboards → RHOAI model metrics**

Shows per-model:
- P50/P95/P99 latency (time to first token)
- Tokens per second throughput
- GPU utilization

---

## Demo Tips

| Situation | Recommendation |
|-----------|---------------|
| gpt-oss-20b slow to respond | Expected — 20B model on single L4, TTFT 15-30s. Mention it. |
| Qwen thinking visible | Intentional — Qwen3 is a reasoning model, shows chain-of-thought |
| RAG not triggering | Add "Use RAG" explicitly in the prompt |
| MCP tools not visible | Refresh playground, check MCP tab, reconnect |
| Token quota hit | Demo moment — shows governance working. Reset via Limitador if needed. |
| OLS refuses off-topic | Intentional behavior — reinforce it's by design |

---

## Notes for the Demo

- **System prompt**: Load `RedHatSA` from Prompt tab before each demo session
- **Model availability**: Both models must show Ready in RHOAI dashboard before demoing
- **Demo key**: The playground uses the demo subscription (500 tokens/hr) — burn through it slowly for the quota demo, then show it hitting the limit
- **HF downloads**: `HF_HUB_OFFLINE=0` is set — the embedding model for RAG is downloaded automatically on first RAG use (~60s delay on cold start)
