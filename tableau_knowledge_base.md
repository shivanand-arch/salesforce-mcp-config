# Tableau Dashboard → Salesforce Data Mapping (Complete Knowledge Base)

> **Extracted**: March 2026 via Tableau Metadata GraphQL API
> **Source**: Tableau Cloud (prod-apsoutheast-b.online.tableau.com, site: exotelanalytics)
> **Project**: Exotel Dashboards
> **Total**: 12 workbooks, 11,053 fields across 22 data sources
> **Raw JSON**: /Users/shivanand/Downloads/tableau_complete_metadata.json (424KB)

---

## 1. Salesforce Objects Used Across All Tableau Dashboards

| Salesforce Object | Used In Workbooks | Notes |
|-------------------|-------------------|-------|
| `'Finance Metrics-Tableau$'` | CEO Dashboard |  |
| `'Geo-diversification Tableau$'` | CEO Dashboard |  |
| `'HR Dept-Tableau$'` | CEO Dashboard |  |
| `'Key matrics-Tableau$'` | CEO Dashboard |  |
| `'Penetration-Tableau$'` | CEO Dashboard |  |
| `'Tech Reporting Metrics-Tableau$'` | CEO Dashboard |  |
| `Account` | Booking Forecast Dashboard, Burn Schedule, CEO Dashboard, Key KPIs Dashboard, Lead Analysis Dashboard - BDR, Meetings Dashboard, OB to Rev & GP Journey, Opportunity Analysis, Penetration Index Dashboard, Retention Dashboard, Revenue Dashboard, Variance Analysis | Customer accounts. Cluster__c, Region__c, Sub_Cluster__c |
| `Accounts_Revenue__c` | CEO Dashboard, Meetings Dashboard, Penetration Index Dashboard, Retention Dashboard, Revenue Dashboard, Variance Analysis | Revenue recognition. Revenue_Booked_Amount__c, GP__c, SKU__c |
| `Accounts_Target__c` | Variance Analysis | Revenue/GP targets (Variance Analysis) |
| `Booking_Target__c` | Booking Forecast Dashboard, Variance Analysis | Booking targets (Booking Forecast, Variance) |
| `Campaign` | Booking Forecast Dashboard, CEO Dashboard, Lead Analysis Dashboard - BDR, Opportunity Analysis | Marketing campaigns linked to Opps and Leads |
| `Event` | Meetings Dashboard | Meetings/activities tracking |
| `Extract` | Burn Schedule, OB to Rev & GP Journey, Penetration Index Dashboard | Hyper extract (Tableau internal) |
| `Lead` | CEO Dashboard, Key KPIs Dashboard, Lead Analysis Dashboard - BDR, Opportunity Analysis, Variance Analysis | Lead tracking. Used in pipeline analysis and BDR dashboards |
| `Lead_Backup__c` | Penetration Index Dashboard | Lead backup/history (Penetration Index) |
| `OB_to_Revenue__c` | Burn Schedule, OB to Rev & GP Journey | Order Book to Revenue mapping (Tableau Prep) |
| `Opp_Related_Programs__c` | Booking Forecast Dashboard, CEO Dashboard, Opportunity Analysis | Junction: Opportunity ↔ Program |
| `Opportunity` | Booking Forecast Dashboard, Burn Schedule, CEO Dashboard, Key KPIs Dashboard, Lead Analysis Dashboard - BDR, Meetings Dashboard, OB to Rev & GP Journey, Opportunity Analysis, Retention Dashboard, Revenue Dashboard, Variance Analysis | Primary deal/pipeline object. Net_New_INR__c, B_Deal_Date__c, StageName |
| `OpportunityLineItem` | Booking Forecast Dashboard, CEO Dashboard, Opportunity Analysis, Variance Analysis | Line items on Opportunities |
| `Opportunity_Trend__c` | Booking Forecast Dashboard, Key KPIs Dashboard, Penetration Index Dashboard | Pipeline trending/snapshots over time |
| `Program__c` | CEO Dashboard, Key KPIs Dashboard, Opportunity Analysis | Project/program tracking |
| `User` | Booking Forecast Dashboard, CEO Dashboard, Key KPIs Dashboard, Meetings Dashboard, Opportunity Analysis, Penetration Index Dashboard, Retention Dashboard, Revenue Dashboard, Variance Analysis | Owner/CSM/AD lookup for people fields |
| `inspire1__Project__c` | Burn Schedule, OB to Rev & GP Journey | Managed pkg project object (Burn Schedule) |

---

## 2. Shared Data Sources Across Workbooks

| Base Data Source | Workbooks Using It | Upstream Tables |
|-----------------|-------------------|-----------------|
| **Event+** (579 fields max) | Meetings Dashboard | Account, Accounts_Revenue__c, Event, Opportunity, User |
| **Finance Metrics-Tableau+ (CEO Dashboard)** (106 fields max) | CEO Dashboard | 'Finance Metrics-Tableau$', 'Geo-diversification Tableau$', 'HR Dept-Tableau$', 'Key matrics-Tableau$', 'Penetration-Tableau$', 'Tech Reporting Metrics-Tableau$' |
| **Index - 5 Aug Acc Rev** (254 fields max) | CEO Dashboard, Penetration Index Dashboard, Retention Dashboard | Account, Accounts_Revenue__c, User |
| **Lead+** (416 fields max) | Lead Analysis Dashboard - BDR | Account, Campaign, Lead, Opportunity |
| **OB to Revenue Workflow** (239 fields max) | OB to Rev & GP Journey | Account, OB_to_Revenue__c, Opportunity, inspire1__Project__c |
| **OB_to_Rev_Burn Schedule** (57 fields max) | Burn Schedule, OB to Rev & GP Journey | Account, Extract, OB_to_Revenue__c, Opportunity, inspire1__Project__c |
| **OneExo Revenue+** (875 fields max) | Retention Dashboard, Revenue Dashboard, Variance Analysis | Account, Accounts_Revenue__c, Accounts_Target__c, Opportunity, User |
| **Opportunity+** (934 fields max) | Booking Forecast Dashboard, Key KPIs Dashboard, Opportunity Analysis, Variance Analysis | Account, Booking_Target__c, Campaign, Lead, Opp_Related_Programs__c, Opportunity, OpportunityLineItem, Opportunity_Trend__c, Program__c, User |
| **Opportunity+ Migrated** (730 fields max) | CEO Dashboard | Account, Campaign, Lead, Opp_Related_Programs__c, Opportunity, OpportunityLineItem, Program__c, User |
| **Output - Group 22 july - Trend** (316 fields max) | Penetration Index Dashboard | Account, Accounts_Revenue__c, Extract, Lead_Backup__c, Opportunity_Trend__c, User |

---

## 3. Per-Workbook Detailed Breakdown

### 3.1. Revenue Dashboard

**Sheets**: 171 | **Data Sources**: 1 | **Total Fields**: 443

**Views/Sheets:**
- GP-Graph Analysis 
- Graph type YoY
- Account Analysis YoY GP
- GP-Cluster Analysis QTD
- graph sheet revenue
- cluster QTD NRR SKU
- Revenue Detail QRR Rolling
- Sheet 169
- GP- %YOY Growth 
- NRR ROLLING
- %QoQ Growth  remove internal
- Account Analysis MTD NRR 
- SKU Analysis rev YoY
- YoY Cluster
- Account Analysis (2)
- NRR YTD
- region QTD NRR SKU
- GP-Region Analysis QTD
- NRR ROLLING SKU
- Cluster Analysis D
- Region Analysis QTD
- Region Analysis 
- GP-SKU Analysis
- Graph QoQ
- cluster QRR YoY
- MOM Graph
- QoQ Acc Insights 
- Sheet 167
- MoM GP-Cluster
- YoY GP-Cluster
- cluster QRR Rolling
- Account Analysis QoQ
- Graph Analysis
- cluster QTD NRR
- region QRR Rolling SKU
- GP-Region Analysis 
- %MoM Growth
- Revenue Detail NRR SKU
- QoQ GP Region
- Account Analysis
- Account Analysis QRR Rolling SKU
- GP-SKU Analysis QTD
- sku QRR Rolling
- SKU Analysis
- YoY SKU
- Acc_wise Details
- %QoQ Growth
- region QRR YOY
- SKU Analysis rev
- MoM Clusterr 
- Revenue Detail MoM GP
- sku QRR YoY SKU
- Revenue Detail NRR
- QoQ Cluster
- MoM SKU P
- Revenue Detail QoQ GP
- GP-%QoQ Growth
- YOY Region
- region MTD NRR
- NRR Analysis QRR Rolling
- region QTD NRR 
- GP-Graph Analysis qtd
- Graph type YoY GP
- Account Analysis QTD GP
- Revenue Detail YTD NRR SKU
- QoQ Clusters
- QoQ SKU 
- sku QTD NRR 
- Account Analysis QTD
- GP-Cluster Analysis
- Revenue Details (2)
- Acc_wise Details (2)
- Revenue Detail YoY
- NRR Analysis MTD SKU
- QTD GP
- cluster YTD NRR SKU 
- sku MTD NRR 
- cluster QRR Rolling SKU
- Total GP
- Account Analysis MoM GP
- SKU Analysis QTD
- NRR Analysis YTD
- NRR Analysis MTD 
- QoQ Region 
- Revenue Detail YTD NRR 
- ROLLING HISTORY NRR
- NRR YTD SKU
- QoQ GP Cluster
- cluster YTD NRR 
- sku QRR Rolling SKU
- Cluster Analysis QTD
- Revenue Detail QTD
- GP-%MoM Growth (2)
- region QRR Rolling
- QoQ Trend
- Graph type MoM
- Revenue Detail QOQ
- Revenue Detail QTD NRR 
- Revenue Details
- sku QRR YoY
- QoQ GP Acc Insights
- sku MTD NRR SKU
- MoM SKU
- GP-SKU Analysis (2)
- cluster YTD NRR SKU
- QTD NRR SKU
- %YOY Growth remove internal 
- region YTD NRR SKU
- Account Analysis MoM
- QoQ GP SKU
- LRD
- Revenue Detail QRR Rolling SKU
- NRR QTD SKU
- QoQ GP Trend
- Revenue Detail QRR YoY SKU
- Revenue Detail (2)
- Graph Analysis QTD
- YoY GP-Region
- QoQ History
- GP-Cluster Analysis (2)
- QoQ GP History
- QTD NRR
- QoQ GP-Region
- Cluster Analysis
- region MTD NRR SKU
- Account Analysis QoQ GP
- KPI Total revenue
- MoM GP-Region
- ROLLING HISTORY NRR sku
- cluster YTD NRR
- GP-%MoM Growth 
- region YTD NRR
- GP- %YOY Growth (2)
- NRR Analysis QRR YOY SKU
- MoM GP-SKU
- MoM Region
- sku YTD NRR SKU
- graph sheet GP
- NRR SKU Account Total
- Graph type QoQ GP
- Revenue Detail QTD NRR SKU
- Sheet 168
- Revenue Detail YoY GP
- QoQ SKU
- Revenue Detail QRR YoY
- sku YTD NRR
- %MoM Growth internal remove
- Account Analysis YoY
- QoQ Acc Details
- Acc_wise_GP_Details 
- NRR Analysis QRR Rolling (2)
- %YOY Growth 
- MOM Histroy
- QoQ Region
- QoQ GP-SKU
- cluster QRR YoY SKU
- YoY GP-SKU 
- LRD 
- Sheet 160
- QoQ GP Acc Details
- region QRR YOY SKU
- NRR Account Total
- QoQ SKU QoQ
- QTD revenue
- NRR QTD
- QoQ GP-Cluster
- LRD NRR
- NRR Analysis QRR YOY
- sku QTD NRR SKU
- Revenue Detail MoM
- NRR Analysis YTD SKU

