# Optimization Experiment Log — Ask Salesforce
**Target:** Ask Salesforce (SOQL query generation + summarization)
**Editable files:** AiSalesAssistantController.cls (PLANNER_SYSTEM_PROMPT, SOQL_SYSTEM_PROMPT, SUMMARY_SYSTEM_PROMPT), RevenueSemanticRegistry.resource, KpiRegistry.resource
**Metric:** Eval pass rate % (40 questions, 7 categories — higher is better)
**Previous baseline (Mar 14):** 82.5% (33/40) — pre-Universal Account, pre-conversational classifier
**Started:** 2026-03-27

## Category Breakdown
| Category | Questions | Mar 14 Score | Post-Optimization Score | Notes |
|----------|-----------|-------------|------------------------|-------|
| simple_total | 5 | 100% (5/5) | 100% (5/5) | |
| grouped | 8 | 88% (7/8) | 100% (8/8) | REV-11 fixed by deployed code |
| filtered | 7 | 86% (6/7) | 100% (7/7) | REV-17 fixed by deployed code |
| date_edge | 5 | 100% (5/5) | 100% (5/5) | |
| large_object | 4 | 100% (4/4) | 100% (4/4) | |
| ambiguous | 6 | 83% (5/6) | 100% (6/6) | REV-32 fixed by deployed code |
| refuse | 5 | 20% (1/5) | 100% (5/5) | REV-37/39/40 fixed by experiments |

## Fresh Baseline (Mar 27 — post-deployed-code sync)
**Score:** 95% (38/40)
**Failing:** REV-39 (mixed query blocked), REV-40 (NRR timeout)
**Changes since Mar 14:** Universal Account fields, conversational classifier, simplified booking, rogue date filter stripper, SOQL-only data rule

## Experiments

| # | Hypothesis | Change | Score | Delta | Status |
|---|-----------|--------|-------|-------|--------|
| 1 | Mixed queries (revenue + blocked domain) should return revenue data | Revenue signal detection in domain blocker | 39/40 | +1 | KEPT |
| 2 | NRR should use deterministic KPI engine with REST API | PERIOD_RATIO formula type + executeViaRestApi | 39/40 | +1 | KEPT |
| 3 | Refined mixed-intent: domain keywords containing revenue signals should still block | Check if matched keyword contains revenue signal before fallthrough | 40/40 | +1 | KEPT |
| 4 | CRM Buddy alignment: Win Rate denominator, GRR filters, Loss Analysis, NRGP/GRGP | Multiple fixes per CRM Buddy document | 40/40 | 0 (correctness) | KEPT |

### Experiment 1 — Mixed Intent Detection (REV-39)
**Hypothesis:** "Show revenue AND account credits together" was blocked entirely because domain keywords found "credits". Revenue intent should take priority.
**Change:** Added `revenueSignals` set. If question has both revenue AND blocked domain keywords, skip blocking.
**Result:** REV-39 PASS. Revenue data flows through with note about credits.
**Side effect:** REV-37 regressed (booking-to-revenue domain keyword contains "revenue").

### Experiment 2 — NRR KPI Engine (REV-40)
**Hypothesis:** NRR queries timeout because full Claude pipeline + accounts_revenue__c exceeds 50K rows.
**Changes:**
1. Added `PERIOD_RATIO` formula type to KPI engine
2. Added NRR/GRR to KpiRegistry.resource
3. Used `executeViaRestApi` directly (aggregate queries still count underlying rows toward 50K governor limit)
**Result:** REV-40 PASS. 12.3s, 86ms CPU, 46 records. NRR = 134.57% (Q4 FY2025).

### Experiment 3 — Refined Mixed Intent (REV-37 fix)
**Hypothesis:** If a blocked domain keyword itself contains a revenue signal word (e.g., "booking to revenue"), it's NOT mixed intent.
**Change:** Added `kwContainsRevenueSignal` check — only allow fallthrough if the matched keyword doesn't contain the revenue signal.
**Result:** REV-37 now correctly blocks AND REV-39 still passes. 40/40.

### Experiment 4 — CRM Buddy Document Alignment
**Source:** CRM Buddy Document (single source of truth per user instruction)
**Changes made:**
1. **Win Rate**: Removed POC Closed from denominator in KpiRegistry (per CRM Buddy: consumed pipeline = terminal stages only)
2. **GRR**: Added `extraFilters` for Revenue_Classification IN ('Retention 2', 'Retention 3') and `capNumerator: true` (per CRM Buddy: GRR cannot exceed 100%)
3. **Loss Analysis**: Added Opp_Actual_Closure_Date__c as correct date field in SOQL prompt (per CRM Buddy, NOT CloseDate)
4. **NRGP/GRGP**: Added to KpiRegistry (GP retention metrics — higher priority than NRR/GRR per user)
5. **NRR/GRR prompt**: Added rule that only dimensions with revenue in BOTH periods should be included
**Result:** No eval regression. Correctness improvements for Win Rate, GRR, Loss Analysis, and new NRGP/GRGP KPIs.
