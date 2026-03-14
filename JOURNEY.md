# Ask Salesforce — The Journey

## From 39 lines of config to a production AI query engine

---

### Day 1 — March 9, 2026: A Config File

**Commit**: `35768be` — *"Add Salesforce MCP configuration for all AI coding assistants"*

The project started as a **39-line CLAUDE.md** and a handful of MCP config files. The entire "codebase" was 6 files, 177 lines. The CLAUDE.md knew about 4 Salesforce objects (Opportunity, Case, Lead, Account) with maybe 15 fields total and 5 SOQL tips.

That was it. No application. No AI. No Apex. Just: "Here's how to connect to our Salesforce org."

```
Files: 6
Lines of code: 177
CLAUDE.md: 39 lines
Apex classes: 0
Custom objects: 0
Tests: 0
```

---

### Day 2 — March 11: The Application

**Commit**: `a5d4845` — *"Ask Salesforce - AI-powered natural language CRM query assistant"*

Two days later, there was a full application. A Lightning Web Component that lets anyone in the company type a question in plain English and get CRM answers back.

The architecture was a 4-layer defense stack:
1. **System prompt** — a 428-line Apex controller with a massive field catalog baked into a string literal
2. **SOQL sanitizer** — 6 auto-fix rules (LIMIT injection, object allowlisting, formula field protection)
3. **Self-correction retry** — if SOQL fails, send the error back to Claude for a fix, up to 2 retries
4. **Session memory** — conversation context passed between turns so follow-ups work

The stress test suite ran 75 questions and hit a **94.7% success rate** on day one. 63 unit tests. Query logging to a custom object for analytics.

```
Files: 107
Lines of code: 91,766
Controller: 428 lines
Test class: 212 lines
Apex classes: 8
Unit tests: 63
Stress test: 75 questions, 94.7% success
```

---

### Day 3 — March 13: Tableau Validation

**Commit**: `a5aeefc` — *"Tableau-validated dashboard mappings + multi-query analytics + new SF objects"*

The prompt was good, but the numbers didn't always match the dashboards. The reason: the dashboard-to-data mappings were reverse-engineered guesses. Some were wrong.

So we extracted **actual metadata from Tableau** — 12 workbooks, 22 data sources, 11,053 fields — via the Tableau Metadata GraphQL API. Seven of the 17 original dashboard mappings had deviations. All corrected.

This phase also added **multi-query analytics**: the LLM can now generate 2-5 SOQL queries per question, executed in parallel, results combined for cross-object metrics (NRR, variance analysis, win rate).

The CLAUDE.md knowledge base grew from 39 lines to **1,006 lines** — a comprehensive field audit of every object, every picklist value, every formula field constraint.

Four new Salesforce objects were discovered that nobody had documented: `Booking_Target__c`, `Accounts_Target__c`, `Program__c`, `Opp_Related_Programs__c`.

```
Controller: 863 lines (+435)
CLAUDE.md: 1,006 lines (+967 from original 39)
New objects discovered: 4
Dashboard mappings corrected: 7/17
Multi-query support: up to 5 parallel SOQL queries
```

---

### Day 4 — March 14: Domain Intelligence + Structured Planner

**Commit**: `97f3b11` — *"Add domain capability matrix (#3) and structured planner (#4)"*

This was the architectural inflection point. Two problems had been identified:

**Problem 1**: Ask SF would happily generate SOQL for data that doesn't live in Salesforce. Account credits? That's in AWS QuickSight. Booking-to-revenue journey? That's a Tableau Prep flow. The system had no concept of "I can't answer that."

**Problem 2**: The entire SOQL generation relied on a single, monolithic ~25KB prompt. Every question — no matter how simple — sent the full 1,454-field catalog to Claude. A "total revenue this year" question doesn't need to know about Case escalation chains or Lead UTM campaigns.

