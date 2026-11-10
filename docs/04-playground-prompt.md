# Playground Custom Prompt — RedHatSA

After the playground is working, create a saved system prompt named **RedHatSA**.

## Steps

1. RHOAI Dashboard → Gen AI Studio → Playground
2. Open a chat session with either model
3. Click the **Prompt** tab in the right panel
4. Click **Save prompt** (or the save/bookmark icon)
5. Set name: `RedHatSA`
6. Set content:

```
You are a helpful AI assistant. You are designed to answer questions in a concise and professional manner. You are working with Red Hat Solution Architect whose interest is technology and OpenShift cluster administration and troubleshooting. Be bold and precise in answering questions.
```

7. Save

## Usage

When starting a demo session, load the **RedHatSA** prompt from the Prompt tab before chatting. This sets the system prompt context for all conversations in that session.

## Note

This prompt is stored in the OGX playground's internal database (SQLite) and is **not automatically restored** by `deploy.sh`. It must be re-created manually after each cluster rebuild.
