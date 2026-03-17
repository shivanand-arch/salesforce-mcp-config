{
  "version": 1,
  "description": "KPI execution registry. Each entry defines a deterministic KPI formula with exact SOQL templates, stage sets, date fields, and supported dimensions. Matched against Tableau Key KPIs dashboard formulas.",
  "kpis": [
    {
      "id": "WIN_RATE",
      "displayName": "Win Rate",
      "domain": "opportunity",
      "formulaType": "RATIO",
      "sourceType": "LIVE_SF_WITH_TABLEAU_SEMANTICS",
      "baseObject": "Opportunity",
      "questionTerms": ["win rate", "win %", "win percentage", "win-rate"],
      "numerator": {
        "label": "Won Deals",
        "measureField": "Amount",
        "measureFn": "SUM",
        "countField": "Id",
        "dateField": "B_Deal_Date__c",
        "stageFilter": ["Order"]
      },
      "denominator": {
        "label": "Consumed Pipeline",
        "measureField": "Amount",
        "measureFn": "SUM",
        "countField": "Id",
        "dateField": "CloseDate",
        "stageFilter": ["Order", "Negotiation", "Closed Lost", "Closed-No decision", "Closed Unknown", "Closed Duplicate", "Rejected", "SDF Rejected", "POC Closed"]
      },
      "defaultDimension": "Account_Cluster__c",
      "supportedDimensions": {
        "cluster": "Account_Cluster__c",
        "region": "Account_Region__c",
        "owner": "Owner.Name",
        "sku": "SKU__c",
        "classification": "Classification_Type__c",
        "use case": "Use_Case__c"
      },
      "supportedTimeGrains": ["FY", "Q", "M"],
      "resultFormat": "PERCENT",
      "showBothValueAndCount": true,
      "interpretationNote": "Won uses B_Deal_Date__c (booking date). Consumed uses CloseDate. Matches Tableau Key KPIs dashboard."
    },
    {
      "id": "CONVERSION_RATE",
      "displayName": "Conversion Rate",
      "domain": "opportunity",
      "formulaType": "RATIO",
      "sourceType": "LIVE_SF_WITH_TABLEAU_SEMANTICS",
      "baseObject": "Opportunity",
      "questionTerms": ["conversion rate", "conversion ratio", "conversion %", "conversion percentage"],
      "numerator": {
        "label": "Closed/Won Deals",
        "measureField": "Amount",
        "measureFn": "SUM",
        "countField": "Id",
        "dateField": "B_Deal_Date__c",
        "stageFilter": ["Order"]
      },
      "denominator": {
        "label": "Total Opportunities",
        "measureField": "Amount",
        "measureFn": "SUM",
        "countField": "Id",
        "dateField": "CloseDate",
        "stageFilter": ["Order", "Suspect", "Approach", "Prospect", "Proposal", "Negotiation", "SDF Submission", "POC", "On Hold", "Closed won - Pending", "Closed Lost", "Closed-No decision", "Closed Unknown", "Closed Duplicate", "Rejected", "SDF Rejected", "POC Closed"]
      },
      "defaultDimension": "Account_Cluster__c",
      "supportedDimensions": {
        "cluster": "Account_Cluster__c",
        "region": "Account_Region__c",
        "owner": "Owner.Name",
        "sku": "SKU__c"
      },
      "supportedTimeGrains": ["FY", "Q", "M"],
      "resultFormat": "PERCENT",
      "showBothValueAndCount": true,
      "interpretationNote": "Conversion = Won / Total pipeline (all stages including open). Wider denominator than Win Rate."
    },
    {
      "id": "SALES_CYCLE_AVG",
      "displayName": "Average Sales Cycle",
      "domain": "opportunity",
      "formulaType": "AVERAGE",
      "sourceType": "LIVE_SF_WITH_TABLEAU_SEMANTICS",
      "baseObject": "Opportunity",
      "questionTerms": ["average sales cycle", "avg sales cycle", "mean sales cycle", "sales cycle average", "sales cycle"],
      "computation": {
        "label": "Sales Cycle (Days)",
        "startDateField": "ISQL_Accepted_Date__c",
        "endDateField": "B_Deal_Date__c",
        "stageFilter": ["Order"],
        "unit": "DAYS",
        "nullHandling": "EXCLUDE_NULL_DATES"
      },
      "defaultDimension": "Account_Cluster__c",
      "supportedDimensions": {
        "cluster": "Account_Cluster__c",
        "region": "Account_Region__c",
        "owner": "Owner.Name",
        "sku": "SKU__c",
        "classification": "Classification_Type__c"
      },
      "supportedTimeGrains": ["FY", "Q", "M"],
      "resultFormat": "DAYS",
      "interpretationNote": "Sales Cycle = days from ISQL Accepted Date to B Deal Date. Only Order stage deals with both dates populated."
    },
    {
      "id": "SALES_CYCLE_MEDIAN",
      "displayName": "Median Sales Cycle",
      "domain": "opportunity",
      "formulaType": "MEDIAN",
      "sourceType": "LIVE_SF_WITH_TABLEAU_SEMANTICS",
      "baseObject": "Opportunity",
      "questionTerms": ["median sales cycle", "sales cycle median"],
      "computation": {
        "label": "Sales Cycle Median (Days)",
        "startDateField": "ISQL_Accepted_Date__c",
        "endDateField": "B_Deal_Date__c",
        "stageFilter": ["Order"],
        "unit": "DAYS",
        "nullHandling": "EXCLUDE_NULL_DATES",
        "maxDetailRows": 10000
      },
      "defaultDimension": "Account_Cluster__c",
      "supportedDimensions": {
        "cluster": "Account_Cluster__c",
        "region": "Account_Region__c",
        "owner": "Owner.Name"
      },
      "supportedTimeGrains": ["FY", "Q", "M"],
      "resultFormat": "DAYS",
      "interpretationNote": "Median Sales Cycle = middle value when all sales cycles are sorted. More robust than average against outliers."
    }
  ]
}