**Solution to Problem 1 — Domain Capability Matrix (#3)**:

A new custom metadata type (`AskSF_Domain__mdt`) with 14 fields that declares, per business domain:
- Is it queryable via SOQL? Or is it external (QuickSight, Tableau Prep)?
- What's the parity level? EXACT match to dashboards, or APPROXIMATE?
- What object does it use? What measures and dimensions are allowed?
- What template message should blocked domains return?

13 domain records created. Non-queryable domains now return a polite redirect ("This data lives in AWS QuickSight...") without ever generating SOQL.

**Solution to Problem 2 — Structured Planner (#4)**:

A revenue-only planner that replaces the 25KB prompt with a ~2KB prompt for the most common query type. Instead of asking Claude to write SOQL, it asks Claude to return a **JSON query plan**:

```json
{
  "domain": "revenue",
  "intent": "aggregate",
  "object": "accounts_revenue__c",
  "measures": [{"fn": "SUM", "field": "Revenue_Booked_Amount__c", "alias": "rev"}],
  "dimensions": ["Cluster__c", "Currency__c"],
  "dateFilter": {"field": "Revenue_Booked_On__c", "start": "2025-04-01", "end": "2026-03-14"},
  "sort": {"field": "rev", "direction": "DESC"},
  "limit": 2000
}
```

Apex then **validates** every field against the domain allowlists and **compiles** the plan to SOQL. No hallucinated fields. No injection. No 50K-row detail queries on a 100K-record table.

The planner returns a 3-state result:
- **SUCCESS** — compiled SOQL, skip the legacy prompt entirely
- **NOT_REVENUE** — classification result (not an error); checks blocked-domain keywords before falling through
- **ERROR** — planner failure, safely falls back to the full prompt path

Feature-flagged via `Use_Structured_Planner__c` checkbox for incremental rollout.

**Eval-driven development**: Before building the planner, we ran a 40-question eval set against the current system to establish a baseline: **33/40 (82.5%)**. The eval exposed the exact failure mode: refuse/redirect scored 1/5 because domain control happened *after* SOQL generation — too late to prevent the wrong query from being built.

```
Controller: 2,048 lines (+1,185)
Test class: 1,124 lines (+912)
Unit tests: 43 (from 63 to 43 in our class — others in separate files)
Domain records: 13
Feature flags: 1
Eval questions: 40 across 7 categories
Baseline accuracy: 82.5%
Custom metadata fields: 14 new (AskSF_Domain__mdt)
```

---

## The Numbers

| Metric | Day 1 | Day 2 | Day 3 | Day 4 |
|--------|-------|-------|-------|-------|
| CLAUDE.md | 39 lines | 39 lines | 1,006 lines | 1,006 lines |
| Controller | — | 428 lines | 863 lines | 2,048 lines |
| Test class | — | 212 lines | 212 lines | 1,124 lines |
| Total files | 6 | 107 | 122 | 155 |
| Total lines | 177 | 91,766 | 96,332 | 132,622 |
| Apex classes | 0 | 8 | 10 | 12 |
| Custom metadata types | 0 | 1 | 1 | 3 |
| Custom metadata records | 0 | 1 | 1 | 15 |
| Unit tests | 0 | 63 | 63 | 43 (class) |
| SF objects documented | 4 | 10 | 14 | 75 |
| Fields cataloged | ~15 | ~200 | ~1,454 | ~1,454 |
| Eval questions | 0 | 75 (stress) | 75 (stress) | 40 (structured) |

## Architecture Evolution

```
Day 1:  Config files → Salesforce org
        (no application)

Day 2:  Question → [25KB prompt] → Claude → SOQL → Execute → Claude → Answer
        (single prompt, single query, no guardrails beyond sanitizer)

Day 3:  Question → [25KB prompt] → Claude → 1-5 SOQL queries → Execute all → Merge → Claude → Answer
        (multi-query, Tableau-validated mappings, REST API for large objects)

Day 4:  Question → [2KB planner] → JSON plan → Validate → Compile SOQL → Execute → Claude → Answer
                 ↘ [not_revenue] → Check blocked domains → Block or fallback to legacy prompt
                 ↘ [error] → Fallback to [25KB prompt] → Claude → SOQL → Execute → Answer
        (domain-aware, structured planner, feature-flagged, eval-driven)
```

## What the Baseline Proved

The 40-question eval wasn't just a test — it was a diagnostic tool that shaped the architecture:

| Category | Baseline Score | What It Told Us |
|----------|---------------|-----------------|
| Simple totals | 5/5 | Prompt path is solid for basic revenue |
| Grouped dimensions | 7/8 | One timeout on large customer ranking |
| Filtered queries | 6/7 | One error, rest clean |
| Date edge cases | 5/5 | FY/quarter logic works reliably |
| Large-object safety | 3/4 | Auto-split works; one timeout |
| Ambiguous phrasings | 5/6 | One misrouted to Opportunity |
| Refuse/redirect | 1/5 | **Structural failure** — domain control too late |

The refuse/redirect score of **1/5** was the finding that justified the planner. It wasn't a prompt quality issue — it was an architectural gap. The system had no way to say "I shouldn't generate SOQL for this question" because classification happened after SOQL was already built.

The structured planner fixes this by moving intent classification **before** SOQL generation.

---

*Built March 9-14, 2026. Five days from a config file to a production AI query engine with domain-aware structured planning, eval-driven development, and feature-flagged rollout.*
