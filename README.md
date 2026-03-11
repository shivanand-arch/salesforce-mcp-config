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
git clone https://github.com/exotel-website/salesforce-mcp-config.git
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

---

## Ask Salesforce - AI-Powered Query Assistant (LWC)

This repo also contains the **Ask Salesforce** Lightning Web Component — an AI-powered natural language CRM query assistant built directly into Salesforce.

### Architecture

- **Frontend**: `askSalesforce` LWC with chat UI and session memory (10 exchanges)
- **Backend**: `AiSalesAssistantController` with 3-attempt self-correction retry
- **AI Engine**: Claude claude-sonnet-4-6 via `ClaudeApiService`
- **Query Safety**: `SoqlSanitizer` with 6 auto-fix rules and GROUP BY validation
- **Field Catalog**: 1,454+ fields across Opportunity, Case, Account, Lead

### Stress Test Results

75 real-world business questions tested against production data:

| Metric | Result |
|--------|--------|
| Success Rate | **94.7%** (54/57 API-reachable) |
| Retry Recovery | **100%** (17/17 recovered) |
| Unit Tests | **63 passing** (41 sanitizer + 22 other) |
| Avg Response Time | ~21 seconds |

### Key Files

| File | Description |
|------|-------------|
| `AiSalesAssistantController.cls` | Main controller with AI orchestration |
| `SoqlSanitizer.cls` | SOQL validation and 6 auto-fix rules |
| `ClaudeApiService.cls` | Anthropic Claude API integration |
| `StressTestRunner.cls` | 75-question stress test suite |
| `askSalesforce/` (LWC) | Chat UI with markdown rendering |
| `Ask_Salesforce_Report.docx` | Full technical report |

---

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
