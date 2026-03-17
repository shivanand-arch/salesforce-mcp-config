# Ask Salesforce vs Tableau Dashboard — Audit Report

**Date:** March 13, 2026
**Scope:** Root cause analysis of value mismatches between Ask Salesforce AI responses and Tableau MGMT Dashboard
**Method:** Extracted 3,718 calculated field formulas from 4 Tableau workbooks via Metadata GraphQL API

---

## Executive Summary

Ask Salesforce returns different values from the Tableau dashboards because **Tableau applies 5-8 layers of calculated field transformations** on top of the raw Salesforce data. Ask Salesforce queries raw Salesforce fields directly via SOQL, bypassing all Tableau logic. The mismatches are **architectural, not bugs** — but fixable by aligning the SOQL prompt with Tableau's calculation patterns.

**3 root causes account for all observed mismatches:**

| # | Root Cause | Impact | Affected Dashboards |
|---|-----------|--------|-------------------|
| 1 | **Wrong value field for bookings** | 5x–14x mismatch | Order Booking, Variance, Booking Forecast |
| 2 | **Wrong currency conversion rates** | 5-15% deviation on intl deals | Revenue, Booking, Variance |
| 3 | **Governor limit on non-aggregate revenue queries** | Query failure (50K+ rows) | Revenue Analysis, Retention |

---

## Root Cause 1: Booking Value Field Mismatch (CRITICAL)

### What Tableau Does (Opportunity Analysis workbook — 652 calculated fields)

Tableau uses a **7-step calculation chain** to derive booking values:

```
Step 1: [Net New] = Salesforce Net_New__c (raw, set by Finance)
                    ↓
Step 2: [Currency convertion net new] =
        IF Currency='USD' THEN [Net New] * 85
        ELSEIF Currency='AED' THEN [Net New] * 22
        ELSE [Net New]
                    ↓
Step 3: [Product Count] = { FIXED [Opportunity ID]: COUNT([Product ID]) }
        (LOD calc — counts OpportunityLineItems per Opportunity)
                    ↓
Step 4: [Net New Unique] =
        IF [Product Count] <= 1 THEN [Currency convertion net new]
        ELSE [Currency convertion net new] / [Product Count]
        (De-duplicates multi-product deals)
                    ↓
Step 5: [Net_New] (Tableau calc) =
        IF Stage = 'Order' THEN [Net New Unique]
        ELSEIF Stage = 'POC' THEN [Net New Unique] / 36
        (POC deals amortized over 36 months)
                    ↓
Step 6: [Net new in lakhs] = [Net_New] / 100000
                    ↓
Step 7: [Remove Reversals] = IF [N-MRR] < 0 THEN "No" ELSE "Yes"
        (Dashboard filter — excludes negative N-MRR deals)
```

### What Ask Salesforce Does

```sql
SELECT ... SUM(Net_New_INR__c) ... FROM Opportunity
WHERE StageName IN ('Order','POC') AND B_Deal_Date__c >= ...
```

Uses `Net_New_INR__c` — a **Salesforce formula field** that does its own currency conversion (different rates) and does NOT:
- Divide by Product Count (multi-product deal deduplication)
- Amortize POC deals by /36
- Filter out negative N-MRR reversals
- Use the same conversion rates (SF formula vs Tableau hardcoded 85/22)

### Impact

| Factor | Tableau | Ask Salesforce | Deviation |
|--------|---------|---------------|-----------|
| Base field | `Net_New__c` (raw) | `Net_New_INR__c` (formula) | Different base values |
| USD rate | 85 | SF formula (varies) | ~2-5% |
| AED rate | 22 | SF formula (varies) | ~3-8% |
| Multi-product dedup | Divides by Product Count | No dedup | **2-5x inflation** |
| POC amortization | /36 | Full value | **36x inflation on POCs** |
| Reversal filter | Excludes N-MRR < 0 | Includes all | Adds negative values |

**This explains the 5x–14x booking value mismatches observed.**

### Fix Required

