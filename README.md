# Exotel Salesforce MCP Configuration

Ready-to-use Salesforce MCP (Model Context Protocol) configuration for AI coding assistants at Exotel. Clone this repo and start querying Salesforce data using natural language.

## Supported Tools

| Tool | Config File | Auto-detected |
|------|------------|---------------|
| Claude Code | `.mcp.json` | Yes |
| Claude Desktop | `.mcp.json` | Yes |
| OpenAI Codex CLI | `.codex/config.toml` | Yes |
| VS Code (Copilot) | `.vscode/mcp.json` | Yes |
| Cursor | `.mcp.json` | Yes |
| Windsurf | `.mcp.json` | Yes |

## One-Time Setup (All Users)

### 1. Install Prerequisites

```bash
# macOS
brew install node

# Install Salesforce CLI
npm install -g @salesforce/cli
```

### 2. Authenticate to Salesforce

```bash
sf org login web -a ameyo -r https://ameyo.my.salesforce.com
```

This opens a browser window. Sign in with your `@exotel.com` Salesforce credentials.

### 3. Clone This Repo

```bash
git clone https://github.com/shivanand-arch/salesforce-mcp-config.git
cd salesforce-mcp-config
```

### 4. Start Your AI Tool

**Claude Code:**
```bash
claude
```

**OpenAI Codex:**
```bash
# Install Codex (one-time)
npm install -g @openai/codex

# Run
codex
```

**VS Code / Cursor / Windsurf:**
Open this folder in your IDE. The MCP config is auto-detected.

## What You Can Do

Once connected, ask questions in natural language:

- "Show me all open opportunities stuck for more than a month"
- "Who booked the highest MRR this quarter?"
- "How many support tickets are SLA breached?"
- "What's our pipeline by stage?"
- "List all accounts with revenue growth > 20%"
- "Show me leads generated from ChatGPT"

## Salesforce Org Details

- **Org**: Exotel
- **URL**: https://ameyo.my.salesforce.com
- **Toolsets**: orgs, data, metadata, users

## Troubleshooting

### "No Salesforce org found"
Re-authenticate: `sf org login web -a ameyo -r https://ameyo.my.salesforce.com`

### "npx timeout" or slow startup
Install the package globally instead:
```bash
npm install -g @salesforcecli/mcp
```
Then update the MCP config to use the direct path instead of npx.

### "Permission denied" errors
Your Salesforce profile may not have API access or access to specific objects. Contact your Salesforce admin.

## Security

- No credentials are stored in this repo
- Each user authenticates independently via OAuth
- Tokens are stored in your local system keychain
- Data access respects your Salesforce profile permissions