**Data Source: OneExo Revenue+ (ameyo.my.salesforce.com) (local copy)** (443 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (136):
  - % MoM growth 
  - % MoM growth  GP
  - % MoM growth of GP previous year 
  - % MoM growth value
  - % QoQ growth 
  - % QoQ growth  GP
  - % QoQ growth GP N 
  - % QoQ growth N
  - % QoQ growth Null
  - % QoQ growth of GP previous year 
  - % QoQ growth of previous year
  - % YoY growth
  - % YoY growth GP
  - % YoY growth of previous 
  - % YoY growth of previous  GP
  - Calculation28
  - Current Quarter %QTD
  - DIFF MTD/PMTD
  - DIFF MTD/PMTD SKU
  - DIFF PYTD YTD
  - DIFF PYTD YTD SKU
  - DIFF QTD/PQTD
  - DIFF QTD/PQTD SKU
  - Diff Rolling 12 month
  - Diff Rolling 12 month SKU
  - ... and 111 more (see JSON)

**Key Measure Fields** (110):
  - Account
  - Account ID
  - Account Name
  - Account Source
  - Account Status
  - Account Type
  - Account_
  - Account_Status__c (Universal Account)
  - Amount INR-CR
  - CPM Count
  - CY- Last 12 month N SKU Lakh
  - Channels Count
  - Cluster__c (Account)
  - Cohort_Industry__c (Universal Account)
  - Cohort_Size__c (Universal Account)
  - Compliance_InfoSec_Contact__c (Universal Account)
  - Current Month  GP in Previous year
  - Current Quarter value GP N
  - Current-Quarter GP in previous Year 
  - DID Count
  - ... and more (see JSON)

---

### 3.2. Variance Analysis

**Sheets**: 8 | **Data Sources**: 5 | **Total Fields**: 4306

**Views/Sheets:**
- Region QoQ OB
- Region YOY OB
- SKU YoY OB
- SKU QoQ OB
- Cluster QoQ OB
- QoQ Variance 
- Yearly Variance
- Cluster YOY OB

**Data Source: Opportunity+ (ameyo.my.salesforce.com) (2)** (918 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Lead` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (1):
  - `Booking_Target__c`

**Key Calculated/Analytics Fields** (128):
  - % of Total Calc
  - % of Total Calc  view by
  - %MoM  Forecast Pipeline Growth 
  - %MoM  Forecast Pipeline Growth  of PY
  - %MoM  Opportunity Growth
  - %MoM  Opportunity Growth of PY
  - %MoM  Pipeline Growth
  - %MoM  Pipeline Growth of previous year
  - %MoM  Weighted Pipeline Growth
  - %MoM  Weighted Pipeline Growth of PY
  - %QoQ  Forecast Pipeline Growth
  - %QoQ  Forecast Pipeline Growth of PY
  - %QoQ  Opportunity Growth 
  - %QoQ  Opportunity Growth OF PY
  - %QoQ  Pipeline Growth  
  - %QoQ  Pipeline Growth  of previous year
  - %QoQ  Weighted Pipeline Growth 
  - %QoQ  Weighted Pipeline Growth of PY
  - %YOY Opportunity Growth
  - %YOY PY Opportunity Growth 
  - %YOY PY Pipeline Forecast Growth 
  - %YOY PY Pipeline Growth
  - %YOY PY Pipeline Weighted Growth 
  - %YOY Pipeline Forecast Growth 
  - %YOY Pipeline Growth 
  - ... and 103 more (see JSON)

**Key Measure Fields** (163):
  - Account
  - Account AutoID
  - Account Cluster
  - Account Currency
  - Account ID
  - Account Name
  - Account Region
  - Account Status
  - AccountSid
  - AccountType
  - Allow_Customer_to_Resolve__c (Account Created By)
  - Allow_Customer_to_Resolve__c (Account Owned By)
  - Amount
  - Amount ($ K)
  - Available_for_Case_Assignment__c (Account Created By)
  - Available_for_Case_Assignment__c (Account Owned By)
  - Billing_Country__c (Lead)
  - Budget_Amount__c (Lead)
  - Business Year booking
  - CM OB Lakh
  - ... and more (see JSON)

**Data Source: OneExo Revenue+ (ameyo.my.salesforce.com) (local copy) (2)** (718 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Accounts_Target__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (2):
  - `Accounts_Target__c`
  - `Booking_Target__c`

**Key Calculated/Analytics Fields** (340):
  - % MoM growth 
  - % QoQ growth 
  - % QoQ growth of GP previous year 
  - % YoY growth
  - % of Total Calc
  - % of Total Calc (GP)
  - Account Target Month for Tableau
  - Account__c (Accounts Target)
  - Accounts Target Name
  - Accounts_Target__c
  - Amount__c (Accounts Target)
  - Amount__c (Accounts Target) (copy)
  - Booking Net New target
  - Booking Net New target GP
  - Booking Target Name
  - Booking_Target__c
  - CM GP Variance  
  - CM GP Variance %
  - CM Net Variance Rev
  - CM Variance 
  - CM Variance  GP Organic
  - CM Variance %
  - CM Variance GP
  - CM Variance GP Net New
  - CM Variance GP NetNew
  - ... and 315 more (see JSON)

**Key Measure Fields** (319):
  - "Amount INR LAKH"
  - Account AutoID
  - Account Cluster
  - Account ID
  - Account Region
  - Account Source
  - Account Status
  - Account Type
  - Account_
  - Account_AutoID__c (Universal Account)
  - Account_Status__c (Universal Account)
  - Amount INR-CR
  - Amount INR-lakhs
  - Bizkonnect_org_chart_url__c (Universal Account)
  - CM Varinace Net New Rev
  - COGS Amount
  - CPM Count
  - CSAT__c (Universal Account)
  - CY- Last 12 month GP Actual
  - CY- Last 12 month N SKU Lakh
  - ... and more (see JSON)

**Data Source: OneExo Revenue+ (ameyo.my.salesforce.com) (local copy) (2) (2) (copy)** (875 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Accounts_Target__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (2):
  - `Accounts_Target__c`
  - `Booking_Target__c`

**Key Calculated/Analytics Fields** (417):
  - % MoM growth 
  - % MoM growth  GP
  - % MoM growth of GP previous year 
  - % MoM growth of previous year
  - % MoM growth value
  - % QoQ growth 
  - % QoQ growth  GP
  - % QoQ growth of GP previous year 
  - % QoQ growth of previous year
  - % YoY growth
  - % YoY growth GP
  - % YoY growth of previous 
  - % YoY growth of previous  GP
  - % YoY growth variance
  - % of Total Calc
  - % of Total Calc (GP)
  - Account Target Month for Tableau
  - Account__c (Accounts Target)
  - Accounts Target Name
  - Accounts_Target__c
  - Amount__c (Accounts Target)
  - Amount__c (Accounts Target) (copy)
  - Blank PYTD
  - Blank YTD
  - Booking Net New target
  - ... and 392 more (see JSON)

**Key Measure Fields** (327):
  - "Amount INR LAKH"
  - Account AutoID
  - Account Cluster
  - Account ID
  - Account Region
  - Account Source
  - Account Status
  - Account Type
  - Account_
  - Account_AutoID__c (Universal Account)
  - Account_Status__c (Universal Account)
  - Amount INR-CR
  - Amount INR-lakhs
  - Bizkonnect_org_chart_url__c (Universal Account)
  - CM Varinace Net New Rev
  - COGS Amount
  - CPM Count
  - CSAT__c (Universal Account)
  - CY- Last 12 month GP Actual
  - CY- Last 12 month N SKU Lakh
  - ... and more (see JSON)

**Data Source: OneExo Revenue+ (ameyo.my.salesforce.com) (local copy) (2) (2)** (865 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Accounts_Target__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (2):
  - `Accounts_Target__c`
  - `Booking_Target__c`

**Key Calculated/Analytics Fields** (412):
  - % MoM growth 
  - % MoM growth  GP
  - % MoM growth of GP previous year 
  - % MoM growth of previous year
  - % MoM growth value
  - % QoQ growth 
  - % QoQ growth  GP
  - % QoQ growth of GP previous year 
  - % QoQ growth of previous year
  - % YoY growth
  - % YoY growth GP
  - % YoY growth of previous 
  - % YoY growth of previous  GP
  - % YoY growth variance
  - % of Total Calc
  - % of Total Calc (GP)
  - Account Target Month for Tableau
  - Account__c (Accounts Target)
  - Accounts Target Name
  - Accounts_Target__c
  - Amount__c (Accounts Target)
  - Amount__c (Accounts Target) (copy)
  - Blank PYTD
  - Blank YTD
  - Booking Net New target
  - ... and 387 more (see JSON)

**Key Measure Fields** (320):
  - "Amount INR LAKH"
  - Account AutoID
  - Account Cluster
  - Account ID
  - Account Region
  - Account Source
  - Account Status
  - Account Type
  - Account_
  - Account_AutoID__c (Universal Account)
  - Account_Status__c (Universal Account)
  - Amount INR-CR
  - Amount INR-lakhs
  - Bizkonnect_org_chart_url__c (Universal Account)
  - CM Varinace Net New Rev
  - COGS Amount
  - CPM Count
  - CSAT__c (Universal Account)
  - CY- Last 12 month GP Actual
  - CY- Last 12 month N SKU Lakh
  - ... and more (see JSON)

**Data Source: Opportunity+ (ameyo.my.salesforce.com)** (930 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `OpportunityLineItem` (salesforce), `Lead` (salesforce), `Booking_Target__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (1):
  - `Booking_Target__c`

**Key Calculated/Analytics Fields** (134):
  - % of Total Calc
  - % of Total Calc  view by
  - %MoM  Forecast Pipeline Growth 
  - %MoM  Forecast Pipeline Growth  of PY
  - %MoM  Opportunity Growth
  - %MoM  Opportunity Growth of PY
  - %MoM  Pipeline Growth
  - %MoM  Pipeline Growth of previous year
  - %MoM  Weighted Pipeline Growth
  - %MoM  Weighted Pipeline Growth of PY
  - %QoQ  Forecast Pipeline Growth
  - %QoQ  Forecast Pipeline Growth of PY
  - %QoQ  Opportunity Growth 
  - %QoQ  Opportunity Growth OF PY
  - %QoQ  Pipeline Growth  
  - %QoQ  Pipeline Growth  of previous year
  - %QoQ  Weighted Pipeline Growth 
  - %QoQ  Weighted Pipeline Growth of PY
  - %YOY Opportunity Growth
  - %YOY PY Opportunity Growth 
  - %YOY PY Pipeline Forecast Growth 
  - %YOY PY Pipeline Growth
  - %YOY PY Pipeline Weighted Growth 
  - %YOY Pipeline Forecast Growth 
  - %YOY Pipeline Growth 
  - ... and 109 more (see JSON)

**Key Measure Fields** (164):
  - Account
  - Account AutoID
  - Account Cluster
  - Account Currency
  - Account ID
  - Account Name
  - Account Region
  - Account Status
  - AccountSid
  - AccountType
  - Allow_Customer_to_Resolve__c (Account Created By)
  - Allow_Customer_to_Resolve__c (Account Owned By)
  - Amount
  - Amount ($ K)
  - Available_for_Case_Assignment__c (Account Created By)
  - Available_for_Case_Assignment__c (Account Owned By)
  - Billing_Country__c (Lead)
  - Budget_Amount__c (Lead)
  - Business Year booking
  - CM OB Lakh
  - ... and more (see JSON)

---

### 3.3. Opportunity Analysis

**Sheets**: 134 | **Data Sources**: 1 | **Total Fields**: 934

**Views/Sheets:**
- Loss SKU Lack of Value Proposition
-  opp Graph Type YOY
- Opportunity Cluster Analysis QTD
- Loss Product Fit & Features
- Total Booking (2)
- %YOY Pipeline
- Loss R Lack of Value Proposition
- Total Booking
- Debook Cluster
- Loss SKU Relationship
- Loss Other Factors
- Loss Details Lack of Value Proposition
- Account details of Pipeline (4)
- Opportunity Cluster Analysis MOM
- Accoount Detail (4)
- Loss Details
- detail Opportunity
- Loss Reason Internal Customer
- Pipeline Cluster Analysis MOM
- Accoount Detail
- detail Opportunity (4)
- OPP Graph Type MoM
- Opportunity Region Analysis YoY
- Pipeline SKU Analysis YOY 
- Loss Reason Loss Theme Execution
- Pipeline Cluster Analysis YOY
- Loss Cluster Lack of Value Proposition
- Loss Total
- %QoQ Pipeline
- Loss Historical Product Fit & Features
- Account details of Opportunity (3)
- Pipeline Historical analysis MoM
- Order Booking Details
- Pipeline Cluster Analysis QoQ
- Loss SKU
- Account details of Pipeline (3)
- Total pipline (2)
- Loss Historical
- Loss Cluster
- Opportunity Region Analysis QoQ
- Loss R Relationship
- Loss Details Loss Theme Execution
- Pipeline SKU Analysis QTD
- Pipeline Region Analysis MOM
- %MoM Pipeline
- Accoount Detail (5)
- Opportunity Region Analysis QTD
- Accoount Detail (2)
- Loss Details Relationship
- Pipeline Cluster Analysis QTD
- Loss Execution
- Pipeline Cluster Analysis 
- Loss Details Loss Theme Pricing
- Account details of Opportunity (4)
- Opportunity Cluster Analysis QoQ
- %QoQ Opportunity
- Opportunity SKU Analysis QoQ
- Loss R Internal Customer
- Pipeline SKU Analysis MoM
- Opportunity SKU Analysis 
- Loss Reason Loss Theme Pricing
- Pipeline Region Analysis 
- Loss Reason Lack of Value Proposition
- Historical analysis QTD
- Loss Relationship
- Loss Historical Loss Theme Pricing
- Account details of Opportunity
- Loss Reason
- Pipeline Historical analysis QoQ
- Opportunity SKU Analysis MoM
- Debook SKU
- Account details of Pipeline (2)
- Loss Cluster Relationship
- Loss SKU Loss Theme Pricing
- Opportunity SKU Analysis (QTD
- Loss Cluster Loss Theme Pricing
- Loss SKU  Loss Theme other fac
- Loss Pricing
- QTD % growth
- Opportunity Region Analysis MoM
- Loss Reason Relationship
- Loss Details Internal Customer
- Pipeline Region Analysis QOQ
- Pipeline Historical analysis (2)
- Pipeline SKU Analysis QoQ
- De-book Details
- Loss Reason Loss Theme other fac
- Opportunity Region Analysis 
- Opp Graph Type QOQ
- Total pipline (3)
- Loss R Loss Theme Execution
- De-Booking
- Loss R
- Loss Cluster Product Fit & Features
- Total pipline
- Opportunity Cluster Analysis 
- Loss Historical Loss Theme other fac
- %MoM Opportunity 
- Pipeline Region Analysis QTD
- QTD % growth Pipeline
- Loss R Loss Theme Pricing
- Debook Region
- Pipeline Region Analysis YOY
- Sheet 134
- Loss SKU Product Fit & Features
- Account details of Pipeline (5)
- Pipeline Details
- Pipeline SKU Analysis 
- %YOY Opportunity
- Loss Cluster Internal Customer
- Loss Cluster Loss Theme other fac
- Loss Cluster Loss Theme Execution
- Loss Historical Lack of Value Proposition
- Loss Historical Relationship
- Loss Details Product Fit & Features
- Loss SKU Loss Theme Execution
- Opportunity SKU Analysis YoY
- Loss Historical Loss Theme Execution
- Pipeline Historical analysis yoy
- Account details of Opportunity QTD
- Loss Historical Internal Customer
- Loss R Loss Theme other fac
- Account details of Opportunity (2)
- Loss Details Loss Theme other fac
- detail Opportunity QTD
- OPP Historical analysis (2)
- Loss Reason Product Fit & Features
- Loss Product
- detail Opportunity (3)
- Loss Internal F
- Loss SKU Internal Customer
- Opportunity Cluster Analysis YOY
- Pipeline Historical Analysis
- Loss Value Proposition

**Data Source: Opportunity+ (ameyo.my.salesforce.com)** (934 fields)
- Extracts: Yes
- Upstream Tables: `Opp_Related_Programs__c` (salesforce), `Program__c` (salesforce), `User` (?), `Account` (salesforce), `OpportunityLineItem` (salesforce), `Lead` (salesforce), `Campaign` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (115):
  - % of Total Calc
  - % of Total Calc  view by
  - %MoM  Forecast Pipeline Growth 
  - %MoM  Forecast Pipeline Growth  of PY
  - %MoM  Opportunity Growth
  - %MoM  Opportunity Growth of PY
  - %MoM  Pipeline Growth
  - %MoM  Pipeline Growth of previous year
  - %MoM  Weighted Pipeline Growth
  - %MoM  Weighted Pipeline Growth of PY
  - %QoQ  Forecast Pipeline Growth
  - %QoQ  Forecast Pipeline Growth of PY
  - %QoQ  Opportunity Growth 
  - %QoQ  Opportunity Growth OF PY
  - %QoQ  Pipeline Growth  
  - %QoQ  Pipeline Growth  of previous year
  - %QoQ  Weighted Pipeline Growth 
  - %QoQ  Weighted Pipeline Growth of PY
  - %YOY Opportunity Growth
  - %YOY PY Opportunity Growth 
  - %YOY PY Pipeline Forecast Growth 
  - %YOY PY Pipeline Growth
  - %YOY PY Pipeline Weighted Growth 
  - %YOY Pipeline Forecast Growth 
  - %YOY Pipeline Growth 
  - ... and 90 more (see JSON)

**Key Measure Fields** (152):
  - Account
  - Account AutoID
  - Account Cluster
  - Account Currency
  - Account ID
  - Account Name
  - Account Region
  - Account Status
  - AccountSid
  - AccountType
  - Allow_Customer_to_Resolve__c (Account Created By)
  - Allow_Customer_to_Resolve__c (Account Owned By)
  - Amount
  - Amount ($ K)
  - Available_for_Case_Assignment__c (Account Created By)
  - Available_for_Case_Assignment__c (Account Owned By)
  - Billing_Country__c (Lead)
  - Budget_Amount__c (Lead)
  - Business Year booking
  - CPM Count
  - ... and more (see JSON)

---

### 3.4. Booking Forecast Dashboard

**Sheets**: 15 | **Data Sources**: 1 | **Total Fields**: 237

**Views/Sheets:**
- Cluster Q
- Account Q
- Region Q
- YTD
- MTD
- Region M
- SKU Q
- Cluster Y
- Region Y
- Cluster M
- QTD
- Account Y (2)
- SKU Y
- Account M
- SKU M

**Data Source: Opportunity+ (ameyo.my.salesforce.com)** (237 fields)
- Extracts: Yes
- Upstream Tables: `Opp_Related_Programs__c` (salesforce), `User` (?), `Account` (salesforce), `OpportunityLineItem` (salesforce), `Campaign` (salesforce), `Opportunity_Trend__c` (salesforce), `Booking_Target__c` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (39):
  - Calculation2
  - Cluster__c (Booking Target)
  - GP Growth
  - Id (Booking Target)
  - MTD Actual + Forecast 
  - MTD Actual + Forecast - Null
  - MTD Actual Net New
  - MTD Booking Target
  - MTD Forecast in Lakhs
  - MTD Target Achieved %
  - MTD Target Forecast Achieved % 
  - QTD Actual + Forecast
  - QTD Actual + Forecast - Null
  - QTD Actual Net New
  - QTD Booking Target 
  - QTD Forecast in Lakhs
  - QTD ORDER lakhs
  - QTD Target Achieved %
  - QTD Target Forecast Achieved %
  - QTD net new
  - Region__c (Booking Target)
  - Revenue Growth
  - SKU__c (Booking Target)
  - Target Date
  - Target Type
  - ... and 14 more (see JSON)

**Key Measure Fields** (67):
  - Account AutoID
  - Account Cluster
  - Account Engagement Api Key
  - Account Engagement Api Version
  - Account Engagement User Id
  - Account Engagement User Key
  - Account Engagement User Role
  - Account LongID
  - Account Name
  - Account Region
  - Account Region Cal
  - Account Status
  - Account name (CPU)
  - Business Year booking
  - CPM Count
  - Channels Count
  - Classfication Type Net New
  - Committed Booking Value
  - Country__c (Account)
  - DID Count
  - ... and more (see JSON)

---

### 3.5. OB to Rev & GP Journey

**Sheets**: 28 | **Data Sources**: 2 | **Total Fields**: 296

**Views/Sheets:**
- Cluster View FY 2025
- SKU Keyhole 
- Revenue PYTD
- CM PYTD
- Sheet 24
- Region View FY 2024
- Sheet Quarter
- Account View
- SKU View
- Booking To Rev PYTD
- Detail-25
- SKU View FY 2025
- OverAll (2)
- Cluster Keyhole
- OverAll
- OverAll (5)
- Region View 2025
- Historical view 2025 Q
- Historical view 2026 Q
- Historical view 2026 FY
- Cluster View
- Sheet 9 FY 26 (2)
- Region Keyhole 
- Sheet 9 FY 25
- Detail-25 (2)
- Historical view 2025 FY
- OverAll (4)
- OverAll (3)

**Data Source: OB to Revenue Workflow | Project : Tableau Prep Flow Output** (239 fields)
- Extracts: No
- Upstream Tables: `Account` (salesforce), `OB_to_Revenue__c` (salesforce), `inspire1__Project__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (55):
  - `Classification_Type__c`
  - `Cluster__c`
  - `Commit_Status__c`
  - `Deal_Category__c`
  - `GP_April_2024__c`
  - `GP_April_2025__c`
  - `GP_Aug_2025__c`
  - `GP_August_2024__c`
  - `GP_Dec_2025__c`
  - `GP_December_2024__c`
  - `GP_Feb_2026__c`
  - `GP_February_2025__c`
  - `GP_Jan_2026__c`
  - `GP_January_2025__c`
  - `GP_July_2024__c`
  - `GP_July_2025__c`
  - `GP_June_2024__c`
  - `GP_June_2025__c`
  - `GP_Mar_2026__c`
  - `GP_March_2025__c`
  - `GP_May_2024__c`
  - `GP_May_2025__c`
  - `GP_Nov_2025__c`
  - `GP_November_2024__c`
  - `GP_Oct_2025__c`
  - `GP_October_2024__c`
  - `GP_Sept_2025__c`
  - `GP_September_2024__c`
  - `Net_New_INR__c`
  - `Region__c`
  - ... and 25 more (see JSON)

**Key Calculated/Analytics Fields** (10):
  - Booking to GP %
  - Booking to Revenue %
  - Booking to Revenue % PYTD
  - GP PYTD
  - GP YTD
  - Logo NET_NEW PYTD
  - PYTD Net New
  - Revenue PYTD
  - Revenue YTD
  - YTD Net New

**Key Measure Fields** (122):
  -  GP April 2025
  -  GP Aug 2025
  -  GP Dec 2025
  -  GP July 2025
  -  GP June 2025
  -  GP May 2025
  -  GP Nov 2025
  -  GP Oct 2025
  -  GP Sept 2025
  - Account_id
  - Account_name
  - De-Booking (copy)
  - GP April
  - GP April 2024
  - GP Aug
  - GP Aug 2024
  - GP Aug 2025
  - GP Dec
  - GP Dec 2024
  - GP Dec 2025
  - ... and more (see JSON)

**Data Source: OB_to_Rev_Burn Schedule | Project : Tableau Prep Flow Output** (57 fields)
- Extracts: No
- Upstream Tables: `Extract` (hyper), `Account` (salesforce), `OB_to_Revenue__c` (salesforce), `inspire1__Project__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (14):
  - `Account__c`
  - `CRM_Project_ID__c`
  - `Classification_Type__c`
  - `Cluster__c`
  - `Commit_Status__c`
  - `Deal_Category__c`
  - `Net_New_INR__c`
  - `Opportunity__c`
  - `Project__c`
  - `Region__c`
  - `Revenue_Type__c`
  - `Reversal_Amount__c`
  - `Status__c`
  - `Usecase_by_SDR__c`

**Key Calculated/Analytics Fields** (1):
  - BURN%

**Key Measure Fields** (12):
  - Account__c
  - Account_id
  - Account_name
  - Booking
  - GP c
  - Max Rev
  - Net_New_INR__c
  - Order Booking
  - Revenue
  - Revenue c
  - Revenue_Type__c
  - Reversal_Amount__c

---

### 3.6. Burn Schedule

**Sheets**: 9 | **Data Sources**: 1 | **Total Fields**: 57

**Views/Sheets:**
- Account View
- Region Keyhole 
- Region OB-Rev_GP
- SKU Keyhole 
- Cluster Keyhole
- Cluster OB-Rev_GP
- Account_detail
- SKU OB-Rev_GP
- Historical OB-Rev_GP

**Data Source: OB_to_Rev_Burn Schedule | Project : Tableau Prep Flow Output** (57 fields)
- Extracts: No
- Upstream Tables: `Extract` (hyper), `Account` (salesforce), `OB_to_Revenue__c` (salesforce), `inspire1__Project__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (14):
  - `Account__c`
  - `CRM_Project_ID__c`
  - `Classification_Type__c`
  - `Cluster__c`
  - `Commit_Status__c`
  - `Deal_Category__c`
  - `Net_New_INR__c`
  - `Opportunity__c`
  - `Project__c`
  - `Region__c`
  - `Revenue_Type__c`
  - `Reversal_Amount__c`
  - `Status__c`
  - `Usecase_by_SDR__c`

**Key Calculated/Analytics Fields** (1):
  - BURN%

**Key Measure Fields** (12):
  - Account__c
  - Account_id
  - Account_name
  - Booking
  - GP c
  - Max Rev
  - Net_New_INR__c
  - Order Booking
  - Revenue
  - Revenue c
  - Revenue_Type__c
  - Reversal_Amount__c

---

### 3.7. CEO Dashboard

**Sheets**: 77 | **Data Sources**: 3 | **Total Fields**: 953

**Views/Sheets:**
- QoQ GP Growth D
- Key Attrition
- Net Cash Details
- SAL - IB
- Revenue
- Operating D
- Operating Leverage
- Base month GR
- Revenue Per Cl
- Audit C
- Payable Days
- Sales Cycle
- QoQ GP Growth
- AI Con D
- Ecc Voice Con
- ACI Total
- Area Chart (2)
- Expand Adoption
- GP
- Account Distribution by Category
- Overall Attrition D
- GP Split
- Rev per Cloud Conversation
- ACI
- Attrition
- Key Attrition D
- Cash Details
- GP Per FTE
- Operating Details
- Rec Days
- PPI
- GPGR
- GP per FTE D
- MCC
- Payable D
- GRGP
- AOP Target
- Cost Per D
- Expand Product
- Glassdoor
- Total Conv
- API
- Total Acc (2)
- AOP
- Rule of 32.5
- Conversion
- Audit Closure
- Demand F
- DSO Details
- Operating P
- ACI (2)
- Win Rate
- GPI (2)
- Operating Profit Details
- DSO
- Onboarding
- NRGP
- Base month
- Total Co D
- GPI
- AI Con
- GPNR
- SLO D
- API (2)
- SLO
- R of 32.5
- Onboarding D
- Area Chart
- Total Acc
- PPI HM
- Net Cashflow
- Cash
- ECC Voice D
- Expand Adoption (3)
- Cost per cloud
- Operating Le
- Glassdoor Rating

**Data Source: Finance Metrics-Tableau+ (CEO Dashboard)** (106 fields)
- Extracts: Yes
- Upstream Tables: `'Geo-diversification Tableau$'` (cloudfile:googledrive-excel-direct), `'Penetration-Tableau$'` (cloudfile:googledrive-excel-direct), `'Tech Reporting Metrics-Tableau$'` (cloudfile:googledrive-excel-direct), `'HR Dept-Tableau$'` (cloudfile:googledrive-excel-direct), `'Key matrics-Tableau$'` (cloudfile:googledrive-excel-direct), `'Finance Metrics-Tableau$'` (cloudfile:googledrive-excel-direct)

**Key Calculated/Analytics Fields** (18):
  - ACI Target
  - API Target
  - Calculation1
  - Fy25 Ebitda %
  - GPI Target
  - Key Employee Exit %
  - QoQ GP Growth
  - QoQ GP Growth max
  - Subscription (YTD) - AOP
  - Subscription (YTD) - Actuals
  - Targets
  - This ACI %
  - This API %
  - This GPI % 
  - This target
  - Total (YTD) - AOP
  - Total (YTD) - Actuals
  - YTD Growth

**Key Measure Fields** (34):
  - AI conver max
  - Attrition Max 
  - Audit Closure Max
  - Cash Max
  - Cost per cloud max
  - DSO Max
  - ECC Voice Conversati max
  - Employee Headcount
  - Exit Max
  - Expand account total
  - Finance - Max Month
  - GP FTE Max
  - GP per FTE (INR Lakhs)
  - Glassdoor Max  
  - Induction Exp Max
  - Max Date - Finance
  - Max Date - Finance (copy)
  - Max Date - HR
  - Max Month - Tech
  - Net Cashflow Max
  - ... and more (see JSON)

**Data Source: Index - 5 Aug Acc Rev** (117 fields)
- Extracts: No
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce)

**Salesforce API Fields** (26):
  - `Account Cluster__c`
  - `Account Region__c`
  - `Customer_Universal_Account__c`
  - `Fixed_Cost__c`
  - `GP__c`
  - `Group_Account__c`
  - `ISQL_Accepted_Date__c`
  - `Norm_Rev_Amount__c`
  - `Product_Type__c`
  - `Products__c`
  - `Project__c`
  - `Rev Classification__c`
  - `Rev Cluster__c`
  - `Rev Customer_Name__c`
  - `Rev Parent_SKU__c`
  - `Rev Region__c`
  - `Rev_Source__c`
  - `Rev_Sub_Source__c`
  - `Revenue_Booked_Amount__c`
  - `Revenue_Booked_Month_for_Tableau__c`
  - `Revenue_Booked_On__c`
  - `Revenue_Classification__c`
  - `SKU__c`
  - `Total_Cost__c`
  - `Universal_Account__c`
  - `Variable_Cost__c`

**Key Calculated/Analytics Fields** (12):
  - Calculation1
  - Calculation2
  - Calculation3
  - Calculation4
  - GPGR Rolling 3 Months 
  - GPGR Rolling 3 Months  -2
  - GPGR Rolling 3 Months  -3
  - GPGR Rolling 3 Months -1
  - GPNR Rolling 3 Months
  - GPNR Rolling 3 Months -1
  - GPNR Rolling 3 Months -2
  - GPNR Rolling 3 Months -3

**Key Measure Fields** (41):
  - Account AD Id
  - Account CSM ID
  - Account Cluster__c
  - Account Name M
  - Account Region__c
  - Account Type Cal
  - Account_Id Main
  - Customer_Universal_Account__c
  - GP * 12
  - GP Accounts Cal
  - GP Last 0 - 12 Months (Logo SKU) 
  - GP Last 0 - 12 Months (Logo SKU) -1
  - GP Last 0 - 12 Months (Logo SKU) -2
  - GP Last 0 - 12 Months (Logo SKU) -3
  - GP Last 12 - 24 Months (Logo SKU)
  - GP Last 12 - 24 Months (Logo SKU) -1
  - GP Last 12 - 24 Months (Logo SKU) -2
  - GP Last 12 - 24 Months (Logo SKU) -3
  - Group_Account__c
  - Max - Revenue Booked on
  - ... and more (see JSON)

**Data Source: Opportunity+ Migrated** (730 fields)
- Extracts: No
- Upstream Tables: `Opp_Related_Programs__c` (salesforce), `Program__c` (salesforce), `User` (?), `Account` (salesforce), `OpportunityLineItem` (salesforce), `Lead` (salesforce), `Campaign` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (20):
  - Expected Response (%)
  - GP Growth
  - MTD Closed - date 
  - MTD Closed - date  B deal
  - QTD B deal date
  - QTD Closed - date 
  - Revenue Growth
  - Win % Denominater (Closed + order)
  - Win % Value Denominator 
  - Win %age
  - Win% Age by Count
  - Win% Age by Count STR
  - Win%age by value
  - Win%age by value New
  - Win%age by value New STR
  - YTD - Closed Date
  - YTD B deal date
  - YTD B deal date (copy)
  - YTD ORDER Date
  - YTD True - Accepted Date

**Key Measure Fields** (142):
  - Account
  - Account AutoID
  - Account Cluster
  - Account Currency
  - Account ID
  - Account Name
  - Account Owner
  - Account Region
  - AccountSid
  - AccountType
  - Allow_Customer_to_Resolve__c (Account Created By)
  - Allow_Customer_to_Resolve__c (Account Owned By)
  - Amount
  - Amount ($ K)
  - Available_for_Case_Assignment__c (Account Created By)
  - Available_for_Case_Assignment__c (Account Owned By)
  - Billing_Country__c (Lead)
  - Budget_Amount__c (Lead)
  - Business Year booking
  - CPM Count
  - ... and more (see JSON)

---

### 3.8. Key KPIs Dashboard

**Sheets**: 0 | **Data Sources**: 2 | **Total Fields**: 1579

**Data Source: Opportunity+ (ameyo.my.salesforce.com)** (723 fields)
- Extracts: Yes
- Upstream Tables: `Program__c` (salesforce), `User` (?), `Account` (salesforce), `Lead` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (18):
  - Expected Response (%)
  - GP Growth
  - MTD Closed - date 
  - QTD B deal date
  - QTD Closed - date 
  - Revenue Growth
  - Win % Denominater (Closed + order)
  - Win % Value Denominator 
  - Win %age
  - Win% Age by Count
  - Win% Age by Count STR
  - Win%age by value
  - Win%age by value New
  - Win%age by value New STR
  - YTD - Closed Date
  - YTD B deal date
  - YTD ORDER Date
  - YTD True - Accepted Date

**Key Measure Fields** (143):
  - Account
  - Account AutoID
  - Account Cluster
  - Account Currency
  - Account ID
  - Account Name
  - Account Owner
  - Account Region
  - Account Status
  - AccountSid
  - AccountType
  - Allow_Customer_to_Resolve__c (Account Created By)
  - Allow_Customer_to_Resolve__c (Account Owned By)
  - Amount
  - Amount ($ K)
  - Available_for_Case_Assignment__c (Account Created By)
  - Available_for_Case_Assignment__c (Account Owned By)
  - Billing_Country__c (Lead)
  - Budget_Amount__c (Lead)
  - Business Year booking
  - ... and more (see JSON)

**Data Source: Opportunity+ (ameyo.my.salesforce.com) (copy)** (856 fields)
- Extracts: Yes
- Upstream Tables: `Program__c` (salesforce), `User` (?), `Account` (salesforce), `Lead` (salesforce), `Opportunity_Trend__c` (salesforce), `Opportunity` (?)

**Salesforce API Fields** (1):
  - `Opportunity_Trend__c`

**Key Calculated/Analytics Fields** (36):
  - Conversion Rate - Amount  MTD
  - Conversion Rate - Amount  YTD or QTD
  - Conversion Rate MTD - Count 
  - Conversion Rate MTD Cal
  - Conversion Rate QTD - Count
  - Count MTD - Converted Opportunity 
  - Count QTD - Converted Opportunity
  - Expected Response (%)
  - GP Growth
  - PQTD ORDER CR lakh
  - PQTD ORDER Date
  - PQTD ORDER Lakh
  - PQTD Pipeline  CR 
  - PQTD Pipeline  Date
  - PYTD
  - PYTD ORDER CR  Lakh
  - PYTD ORDER date
  - PYTD pipeline CR 
  - PYTD pipeline date
  - QTD Historical Null
  - QTD ORDER CR Lakh
  - QTD ORDER Date
  - QTD ORDER Date (copy)
  - QTD ORDER lakhs
  - QTD Pipeline CR
  - ... and 11 more (see JSON)

**Key Measure Fields** (170):
  - Account
  - Account AutoID
  - Account Cluster
  - Account Currency
  - Account ID
  - Account LongID
  - Account Name
  - Account Owner
  - Account Region
  - Account Status
  - AccountSid
  - AccountType
  - Account__c (Opportunity Trend)
  - Allow_Customer_to_Resolve__c (Account Created By)
  - Allow_Customer_to_Resolve__c (Account Owned By)
  - Amount
  - Amount ($ K)
  - Available_for_Case_Assignment__c (Account Created By)
  - Available_for_Case_Assignment__c (Account Owned By)
  - Billing_Country__c (Lead)
  - ... and more (see JSON)

---

### 3.9. Lead Analysis Dashboard - BDR

**Sheets**: 23 | **Data Sources**: 1 | **Total Fields**: 416

**Views/Sheets:**
- Forecast Cat M
- Forecast Cat Q
- Sheet 23
- Cluster Y
- Historical M
- Account Y
- Cluster Q
- Account M
- Region Leads Y
- QTD
- Historical Q
- Region Leads Q
- SKU M
- Cluster M
- Historical Y
- SKU Q
- Account Q
- Region Leads M
- YTD
- Forecast Cat Y
- MTD 
- ClusterD Y
- SKU Y

**Data Source: Lead+ (ameyo.my.salesforce.com)** (416 fields)
- Extracts: Yes
- Upstream Tables: `Account` (salesforce), `Lead` (salesforce), `Campaign` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (32):
  - CM MTD Leads 
  - Calculation9
  - Cluster calculation
  - GP Growth
  - MTD Down Growth
  - MTD Growth 
  - MTD Growth Param
  - MTD Lead Parameter Cal
  - MTD PY Lead Parameter Cal
  - MTD Up Growth
  - PY CM MTD Leads  
  - PY QTD Leads
  - PY YTD Leads
  - Prefix Label MTD
  - Prefix Label QTD
  - Prefix Label YTD
  - QTD Down Growth
  - QTD Growth
  - QTD Growth Param
  - QTD Lead Param Cal
  - QTD Leads
  - QTD PY Lead Param cal
  - QTD Up Growth
  - Revenue Growth
  - YTD Down Growth
  - ... and 7 more (see JSON)

**Key Measure Fields** (39):
  - Account AutoID
  - Account Name
  - Account Status
  - AccountSid
  - AccountSid__c (Lead)
  - AccountType
  - AccountType__c (Lead)
  - Account_Name__c (Lead)
  - Amount__c (Lead)
  - AnnualRevenue (Lead)
  - Billing_Country__c (Lead)
  - Billing_Country__c (Leads)
  - Budget_Amount__c (Lead)
  - CPM Count
  - Channels Count
  - Cluster__c (Account)
  - Committed Booking Value
  - ConvertedAccountId (Lead)
  - Country (Lead)
  - DID Count
  - ... and more (see JSON)

---

### 3.10. Meetings Dashboard

**Sheets**: 57 | **Data Sources**: 1 | **Total Fields**: 579

**Views/Sheets:**
- Owner Count All
- M Category 
- Y Status
- Q Cluster
- Q No Out
- Q Good M
- Y Productive Meet
- Q Owner Count
- Q Productive Meet
- M Status
- Meeting Type All
- Region Y
- Y Cluster
- Cluster All
- YTD
- Details MTD
- Opp Meetings All
- Q Category
- MTD Analysis
- Q Status
- M No Out
- MTD
- M Cluster
- M Opp Meetings
- Region M
- M Cluster Tool
- Status All
- M Meeting Type
- All Productive Meet
- YTD Analysis
- Details YTD
- All No Out
- Y No Out
- Region Q
- Good M All
- Meeting Guide link
- M Productive Meet
- Details All
- M SKU
- Y Good M
- Y SKU
- Details QTD
- Q Opp Meetings
- All time
- QTD
- M Owner Count
- Y Category
- Y Opp Meetings
- QTD Analysis
- Region All
- Y Owner Count
- Category All
- Y Meeting Type
- Q Meeting Type 
- SKU All
- Analysis All
- Q SKU

**Data Source: Event+ (ameyo.my.salesforce.com)** (579 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Opportunity` (?), `Event` (salesforce)

**Key Calculated/Analytics Fields** (10):
  - Calculation4
  - Calculation5
  - GP Growth
  - Good Meeting Count - QTD
  - MTD Meeting Cal
  - QTD Meeting Cal
  - QTD Meeting Count
  - Revenue Growth
  - YTD - Meeting Start
  - YTD - Start Date

**Key Measure Fields** (50):
  - Account Name
  - Account Owner
  - Account Owner = Meeting Owner
  - Account Record Type
  - Account Status
  - Account type cal
  - AccountId (User1)
  - AccountId (User2)
  - CPM Count
  - Channels Count
  - Committed Booking Value
  - Country
  - Country (User2)
  - DID Count
  - EmailPreferencesStayInTouchReminder (User1)
  - EmailPreferencesStayInTouchReminder (User2)
  - Fixed Stage - Max
  - Good Meeting Count
  - Group Account
  - Id (Account)
  - ... and more (see JSON)

---

### 3.11. Penetration Index Dashboard

**Sheets**: 33 | **Data Sources**: 2 | **Total Fields**: 570

**Views/Sheets:**
- API 12 months
- Month API
- PPI HM R
- ACI C N
- ACI M N
- PPI 12 M
- API M
- ACI Last 12 months
- API C
- ACI Details New
- PPI HM 12M
- GPI Details
- API R
- ACI R N
- PPI C
- PPI HM Details 
- PPI SKU
- PPI HM C
- PPI SKU HM
- API SKU
- Sheet 32
- GPI R
- PP HM M 
- GPI C
- PPI M
- PPI R
- Month PPI
- Sheet 33
- GPI M
- GPI Month
- API Details
- PPI Details
- GPI SKU

**Data Source: Output - Group 22 july - Trend** (316 fields)
- Extracts: No
- Upstream Tables: `Extract` (hyper), `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Opportunity_Trend__c` (salesforce), `Lead_Backup__c` (salesforce)

**Salesforce API Fields** (59):
  - `Account Cluster__c`
  - `Account Region__c`
  - `Account_LongID__c`
  - `Customer_Universal_Account__c`
  - `Fixed_Cost__c`
  - `GP__c`
  - `Group_Account__c`
  - `ISQL_Accepted_Date__c`
  - `Lead Account_ID__c`
  - `Lead Create_Date__c`
  - `Lead Expected_Closure_Date__c`
  - `Lead First_Name__c`
  - `Lead Last_Name__c`
  - `Lead_Account_Name__c`
  - `Lead_Actual_Closure_Date__c`
  - `Lead_Forecast_Category__c`
  - `Lead_Owner__c`
  - `Lead_Source__c`
  - `Lead_Status__c`
  - `Lead_Trend_Date__c`
  - `Norm_Rev_Amount__c`
  - `Opp B_Deal_Date__c`
  - `Opp Classification_Type__c`
  - `Opp Close_Date__c`
  - `Opp Close_Month_for_Tableau__c`
  - `Opp Deal_Type__c`
  - `Opp Expected_Close_Date__c`
  - `Opp Forecast_Category__c`
  - `Opp MRR_Amount__c`
  - `Opp Net_New_INR__c`
  - ... and 29 more (see JSON)

**Key Calculated/Analytics Fields** (15):
  - ACI Calculation
  - ACI Calculation -1
  - ACI Calculation -10
  - ACI Calculation -11
  - ACI Calculation -2
  - ACI Calculation -3
  - ACI Calculation -4
  - ACI Calculation -5
  - ACI Calculation -6
  - ACI Calculation -7
  - ACI Calculation -8
  - ACI Calculation -9
  - Calculation1
  - Calculation2
  - Calculation4

**Key Measure Fields** (96):
  - ACI Accounts to cover
  - ACI Accounts to cover (copy)
  - ACI Accounts to cover - Cus + Pro
  - ACI Accounts to cover - Lead
  - ACI Accounts to cover - Lead (copy)
  - ACI Accounts to cover - Opp
  - ACI Accounts to cover - Rev
  - ACI Accounts to cover -1
  - ACI Accounts to cover -10
  - ACI Accounts to cover -11
  - ACI Accounts to cover -2
  - ACI Accounts to cover -3
  - ACI Accounts to cover -4
  - ACI Accounts to cover -5
  - ACI Accounts to cover -6
  - ACI Accounts to cover -7
  - ACI Accounts to cover -8
  - ACI Accounts to cover -9
  - ACI Lead / Total 
  - ACI Opp / Total
  - ... and more (see JSON)

**Data Source: Index - 5 Aug Acc Rev** (254 fields)
- Extracts: No
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce)

**Salesforce API Fields** (29):
  - `Account Cluster__c`
  - `Account Region__c`
  - `Customer_Universal_Account__c`
  - `Fixed_Cost__c`
  - `GP__c`
  - `Group_Account__c`
  - `ISQL_Accepted_Date__c`
  - `Lead_Status__c`
  - `Norm_Rev_Amount__c`
  - `Opp Stage__c`
  - `Opp Trend_Date__c`
  - `Product_Type__c`
  - `Products__c`
  - `Project__c`
  - `Rev Classification__c`
  - `Rev Cluster__c`
  - `Rev Customer_Name__c`
  - `Rev Parent_SKU__c`
  - `Rev Region__c`
  - `Rev_Source__c`
  - `Rev_Sub_Source__c`
  - `Revenue_Booked_Amount__c`
  - `Revenue_Booked_Month_for_Tableau__c`
  - `Revenue_Booked_On__c`
  - `Revenue_Classification__c`
  - `SKU__c`
  - `Total_Cost__c`
  - `Universal_Account__c`
  - `Variable_Cost__c`

**Key Calculated/Analytics Fields** (17):
  - ACI Calculation
  - ACI Calculation -1
  - ACI Calculation -10
  - ACI Calculation -11
  - ACI Calculation -2
  - ACI Calculation -3
  - ACI Calculation -4
  - ACI Calculation -5
  - ACI Calculation -6
  - ACI Calculation -7
  - ACI Calculation -8
  - ACI Calculation -9
  - Calculation1
  - Calculation2
  - Calculation3
  - Calculation4
  - Calculation5

**Key Measure Fields** (82):
  - ACI Accounts to Cover - Rev
  - ACI Accounts to cover
  - ACI Accounts to cover - Lead
  - ACI Accounts to cover - Opp
  - ACI Accounts to cover - Rev
  - ACI Accounts to cover -1
  - ACI Accounts to cover -10
  - ACI Accounts to cover -11
  - ACI Accounts to cover -2
  - ACI Accounts to cover -3
  - ACI Accounts to cover -4
  - ACI Accounts to cover -5
  - ACI Accounts to cover -6
  - ACI Accounts to cover -7
  - ACI Accounts to cover -8
  - ACI Accounts to cover -9
  - Account AD Id
  - Account CSM ID
  - Account Cluster Cal - Base
  - Account Cluster__c
  - ... and more (see JSON)

---

### 3.12. Retention Dashboard

**Sheets**: 131 | **Data Sources**: 2 | **Total Fields**: 683

**Views/Sheets:**
- ROLLING HISTORY NRR sku
- sku QRR Rolling SKU
- NRGP C 12 (2)
- GRR Rev Mon Details 
- GRR YTD M L+S 
- Revenue Detail NRR SKU
- GRGP His
- GRR Rev Mon R LS
- GRGP His (2)
- GRR Rev Mon Details LS
- GRR YTD logo M
- Revenue Detail QTD NRR 
- sku QRR YoY SKU
- GRGP Card 
- cluster YTD NRR SKU 
- GRR Rev Mon R
- NRR YTD
- GRR Roll SKU
- NRGP C
- NRGP R 12 (2)
- GRR Month logo M  
- GRGP R (2)
- sku QRR Rolling
- SKU NRR 12_Rolling
- NRGP Account Details 12 (3)
- NRR Analysis QRR Rolling (2)
- GRGP C
- cluster QRR Rolling
- NRGP SKU
- cluster QTD NRR
- Revenue Detail QRR Rolling
- sku MTD NRR SKU
- NRR_SKU
- cluster QRR Rolling SKU
- Revenue Detail QTD NRR SKU
- Revenue Detail YTD NRR SKU
- NRR Analysis YTD
- Account Analysis MTD NRR 
- GRR Roll M
- Rolling 12 M NRR
- NRGP Account Details 12
- sku YTD NRR
- region MTD NRR SKU
- cluster QTD NRR SKU
- Base 4 (2)
- region QTD NRR SKU
- NRGP Card 12 month rolling (2)
- GRR Rev YTD C
- cluster QRR YoY SKU
- region MTD NRR
- GRR Rev YTD R LS
- region QRR YOY SKU
- NRGP Account Details
- Sheet 168 (2)
- GRR Rev YTD Details
- NRGP Account Details 12 (2)
- NRR Analysis MTD 
- region YTD NRR SKU
- GRR Rev Roll His
- GRGP SKU (2)
- NRGP His (2)
- GRR Month logo_SKU M
- NRR Analysis MTD SKU
- SKU_NRR QRR
- NRGP His
- GRR Rev YTD SKU
- Sheet 57
- NRGP SKU 12 (2)
- sku QRR YoY
- NRR QRR
- GRR Rev Mon SKU
- GRGP Account Details (2)
- NRGP R
- region QRR Rolling
- NRR Analysis QRR YOY
- GRR Rev YTD Details LS
- Base 4
- GRR Rev Roll R
- NRR Analysis YTD SKU
- NRR Analysis QRR YOY SKU
- NRGP R 12 (3)
- NRGP SKU 12 (3)
- NRR Account Total
- region YTD NRR
- NRR Analysis QRR Rolling
- NRGP SKU 12
- GRGP Card (2)
- Base 12
- GRR Rev Roll Details
- Revenue Detail YTD NRR 
- NRGP Card
- Revenue Detail QRR YoY
- sku MTD NRR 
- Sheet 169
- GRR Rev Mon C
- SKU_QRR rolling
- SKU_NRRYTD
- sku QTD NRR SKU
- GRR Rev Roll R L+S
- GRR Rev Roll C
- NRGP C 12
- GRR Rev Roll Sku His
- region QTD NRR 
- cluster YTD NRR
- ROLLING HISTORY NRR
- Revenue Detail QRR YoY SKU
- NRR 3M ROLLING
- sku QTD NRR 
- region QRR YOY
- NRGP Card (2)
- GRR Rev Mon C LS
- GRR Rev Roll Details L+S
- LRD NRR (10)
- NRGP Card 12 month rolling
- sku YTD NRR SKU
- Revenue Detail QRR Rolling SKU
- GRGP C (2)
- GRR Rev YTD R
- NRGP R 12
- cluster YTD NRR 
- Sheet 168
- region QRR Rolling SKU
- NRGP C 12 (3)
- GRGP Account Details
- GRR Roll M L+S
- cluster YTD NRR SKU
- GRGP R 
- GRGP SKU
- cluster QRR YoY
- GRR Rev YTD C LS
- GRR Rev Roll C L+S

**Data Source: Index - 5 Aug Acc Rev** (241 fields)
- Extracts: No
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce)

**Salesforce API Fields** (26):
  - `Account Cluster__c`
  - `Account Region__c`
  - `Customer_Universal_Account__c`
  - `Fixed_Cost__c`
  - `GP__c`
  - `Group_Account__c`
  - `ISQL_Accepted_Date__c`
  - `Norm_Rev_Amount__c`
  - `Product_Type__c`
  - `Products__c`
  - `Project__c`
  - `Rev Classification__c`
  - `Rev Cluster__c`
  - `Rev Customer_Name__c`
  - `Rev Parent_SKU__c`
  - `Rev Region__c`
  - `Rev_Source__c`
  - `Rev_Sub_Source__c`
  - `Revenue_Booked_Amount__c`
  - `Revenue_Booked_Month_for_Tableau__c`
  - `Revenue_Booked_On__c`
  - `Revenue_Classification__c`
  - `SKU__c`
  - `Total_Cost__c`
  - `Universal_Account__c`
  - `Variable_Cost__c`

**Key Calculated/Analytics Fields** (27):
  - Calculation1
  - Calculation2
  - Calculation3
  - Calculation4
  - GPGR Rolling 12 Months 
  - GPGR Rolling 12 Months -1
  - GPGR Rolling 3 Months 
  - GPGR Rolling 3 Months  -2
  - GPGR Rolling 3 Months  -3
  - GPGR Rolling 3 Months -1
  - GRR GP - Rolling 12 Months
  - GRR Revenue - YTD (Logo SKU)
  - GRR Revenue - YTD (Logo)
  - Min - Revenue YTD or PYTD (Logo SKU)
  - Min - Revenue YTD or PYTD (Logo)
  - NGPR Rolling 12 Months
  - NGPR Rolling 12 Months -1
  - NGPR Rolling 12 Months LOGO
  - NGPR Rolling 3 Months
  - NGPR Rolling 3 Months -1
  - NGPR Rolling 3 Months -2
  - NGPR Rolling 3 Months -3
  - NGPR Rolling 3 Months Logo 
  - PYTD - Rev Logo
  - PYTD - Rev Logo SKU
  - ... and 2 more (see JSON)

**Key Measure Fields** (146):
  - Account AD Id
  - Account CSM ID
  - Account Cluster cal
  - Account Cluster__c
  - Account Name M
  - Account Region cal
  - Account Region__c
  - Account Type Cal
  - Account_Id Main
  - Blank GRGP Logo 
  - Blank GRGP Logo  (copy)
  - Blank GRR Revenue Logo
  - Blank GRR Revenue Logo SKU
  - Blank NRGP Logo 
  - Blank NRGP Logo  (copy)
  - Current Month Revenue (Logo SKU)
  - Current Month Revenue (Logo)
  - Customer_Universal_Account__c
  - GP Last 0 - 12  Months (Logo SKU) 
  - GP Last 0 - 12  Months (Logo SKU)  -1
  - ... and more (see JSON)

**Data Source: OneExo Revenue+ (ameyo.my.salesforce.com) (local copy)** (442 fields)
- Extracts: Yes
- Upstream Tables: `User` (?), `Account` (salesforce), `Accounts_Revenue__c` (salesforce), `Opportunity` (?)

**Key Calculated/Analytics Fields** (136):
  - % MoM growth 
  - % MoM growth  GP
  - % MoM growth of GP previous year 
  - % MoM growth value
  - % QoQ growth 
  - % QoQ growth  GP
  - % QoQ growth GP N 
  - % QoQ growth N
  - % QoQ growth Null
  - % QoQ growth of GP previous year 
  - % QoQ growth of previous year
  - % YoY growth
  - % YoY growth GP
  - % YoY growth of previous 
  - % YoY growth of previous  GP
  - Calculation28
  - Current Quarter %QTD
  - DIFF MTD/PMTD
  - DIFF MTD/PMTD SKU
  - DIFF PYTD YTD
  - DIFF PYTD YTD SKU
  - DIFF QTD/PQTD
  - DIFF QTD/PQTD SKU
  - Diff Rolling 12 month
  - Diff Rolling 12 month SKU
  - ... and 111 more (see JSON)

**Key Measure Fields** (110):
  - Account
  - Account ID
  - Account Name
  - Account Source
  - Account Status
  - Account Type
  - Account_
  - Account_Status__c (Universal Account)
  - Amount INR-CR
  - CPM Count
  - CY- Last 12 month N SKU Lakh
  - Channels Count
  - Cluster__c (Account)
  - Cohort_Industry__c (Universal Account)
  - Cohort_Size__c (Universal Account)
  - Compliance_InfoSec_Contact__c (Universal Account)
  - Current Month  GP in Previous year
  - Current Quarter value GP N
  - Current-Quarter GP in previous Year 
  - DID Count
  - ... and more (see JSON)

---

## 4. Tableau Prep Flow Data Sources

Two workbooks use Tableau Prep flows instead of direct Salesforce connections:

### OB to Revenue Workflow (Prep Flow)
- **Used by**: OB to Rev & GP Journey
- **Upstream Tables**: Account, OB_to_Revenue__c, inspire1__Project__c, Opportunity
- **Purpose**: Joins Order Booking data with Revenue recognition data to track booking-to-revenue conversion
- **Key Fields**: Monthly Net New (by month/year), Monthly Revenue (by month/year), Monthly GP (by month/year), Booking to Revenue %, Booking to GP %

### OB_to_Rev_Burn Schedule (Prep Flow)
- **Used by**: Burn Schedule, OB to Rev & GP Journey
- **Upstream Tables**: Extract, Account, OB_to_Revenue__c, inspire1__Project__c, Opportunity
- **Purpose**: Burn schedule tracking - how order bookings convert to revenue over time by region/cluster/SKU

## 5. CEO Dashboard - Non-Salesforce Data Sources

The CEO Dashboard includes one Excel-based data source with 6 sheets:

### Finance Metrics-Tableau+ (106 fields)
| Excel Sheet | Purpose |
|-------------|---------|
| `Finance Metrics-Tableau$` | Revenue, GP, margins, NRR/GRR targets |
| `Key matrics-Tableau$` | Key business KPIs and metrics |
| `Geo-diversification Tableau$` | International revenue diversification |
| `Penetration-Tableau$` | Product/account penetration metrics |
| `Tech Reporting Metrics-Tableau$` | Technology/platform metrics |
| `HR Dept-Tableau$` | Headcount and HR metrics |

## 6. Key Business Metrics by Dashboard

| Dashboard | Primary Metrics | Salesforce Objects | Filters |
|-----------|----------------|-------------------|---------|
| Revenue Dashboard | Revenue (₹), GP, NRR/GRR, MoM/QoQ/YoY Growth | Accounts_Revenue__c, Account | Year, Region, Cluster, SKU, Rev Classification |
| Variance Analysis | Target vs Actual (Revenue, GP, Booking), GM Profile | Accounts_Revenue__c + Opportunity + Accounts_Target__c + Booking_Target__c | Year, Region, Cluster, Quarter |
| Opportunity Analysis | Pipeline, Funnel, Win Rate, Loss Analysis, Order Booking | Opportunity, Account, Lead | Region, Cluster, SKU, Classification Type, Stage |
| Booking Forecast | MTD/QTD/YTD Actual vs Target vs Forecast | Opportunity + Booking_Target__c | Region, Cluster, Parent SKU, Forecast Category |
| OB to Rev & GP Journey | Booking→Revenue→GP conversion journey by period | OB_to_Revenue__c (Prep), Opportunity, Account | Year, Quarter, Region, Cluster |
| Burn Schedule | OB-to-Rev burn rate by Region/Cluster/SKU/Account | OB_to_Revenue__c (Prep), Account, Opportunity | Region, Cluster, SKU |
| CEO Dashboard | Consolidated: Revenue, GP, NRR/GRR, Penetration, Pipeline | Accounts_Revenue__c + Opportunity + Excel | Region, Cluster |
| Key KPIs | Sales Cycle, Win Rate, Conversion Rate | Opportunity + Opportunity_Trend__c | Classification Type, Region, Cluster |
| Lead Analysis | Lead Volume (MTD/QTD/YTD), Source, Conversion | Lead, Campaign | Lead Parameter, BDR, Lead Category, Region |
| Meetings Dashboard | Meeting Count, Productive Meetings, Effort | Event, Account, Opportunity | AD/CSM, Meeting Type, Region, Cluster |
| Penetration Index | ACI/API/PPI/GPI metrics, Product Penetration | Account, Accounts_Revenue__c, Opportunity_Trend__c, Lead_Backup__c | PPI Month, Min Revenue, Region, Cluster |
| Retention Dashboard | NRR, GRR, NRGP, GRGP (Monthly/Rolling/YTD/SKU) | Accounts_Revenue__c, Account | Month, Region, Cluster, SKU, AD/CSM |

## 7. Limitations & Notes

1. **Calculated Field Formulas**: Not available via API with Viewer role. Need Creator/Explorer access or .twbx export from workbook owner (Bhavya Paliwal) to see actual Tableau calculated field formulas.
2. **Connected Columns**: The mapping between Tableau field names and Salesforce API field names is partially available. Fields with `__c` suffix are direct Salesforce API names. Calculated fields (e.g., 'Win Rate', 'QoQ Growth') are Tableau-computed and their formulas require Creator access.
3. **Tableau Prep Flows**: OB to Revenue and Burn Schedule dashboards use Tableau Prep to join/transform data before visualization. The exact Prep flow logic requires Prep access.
4. **Data Freshness**: Most datasources use scheduled extracts (hasExtracts: true). Real-time data requires live connections.
5. **Field Count Variance**: Some datasources appear as copies (e.g., 'Opportunity+ (copy)') with different field counts due to additional calculated fields or different table joins.

---

## 8. Comparison: Tableau Actual vs Previous CLAUDE.md Mappings

### 8.1 Dashboard → Data Source Mapping Accuracy

| Dashboard | CLAUDE.md Mapping | Actual Tableau Data Source | Deviation |
|-----------|-------------------|--------------------------|-----------|
| MIS → Revenue Analysis | accounts_revenue__c | OneExo Revenue+ → Accounts_Revenue__c + Account + User + Opportunity | MATCH + Opportunity join not documented |
| MIS → GP Analysis | accounts_revenue__c (GP__c) | OneExo Revenue+ → same as Revenue | MATCH |
| Booking & Pipeline → Order Booking | Opportunity (Stage=Order/POC) | Opportunity+ → Opportunity + Account + Lead + User + Campaign + OpportunityLineItem + Program__c | PARTIAL — 5 additional tables joined not documented |
| Booking & Pipeline → Pipeline | Opportunity (active stages) | Same Opportunity+ datasource | MATCH |
| Booking & Pipeline → Loss Analysis | Opportunity (lost stages) | Same Opportunity+ datasource | MATCH |
| Variance → Revenue | accounts_revenue__c | OneExo Revenue+ with Accounts_Target__c join | DEVIATION — Accounts_Target__c not documented in CLAUDE.md |
| Variance → Booking | Opportunity | Opportunity+ with Booking_Target__c join | DEVIATION — Booking_Target__c not documented in CLAUDE.md |
| Variance → GM Profile | accounts_revenue__c | OneExo Revenue+ (3 copies with different calc fields) | MATCH + multiple calculated variants |
| Booking Forecast | Opportunity (pipeline) | Opportunity+ with Booking_Target__c + Opportunity_Trend__c + Campaign + Opp_Related_Programs__c | DEVIATION — 4 additional objects not documented |
| Retention → Revenue | accounts_revenue__c (current vs preceding) | Index-5 Aug Acc Rev + OneExo Revenue+ | PARTIAL — two datasources, not one |
| Retention → GP | accounts_revenue__c (GP__c) | Same two datasources | PARTIAL |
| Penetration Index | Account + accounts_revenue__c | Output-Group 22 july Trend + Index-5 Aug Acc Rev → Account + Accounts_Revenue__c + Opportunity_Trend__c + Lead_Backup__c + User | DEVIATION — 2 additional objects (Opportunity_Trend__c, Lead_Backup__c) |
| Key KPIs | Opportunity | Opportunity+ (2 copies) → Opportunity + Account + Lead + User + Program__c + Opportunity_Trend__c | DEVIATION — Opportunity_Trend__c + Program__c not documented |
| Lead Analysis | Lead | Lead+ → Lead + Account + Campaign + Opportunity | PARTIAL — 3 additional joins not documented |
| Meetings | Event/Task | Event+ → Event + Account + User + Accounts_Revenue__c + Opportunity | DEVIATION — Revenue + Opportunity joins not documented |
| CEO Dashboard | Cross-object | 3 datasources: Excel (Finance Metrics) + Index-5 Aug Acc Rev (SF) + Opportunity+ Migrated (SF) | MATCH — but Excel source details now available |
| Booking to Revenue | Cross-object: OB from Opportunity, Rev/GP from accounts_revenue__c | OB to Revenue Workflow (Tableau Prep) + OB_to_Rev_Burn Schedule (Tableau Prep) | DEVIATION — uses Tableau Prep flows, not direct SF queries |

### 8.2 New Objects Discovered (Not in CLAUDE.md Dashboard Mapping)

| Object | Used By Dashboard(s) | Purpose |
|--------|---------------------|---------|
| `Accounts_Target__c` | Variance Analysis | Revenue/GP targets for variance computation |
| `Booking_Target__c` | Variance Analysis, Booking Forecast | Booking targets for forecast vs actual |
| `Opportunity_Trend__c` | Key KPIs, Penetration Index, Booking Forecast | Pipeline trending/snapshots for time-series analysis |
| `Lead_Backup__c` | Penetration Index | Lead history backup for penetration calculations |
| `OB_to_Revenue__c` | OB to Rev & GP Journey, Burn Schedule | Booking-to-revenue mapping (Tableau Prep) |
| `inspire1__Project__c` | OB to Rev & GP Journey, Burn Schedule | Managed package project data |
| `Opp_Related_Programs__c` | Opportunity Analysis, Booking Forecast, CEO Dashboard | Junction: Opportunity ↔ Program |
| `OpportunityLineItem` | Opportunity Analysis, Variance Analysis, CEO Dashboard | Deal line items with product detail |
| `Program__c` | Key KPIs, Opportunity Analysis, CEO Dashboard | Program/project tracking |
| `Campaign` | Lead Analysis, Opportunity Analysis, Booking Forecast, CEO Dashboard | Marketing campaign attribution |

### 8.3 Key Architectural Findings vs CRM Buddy Document

| # | Finding | Impact on Ask Salesforce |
|---|---------|------------------------|
| 1 | **Variance Analysis uses `Accounts_Target__c`** — a separate target object not `Target__c` | CLAUDE.md documents `Target__c` but Tableau uses `Accounts_Target__c`. Need to verify if these are the same or different objects. |
| 2 | **Booking targets use `Booking_Target__c`** — not documented anywhere in CLAUDE.md | Need to add this object to the field audit for booking target/forecast questions. |
| 3 | **Retention uses TWO datasources** — not a single-pass calculation | NRR/GRR computation requires joining current vs preceding period from `Accounts_Revenue__c`. Multi-query support (from plan) is essential. |
| 4 | **Penetration Index uses `Opportunity_Trend__c`** — snapshot data | ACI/API/PPI/GPI metrics need historical snapshots, not just current Opportunity state. |
| 5 | **Meetings dashboard joins `Accounts_Revenue__c` + `Opportunity`** | Meeting productivity metrics correlate with revenue — not just Event data alone. |
| 6 | **OB→Rev journey uses Tableau Prep** | This transformation logic is NOT available via SOQL. Ask Salesforce cannot replicate this without the Prep flow logic. |
| 7 | **Variance Analysis has 5 datasource copies** (4,306 total fields) | Multiple calculated field variants for different time periods/views. Most complex workbook. |
| 8 | **Revenue Dashboard joins Opportunity table** | Even pure revenue views pull Opportunity data — likely for deal context on revenue records. |
| 9 | **Lead Analysis joins Opportunity + Account** | Lead conversion tracking requires cross-object queries. |
| 10 | **CEO Dashboard uses Excel sheets** for Finance Metrics, HR, Tech Reporting | These metrics are NOT in Salesforce and cannot be replicated via SOQL. |

### 8.4 Field Count Comparison: Tableau vs CLAUDE.md

| Object | CLAUDE.md Fields Documented | Tableau Fields Referencing Object | Gap |
|--------|---------------------------|----------------------------------|-----|
| Opportunity | 227 fields | 934 (incl. calculated) | +707 calculated/derived fields in Tableau |
| Account | 214 fields | Referenced in 12/12 workbooks | Consistent — Account is universal join |
| Accounts_Revenue__c | 39 fields | 443-718 (incl. calculated) | +400+ calculated period/comparison fields |
| Lead | ~50 fields | 416 (incl. calculated) | +366 calculated fields |
| Event | ~72 fields | 579 (incl. calculated) | +507 calculated fields |
| Case | 385 fields | Not in Tableau dashboards | N/A — Support dashboards are native SF |

### 8.5 CRM Buddy Patterns — Validated Against Tableau

| # | CRM Buddy Pattern | Tableau Validation | Status |
|---|-------------------|-------------------|--------|
| 1 | Revenue from `accounts_revenue__c` | Revenue Dashboard, Retention, CEO all use `Accounts_Revenue__c` | CONFIRMED |
| 2 | Bookings from Opportunity (Stage=Order) | All booking dashboards filter on Opportunity stage | CONFIRMED |
| 3 | Won stage = 'Order' | Tableau calculated fields reference 'Order' stage | CONFIRMED |
| 4 | Cluster from `Account_Cluster__c` / `Cluster__c` | All dashboards use Cluster-based grouping and filtering | CONFIRMED |
| 5 | FY Apr-Mar convention | Tableau calculated fields named 'YTD fiscal', 'Quarter Current' follow Apr-Mar | CONFIRMED |
| 6 | Net New INR as primary metric | `Net_New_INR__c` appears across Opportunity Analysis, Booking Forecast, Variance, Key KPIs | CONFIRMED |
| 7 | Revenue_Booked_Amount__c for revenue | Present in Revenue Dashboard, Retention, CEO, Penetration Index | CONFIRMED |
| 8 | GP__c for gross profit | Present in Revenue Dashboard, Variance, Retention, OB to Rev | CONFIRMED |
| 9 | B_Deal_Date__c for booking date | Referenced in Opportunity-based dashboards | CONFIRMED |
| 10 | Personal detection (my/I/me → owner filter) | Tableau dashboards have AD/CSM/Owner filter dimensions | ALIGNED — same filter approach |

### 8.6 Recommendations for Ask Salesforce

1. **Add `Accounts_Target__c` and `Booking_Target__c` to CLAUDE.md** — these are used for all target vs actual variance computations
2. **Add `Opportunity_Trend__c` to CLAUDE.md** — essential for time-series KPIs (sales cycle, win rate trending)
3. **Multi-query support (planned)** is CRITICAL for Retention (NRR/GRR), Variance, and Win Rate dashboards
4. **Cannot replicate**: OB→Rev journey (Tableau Prep), CEO Excel metrics (Finance/HR/Tech)
5. **Support dashboards (Case)** are NOT in Tableau — they are native Salesforce reports/dashboards
6. **Calculated field formulas** need Creator access or .twbx export to document the actual computation logic
