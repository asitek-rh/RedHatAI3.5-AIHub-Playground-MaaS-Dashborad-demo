# API Key Generation

Generate 5 API keys in RHOAI dashboard after MaaS subscriptions are created.

## Steps

1. RHOAI Dashboard → Gen AI Studio → API Keys → Create API key
2. Create one key per subscription with these names:

| Key name | Subscription |
|----------|-------------|
| `Gpt-playground-demo-key` | `gpt-oss-demo-subscription` |
| `Gpt-playground-prod-key` | `gpt-oss-prod-subscription` |
| `Goose-key` | `goose-subscription` |
| `OLS-key` | `ols-subscription` |
| `Qwen-key` | `qwen-subscription` |

3. **Copy each `sk-oai-*` token immediately** — it is shown only once
4. Fill in `secrets/api-keys.env`:

```bash
cp secrets/api-keys.env.template secrets/api-keys.env
# Edit the file and paste each key
```

## Important

- If subscriptions are not visible in the dropdown, log out of the dashboard and log back in
- If a key is lost, delete it and generate a new one