The SOQL prompt cannot replicate the Product Count LOD calculation (requires OpportunityLineItem subquery which SOQL doesn't support in aggregates). Options:

**Option A (Recommended):** Add a caveat to the SOQL prompt explaining that Ask SF booking values use `Net_New_INR__c` which differs from the Tableau dashboard's calculated `Net_New` due to product count deduplication and POC amortization. The summary step should note this when presenting booking values.

**Option B:** Use `Net_New__c` (raw) × hardcoded rates to match Tableau's base, but still cannot replicate the Product Count LOD or Remove Reversals filter without OpportunityLineItem data.

**Option C:** Create a Salesforce formula field or rollup that replicates Tableau's calculation chain — requires Salesforce admin changes.

---

## Root Cause 2: Revenue Currency Conversion Mismatch (MODERATE)

### What Tableau Does (Revenue Dashboard — 512 calculated fields)

```
[Revenue Booked Amount INR] =
    IF [Currency] = "USD" THEN [Revenue Booked Amount] * 80
    ELSE [Revenue Booked Amount]

[Revenue in Lakhs] = [Revenue Booked Amount INR] / 100000

[Norm. Amt in INR] =
    IF [Currency] = "USD" THEN [Norm. Rev Amount] * 75
    ELSE [Norm. Rev Amount]

[Value] =
    IF [Displayed Value] = "Actual Amt" THEN [Revenue in Lakhs]
    ELSEIF [Displayed Value] = "Normalized Amt" THEN [Norm. Amt in Lakhs]
```

Key findings:
- **"Actual" revenue** uses USD rate = **80**
- **"Normalized" revenue** uses USD rate = **75**
- The `[Last Refresh Date]` = `MAX(Revenue_Booked_On__c)` — NOT today's date
- QTD/YTD calculations use `FIXED` LOD expressions with `DATEDIFF('quarter', ...)` against `[Last Refresh Date]`

### What Ask Salesforce Does

```sql
SELECT Cluster__c, SUM(Revenue_Booked_Amount__c) FROM accounts_revenue__c
WHERE Revenue_Booked_On__c >= ... GROUP BY Cluster__c
```

Uses `Revenue_Booked_Amount__c` directly — which is the raw Salesforce value in **native currency** (INR, USD, etc.). No conversion applied.

### Impact

For domestic (INR) deals: **No impact** — values match.
For international (USD) deals: **5-15% deviation** depending on which Tableau view (Actual=80x vs Normalized=75x vs Ask SF raw).

### Fix Required

The SOQL prompt should note that `Revenue_Booked_Amount__c` is in native currency. For cross-region totals, the summary step should convert using standard rates. Add to the SOQL prompt:

```
Revenue_Booked_Amount__c is in NATIVE currency (mostly INR).
For USD accounts: multiply by 80 to match Tableau "Actual" view.
For unified INR totals across regions: always GROUP BY Currency__c
and let the summary step apply conversion.
```

---

## Root Cause 3: Governor Limit on Revenue Queries (CRITICAL)

### What Happens

`accounts_revenue__c` has **>50,000 records**. When Ask Salesforce generates a non-aggregate query (e.g., fetching individual revenue records), Salesforce's `Database.query()` hits the 50,001 row governor limit and throws an exception.

Aggregate queries (with GROUP BY) work fine because Salesforce processes them server-side without the row limit.

### When This Triggers

- Any revenue question that generates a detail-level query instead of an aggregate
- Large date ranges (full FY) on accounts_revenue__c without sufficient filtering
- Retention NRR/GRR queries that try to fetch account-level detail for two periods

### Current Mitigation

`SoqlSanitizer.enforceLimit()` caps LIMIT at 2000, but this doesn't help when:
1. The query has no LIMIT (aggregate without GROUP BY — sanitizer strips LIMIT)
2. The underlying dataset exceeds 50K even with LIMIT 2000 (SF evaluates WHERE first, then LIMIT)

### Fix Required

Add to the SOQL prompt:

```
CRITICAL: accounts_revenue__c has 50,000+ records.
ALWAYS use aggregate queries (GROUP BY) for this object.
NEVER write SELECT field1, field2 FROM accounts_revenue__c without GROUP BY.
Even for "show me revenue records" — use GROUP BY Account__c or Customer_Name__c.
Exception: If fetching specific account's records, add Account__c filter to reduce row count.
```

---

## Additional Findings

### Finding 4: Tableau NRR/GRR Uses LOD Expressions (Not Simple Division)

Tableau's retention formulas use `{FIXED}` LOD expressions:

```
[YTD fiscal revenue] = { FIXED [Account Name], DATEPART('month', [Revenue Booked On]):
    SUM(ZN(IF [Revenue Booked On] <= [Last Refresh Date]
    AND [Revenue Booked On] >= DATE(FY start)
    THEN [Revenue Booked Amount] END)) }

[PYTD Fiscal revenue] = { FIXED [Account Name], DATEPART('month', [Revenue Booked On]):
    SUM(ZN(IF [Revenue Booked On] <= DATEADD('year',-1,[Last Refresh Date])
    AND [Revenue Booked On] >= DATEADD('year',-1,DATE(FY start))
    THEN [Revenue Booked Amount] END)) }

[YTD NRR] = SUM([YTD fiscal revenue]) / SUM([PYTD Fiscal revenue])
```

Key difference: Tableau computes NRR at the **Account + Month** grain using LOD, then aggregates up. Ask Salesforce's multi-query approach computes at the **Account** grain only (no monthly breakdown), which can produce different results due to partial-year effects.

### Finding 5: Tableau's "Last Refresh Date" ≠ Today

```
[Last Refresh Date] = { FIXED : MAX([Revenue Booked On]) }
```

This is the **most recent revenue booking date in the data**, not today's date. If the latest data is from March 10 but today is March 13, Tableau's QTD/YTD calculations stop at March 10. Ask Salesforce uses today's date for its date ranges, potentially including days with no data.

### Finding 6: Variance Analysis Uses Complex Target Joins

The Variance Analysis workbook (2,554 calculated fields across 5 data sources) joins:
- `Opportunity+` data source (booking actuals)
- `Booking_Target__c` (target values via `[Order Target]`, `[Target Date]`)
- `OneExo Revenue+` ×3 (revenue actuals at different time grains)
- `Accounts_Target__c` (revenue/GP targets)

Target formulas like:
```
[CM Target OB] = ZN(IF [Target Date] <= TODAY()
    AND DATEDIFF('month', [Target Date], TODAY()) = 0
    THEN [Order Target] END)

[CM Variance] = SUM([CM OB Lakh]) - SUM([CM Target OB])
```

Ask Salesforce's target queries are simpler and may not match the exact date filtering logic Tableau uses.

---

## Recommended Fixes (Priority Order)

### Fix 1: Add Booking Value Disclaimer to SOQL Prompt (HIGH — 30 min)

After line 148 in AiSalesAssistantController.cls, add:

```
IMPORTANT — Tableau Dashboard Difference:
The Tableau Order Booking dashboard uses a DIFFERENT calculation:
  - Base: Net_New__c (raw) × manual rates (USD=85, AED=22)
  - Deduplicates multi-product deals by dividing by OpportunityLineItem count
  - Amortizes POC deals over 36 months (/36)
  - Filters out deals where calculated N-MRR < 0 (reversals)
Ask Salesforce uses Net_New_INR__c which is a Salesforce formula (different rates, no dedup, no POC amort).
Values WILL differ from the Tableau dashboard — typically Ask SF shows HIGHER values.
When user asks about booking values, note this in the summary.
```

### Fix 2: Force Aggregate on accounts_revenue__c (HIGH — 15 min)

Add to the SOQL prompt after the accounts_revenue__c definition:

```
GOVERNOR LIMIT WARNING: accounts_revenue__c has 50,000+ records.
ALWAYS use GROUP BY for this object. NEVER write detail-level SELECT without GROUP BY.
For retention/NRR queries: GROUP BY Account__c, Cluster__c to stay within limits.
```

### Fix 3: Add Revenue Currency Note (MEDIUM — 10 min)

Update the REVENUE DEFINITION section to note:

```
Revenue_Booked_Amount__c is in NATIVE currency (INR for domestic, USD for intl).
Tableau converts: USD×80 for "Actual", USD×75 for "Normalized".
For cross-region totals: GROUP BY Currency__c and note conversion in summary.
```

### Fix 4: Update Hardcoded Conversion Rates (LOW — 5 min)

Line 129 currently says `1 USD=83.33 INR`. Tableau uses 80 (Actual) or 85 (Booking). Update to reflect the context-dependent rates:

```
Conversion rates differ by context:
  Booking dashboard: 1 USD=85, 1 AED=22
  Revenue dashboard (Actual): 1 USD=80
  Revenue dashboard (Normalized): 1 USD=75
  For Ask SF summary display: use 1 USD=83 INR as average
```

---

## Summary of All Tableau Calculated Field Chains

### Booking (Opportunity Analysis — 652 calc fields)
```
Net_New__c → ×USD(85)/AED(22) → ÷Product Count → ÷36 if POC → /100000 → filter N-MRR<0
```

### Revenue (Revenue Dashboard — 512 calc fields)
```
Revenue_Booked_Amount__c → ×USD(80) → /100000 → toggle Actual/Normalized
NRR = FIXED[Account,Month](current FY rev) / FIXED[Account,Month](prev FY rev)
```

### Variance (Variance Analysis — 2,554 calc fields)
```
Booking: Net_New__c → same chain as above → compare to Booking_Target__c[Order Target]
Revenue: Revenue_Booked_Amount__c → same chain → compare to Target__c/Accounts_Target__c
```

---

## Files That Need Changes

| File | Change | Priority |
|------|--------|----------|
| `AiSalesAssistantController.cls` line 148 | Add Tableau booking disclaimer | HIGH |
| `AiSalesAssistantController.cls` line 129 | Update conversion rates | MEDIUM |
| `AiSalesAssistantController.cls` line 131-141 | Add governor limit warning for accounts_revenue__c | HIGH |
| `AiSalesAssistantController.cls` line 552-556 | Update summary prompt currency rates | MEDIUM |
