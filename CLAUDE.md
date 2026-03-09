# Exotel Salesforce MCP

This project provides Salesforce MCP (Model Context Protocol) integration for AI coding assistants.

## Salesforce Org Details
- **Org Alias**: ameyo
- **Org URL**: https://ameyo.my.salesforce.com
- **Toolsets Enabled**: orgs, data, metadata, users

## Key Salesforce Objects & Fields

### Opportunity
- Stage values: Suspect, Approach, Prospect, Proposal, Negotiation, POC, On Hold, Order (Won), Closed Lost, Closed-No decision, Closed Unknown, Closed Duplicate, Rejected, SDF Rejected
- `MRR_Amount__c` — Monthly recurring revenue
- `Deal_Type__c` — Subscription, On-Premise, Onetime_Customisation, AMC
- `Classification_Type__c` — New Sales, Cross sell, Up sell, Cross Sell New, Net-New Upsell (Cross-Sell), Net-New Upsell (New Sales), AMC Renewal, License Renewal
- `Loss_Reason__c` — Reason for deal loss
- `LastStageChangeDate` — Standard field for tracking stage movement

### Case (Support Tickets)
- `Is_Jira_Escalated__c` — Whether ticket is escalated to Jira
- `Customer_pending_hours__c` — Hours spent waiting on customer
- Team ownership via Owner queue names: "SAAS FLR Queue", "FLR Support Queue", "TNR - Major Queue", "TNR - Minor Queue"

### Lead
- SDR role identified via `Owner.UserRole.Name LIKE '%SDR%'`
- ChatGPT leads tracked via `UTM_Campaign__c = 'chatgpt.com'` and `LeadSource = 'Answer Engine'`
- SDR-generated opportunities use `LeadSource = 'IS Generated'` (not 'SDR Generated')

### Account
- `Revenue_Growth__c` — Revenue growth metric
- `Churned_Day__c` — Number field (NOT a date)

## SOQL Tips
- Multipicklist fields (`Product_Type__c`, `Type_of_Solution__c`) require `INCLUDES` operator, NOT `LIKE`
- `Description` field cannot be filtered with `LIKE` in SOQL
- `Subject` field cannot be used in `GROUP BY`
- Cannot use alias names in `ORDER BY` — use the aggregate function directly (e.g., `ORDER BY COUNT(Id) DESC`)
- Won stage = `'Order'` (not 'Closed Won')
