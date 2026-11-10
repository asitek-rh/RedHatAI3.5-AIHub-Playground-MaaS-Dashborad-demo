# Secrets

This directory is in .gitignore — never commit real API keys.

## Steps
1. Copy api-keys.env.template to api-keys.env
2. Generate 5 API keys in RHOAI dashboard (see docs/03-api-key-generation.md)
3. Fill in api-keys.env with the sk-oai-* values
4. Run: bash apply-secrets.sh
