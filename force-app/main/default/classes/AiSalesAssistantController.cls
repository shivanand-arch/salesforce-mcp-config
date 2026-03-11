/**
 * Main controller for the AI Sales Assistant LWC.
 * Orchestrates: User Question -> Claude (SOQL) -> Execute -> Claude (Summary) -> LWC
 */
public with sharing class AiSalesAssistantController {

    public class AssistantResponse {
        @AuraEnabled public String answer;
        @AuraEnabled public String soqlQuery;
        @AuraEnabled public Integer recordCount;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Long executionTimeMs;
    }

    // Batch ID for stress test logging — set by StressTestRunner before calling askQuestion
    public static String currentBatchId;

    private static final String SOQL_SYSTEM_PROMPT =
        'You are a Salesforce SOQL generator for Exotel/Ameyo\'s org. Convert natural language to SOQL.\n\n' +
        '=== RULES ===\n' +
        '1. Return ONLY a SOQL query in ```soql ``` code blocks.\n' +
        '2. Always LIMIT (max 2000) EXCEPT aggregate queries without GROUP BY (e.g. SELECT COUNT(Id) FROM X — NO LIMIT allowed). 3. No DML. 4. Use aggregates for totals/summaries.\n' +
        '5. NEVER invent field names. ONLY use fields listed here or standard SF fields.\n' +
        '6. DateTime vs Date: CloseDate and fields ending _Date__c (Date type) use YYYY-MM-DD.\n' +
        '   ALL DateTime fields (CreatedDate, LastModifiedDate, LastStageChangeDate, *_time__c, *_DateTime__c) use YYYY-MM-DDT00:00:00Z.\n' +
        '7. Formula fields CANNOT be used in GROUP BY, aggregate WHERE, or ORDER BY in aggregates.\n' +
        '8. Multi-picklist: MUST use INCLUDES/EXCLUDES infix, NEVER as function. NEVER use LIKE on multi-picklist.\n\n' +
        '=== QUERY PHILOSOPHY ===\n' +
        '- DEFAULT TIME: No date specified → current FY (April 1 to today). Leads/Cases use CreatedDate.\n' +
        '  e.g. March 2026 → CloseDate >= 2025-04-01; June 2026 → CloseDate >= 2026-04-01\n' +
        '- Specified range: add 30-day buffer both sides.\n' +
        '- Prefer >= for thresholds ("above 2 lakhs" = >= 200000).\n' +
        '- Rankings/leaderboards → GROUP BY + COUNT/SUM, ORDER BY aggregate DESC, LIMIT 2000.\n' +
        '- Deal lists/details → individual records with Name, Account.Name, Owner.Name, etc.\n' +
        '- Losses/wins: include Loss_Reason__c, Competition__c, Account_Region__c, Product_Type__c, Owner.Name.\n\n' +
        '=== FISCAL YEAR & QUARTERS ===\n' +
        'Indian FY (Apr-Mar): Q1=Apr-Jun, Q2=Jul-Sep, Q3=Oct-Dec, Q4=Jan-Mar.\n' +
        'FY2025=Apr 2025-Mar 2026, FY2026=Apr 2026-Mar 2027.\n' +
        'ALWAYS use explicit date ranges for FY/quarters, NEVER SOQL fiscal literals. LAST_N_DAYS is OK.\n\n' +
        '=== CURRENCY ===\n' +
        '1 USD=83.33 INR, 1 AED=22.73 INR. INR deals in INR, USD/AED deals in USD.\n' +
        'Cross-currency: include CurrencyIsoCode in SELECT and GROUP BY.\n\n' +
        '=== OPPORTUNITY (341 fields) ===\n' +
        'Standard: Id, Name, AccountId, OwnerId, StageName, Amount, CloseDate, CreatedDate,\n' +
        '  LastModifiedDate, IsClosed, IsWon, Probability, Type, LeadSource, Description,\n' +
        '  ForecastCategoryName, LastStageChangeDate(DateTime!), LastActivityDate, NextStep,\n' +
        '  CampaignId, CurrencyIsoCode, HasOpportunityLineItem, RecordTypeId\n\n' +
        'Custom Number: MRR_Amount__c(MRR,NUMBER not Currency), One_Time_Value__c, Seats_Count__c,\n' +
        '  Channels_Count__c, DID_Count__c, Number_of_seats__c, Committed_Booking_Value__c,\n' +
        '  Full_Potential_Value__c, Net_New__c\n' +
        'Custom Picklist: Deal_Type__c(Subscription|On-Premise|Onetime_Customisation|AMC),\n' +
        '  Classification_Type__c(New Sales|Up sell|Cross sell|AMC Renewal|etc),\n' +
        '  Account_Region__c(Scaleup|Domestic Enterprise|International),\n' +
        '  Account_Cluster__c, Loss_Reason__c, Loss_Theme__c, Win_Reasons__c, Win_Theme__c,\n' +
        '  CH_Forecast__c, Commit_Status__c, Deal_Category__c, Deal_Circle__c,\n' +
        '  Deal_Request_Type__c, Existing_Customer_or_Not__c, Forecast_Category__c,\n' +
        '  SKU__c, Product_Dimension__c, Sub_Stage__c, Telephony__c, Telephony_Provided__c,\n' +
        '  Use_Case__c, Sales_Status__c, ISQL_Stage__c, Reversal_Type__c, Lead_Campaign_Type__c\n' +
        'Multi-Picklist (MUST use INCLUDES): Product_Type__c, Type_of_Solution__c, Competition__c,\n' +
        '  CRM_3rd_Party__c, PBX_Integration__c, Custom_use_cases__c, Pricing_Model__c,\n' +
        '  Setups__c, Lead_Products__c\n' +
        'Date: Deployment_Date__c, Expected_Close_Date__c, Actual_Closed_Date__c,\n' +
        '  Order_Stage_Date__c, Negotiation_Stage_Date__c, Proposal_Stage_Date__c,\n' +
        '  Prospect_Stage_Date__c, Approach_Stage_Date__c, POC_Stage_Date__c\n' +
        'Text: Country__c, Tenant_Name__c, Partner_Name__c\n' +
        'Checkbox: Is_From_Lead_Conversion__c, Converted_Opportunity__c, Decision_Maker_Identified__c,\n' +
        '  Discovery_Completed__c, Executive_Engagement__c, ROI_Analysis_Completed__c,\n' +
        '  Veeno__c, Is_Short_Rental__c\n' +
        'Lookup: Product_Specialist__c(User/Pre-Sales), Co_owner__c(User/CSM), Lead__c(Lead),\n' +
        '  Lead_Created_By__c(User), Owner_Manager__c(User)\n' +
        'Formula(read-only,NO GROUP BY): Amount_INR__c, Amount_USD__c, Norm_MRR__c, Total_Amount__c,\n' +
        '  Sales_Cycle__c, Business_Unit__c, Cluster__c, Region__c, Stage_Name__c,\n' +
        '  Source_Type__c, Age__c, Last_Activity_Since__c\n\n' +
        'STAGE VALUES: Active: Approach, Suspect, Prospect, Proposal, Negotiation, POC, On Hold,\n' +
        '  Closed won - Pending. Won: "Order" (NOT "Closed Won").\n' +
        '  Lost: Closed Lost, Closed-No decision, Closed Unknown, Closed Duplicate, Rejected, SDF Rejected\n' +
        'RecordTypes: Amendment Type, CPQ Existing Customer Type, CPQ New Customer Type,\n' +
        '  Existing Customer Type, New Customer Type, New Prospect, Renewal Type\n\n' +
        '=== CASE (557 fields) ===\n' +
        'Standard: Id, CaseNumber, Subject, Status, Priority, Origin, Type, Reason, CreatedDate,\n' +
        '  ClosedDate, IsClosed, IsEscalated, IsStopped, StopStartDate(DateTime), AccountId,\n' +
        '  ContactId, OwnerId, ParentId, Description, RecordTypeId\n\n' +
        'Custom Text: Queue__c(Queue name), Jira_Ticket_Key__c\n' +
        'Custom Number: Customer_pending_hours__c, Escalation_Level__c(1-4), Incident_duration__c(Min),\n' +
        '  Actual_Efforts__c, Priority_Score__c\n' +
        'Custom Currency: Approved_MRR__c, Approved_OTC__c, Quoted_MRR__c, Quoted_OTC__c\n' +
        'Custom DateTime: First_Escalation_time__c, Second_Escalation_time__c,\n' +
        '  Third_Escalation_time__c, Fourth_Escalation_time__c, Ticket_Start_time__c,\n' +
        '  Ticket_End_time__c, Date_Resolved__c, Ticket_Resolution_Time__c(DateTime),\n' +
        '  First_Resolution_Time__c, L4_Resolution_Date_time__c, JIRA_Escalated_Date__c\n' +
        'Custom Date: Delivery_Date__c, Deployment_Date__c, Deployment_Start__c, Deployment_End__c,\n' +
        '  APC_Parked_Ticket_Resolution_Date__c\n' +
        'Checkbox: Is_Jira_Escalated__c, Is_escalated__c, SLA_Violated__c, Activity__c\n' +
        'Picklist: Jira_Issue_Type__c, Jira_Ticket_Priority__c, Escalation_Closer_Type__c,\n' +
        '  Is_Escalation_Valid__c, Category__c, Issue_Category__c, Issue_Sub_category__c,\n' +
        '  Issue_type__c, Customer_Issue_Category__c, Customer_Issue_Sub_category__c,\n' +
        '  Cogno_Issue_Category__c, Cogno_Sub_Category__c, Product_Type__c(Picklist NOT multi),\n' +
        '  Product_Type_AI__c, Impact__c, Overall_SLA__c, SLA_Violation_Reason__c,\n' +
        '  First_Contact_resolution__c, Ticket_resolution_team__c, Resolution_expected_from__c,\n' +
        '  Accounts_Billing__c, Delivery_Type__c, Change_Type__c, Revenue_Increase__c,\n' +
        '  Cogno_Services__c, Source_of_Jira_Ticket__c\n' +
        'Lookup: First_Escalation_ticket_owner__c(User), Second_Escalation_ticket_owner__c(User),\n' +
        '  Third_Escalation_ticket_owner__c(User), Fourth_Escalation_ticket_owner__c(User),\n' +
        '  FLR_User__c(User), Agent__c(User), Manager__c(User)\n' +
        'Formula(NO GROUP BY/agg WHERE): Resolution_Time_Minutes__c(Number-USE FOR MTTR),\n' +
        '  Resolution_Time__c(DateTime), CM_Resolution_Level__c(Text), Total_Time__c(Text-no AVG),\n' +
        '  SLA__c(Text), Age_in_min__c(Number), Account_CSM__c, Account_Manager_Name__c, Acc_Setup_Type__c\n\n' +
        'MTTR: Use Resolution_Time_Minutes__c. "Without start/stop"→IsStopped=false. "With"→IsStopped=true.\n' +
        '  NO field MTTR__c or MTTR_Without_Start_Stop__c exists.\n' +
        'Status: Close_unsuccessful, Close_successful, Resolved, New, Open, Waiting on Customer (New),\n' +
        '  Pending, Closed - No Response, Approval Pending, SUA Approved, Delivery - In Progress,\n' +
        '  Close - Not Approved, Closed, Note_added, Waiting on DRI (New), Closed from DRI,\n' +
        '  Approved, In Progress, Pending - FD, Waiting on Third party, Resolved - RCA Pending\n' +
        'Origin: Email, Portal, Resolved-Chat, Platform-Voice, Missed-Chat, Phone, Open-Chat,\n' +
        '  Platform-Chat, Web, True Caller Email\n' +
        'Priority: Low, Minor, High, Medium, Critical, Major, Urgent, P3\n' +
        'Queue names: SAAS FLR Queue, FLR Support Queue, TNR - Major Queue, TNR - Minor Queue\n' +
        'RecordTypes: AOC Alerts, APC Alert, BIU, Change Management, CoC Tickets, Cogno Delivery,\n' +
        '  CognoAI, Compass, Consultancy, Conversation, Escalation, Feedback, GDPR,\n' +
        '  GP & Churn Request, Normal Support, Philippines Support, Platform Support,\n' +
        '  Premium Platform Support, Problem Management, Project Issues, PSG, RCA,\n' +
        '  Release Upgrade, SaaS Alerts, Service, Service Delivery, Service Issue,\n' +
        '  Service Project Delivery, Solutions Consultancy, SUAM, SUAM Exotel, Support,\n' +
        '  TrueCaller, TTSL\n\n' +
        '=== ACCOUNT (249 fields) ===\n' +
        'Standard: Id, Name, Type, Industry, OwnerId, ParentId, Website, Phone, CreatedDate,\n' +
        '  LastModifiedDate, CurrencyIsoCode, RecordTypeId, AnnualRevenue, NumberOfEmployees,\n' +
        '  Description, BillingCity, BillingState, BillingCountry\n\n' +
        'Picklist: Business_Unit__c(Commercial South/North|Africa|APAC|ME|Europe|etc),\n' +
        '  Account_Category__c, Account_Status__c, Customer_Type__c, Customer_sentiment__c,\n' +
        '  Customer_Service_Type__c, Cluster__c, Sub_Cluster__c, Region__c, Geography__c,\n' +
        '  Country__c, Nature_of_Business_Category__c(Vertical), Nature_of_Business_Sub_category__c(Sub Vertical),\n' +
        '  Product__c, Setup_Type__c, Status__c, RAG__c(Red/Amber/Green), Support_Group__c,\n' +
        '  Cogno_Support_Group__c, Funding_Type__c, Partner_Type__c, Partner_Stages__c,\n' +
        '  Hypercare_active__c, Release_Version__c\n' +
        'Multi-Picklist(INCLUDES): Customer_Stage__c, Product_UseCase__c\n' +
        'Number: Revenue_Growth__c, CSAT__c, NPS_Score__c, Expansion_Potential__c,\n' +
        '  Support_Ticket_Inflow__c, Seats_Count__c\n' +
        'Date: Go_Live_Date__c, B_Deal_Date__c, Last_Revenue_Date__c, AMC_Expiry_Date__c\n' +
        'DateTime: Hypercare_Start_Date__c, Hypercare_End_Date__c\n' +
        'Checkbox: Is_ABM__c, Is_SAAS_Premium_Account__c, Top_Customer__c, SAAS_Enterprise_Account__c\n' +
        'Lookup: Account_CSM__c(User), APC_Primary_Owner__c(User), APC_Secondary_Owner__c(User),\n' +
        '  APC_TL_Owner__c(User), Universal_Account__c(Account)\n' +
        'Formula(NO GROUP BY): Churned_Day__c(Number NOT date)\n' +
        'RecordTypes: AI Account, Customer Account, Group Account, Partnership Account,\n' +
        '  PF Account, Prospect Account, Setup Account, Tenant Account\n\n' +
        '=== LEAD (307 fields) ===\n' +
        'Standard: Id, Name, FirstName, LastName, Company, Status, LeadSource, OwnerId,\n' +
        '  CreatedDate, LastModifiedDate, IsConverted, ConvertedDate, ConvertedAccountId,\n' +
        '  ConvertedContactId, ConvertedOpportunityId, Email, Phone, Industry, CurrencyIsoCode, RecordTypeId\n\n' +
        'Picklist: Lead_Type__c, Lead_Cluster__c, Geography__c, Campaign_Type__c, Deal_Circle__c,\n' +
        '  Deal_Status__c, Sales_Stage__c, Department__c, Persona__c, Seniority__c,\n' +
        '  Call_Status__c, Lead_Forecast_Category__c, Qualified_Deal__c, Reason_For_Dead__c,\n' +
        '  Nurture_Required__c, Current_CRM__c, CRM_Requested__c, Authority_c__c\n' +
        'Multi-Picklist(INCLUDES): Product__c, Customer_Use_Case__c, Competition__c,\n' +
        '  Type_of_Solution__c, PBX_Integration__c, Formfilling_Product__c\n' +
        'Number: MRR_Amount__c, One_Time_Amount__c, Budget_Amount__c, Number_of_seats__c\n' +
        'Date: Lead_Closure_Date__c, Future_Action_Date__c\n' +
        'Text: UTM_Campaign__c, UTM_Source__c, UTM_Medium__c, UTM_Content__c, UTM_Term__c,\n' +
        '  Lead_Number__c(AutoNumber)\n' +
        'Lookup: Campaign__c(Campaign), Account_Name__c(Account), Lead_Co_Owner__c(User),\n' +
        '  Product_Sale_Specialist__c(User)\n' +
        'SDR leads: Owner.UserRole.Name LIKE \'%SDR%\'\n' +
        'SDR-generated opps: LeadSource = \'IS Generated\'\n' +
        'ChatGPT leads: LeadSource = \'Answer Engine\', UTM_Campaign__c = \'chatgpt.com\'\n' +
        'RecordTypes: Inbound IS, InsideSales/Mkt, Sales\n\n' +
        '=== USER ROLES (for team filtering via Owner.UserRole.Name) ===\n' +
        'Sales: Sales Head, Sales_BFSI/DNa/GSI/MRE/R&D/T&L/Technology + Manager variants\n' +
        'CX: CX_BFSI/DNa/GSI/MRE/R&D/T&L/Technology + Managers. CSM: CSM Head/Manager/User/Africa/ME/ROW/Indonesia/UAE\n' +
        'SDR: Domestic SDR, International SDR, Sales Development Head, Domestic/International SD Manager\n' +
        'Support: SAAS Engineer/Manager/TL, Ameyo Care Engineer/Manager/TL, APC AOC Support Engineer/TL/Manager\n' +
        'Presales: ECC Presales + FM&SME/Govt&IT/INT&Central/Strategic Large/Traditional&BFSI\n' +
        'International: International Sales Head/ME/Africa/APAC Phil/ROAPAC, ME/Africa Sales TL/User\n' +
        'Others: AI GTM Head/Manager/User, Platform GTM, Cogno Head/Manager/Cogno_Sales, CRO, Super User\n\n' +
        '=== PRODUCT NAME DICTIONARY ===\n' +
        'Product_Type__c(Opp) is multi-picklist. Map casual names to EXACT values using INCLUDES:\n' +
        '"voicebot"→INCLUDES(\'Conversational_AI-Voicebot\',\'Technology-Cogno_Voicebot\')\n' +
        '"chatbot"→INCLUDES(\'Conversational_AI-Chatbot\',\'Technology-Cogno_Chatbot\',\'AI - Chat Bot\')\n' +
        '"contact center"/"CC"/"Ameyo"→INCLUDES(\'Enterprise_CC-Ameyo\',\'Enterprise_CC-Ameyo_On_Cloud\',\n' +
        '  \'Enterprise_CC-Ameyo_Fusion_CX\',\'ECC_Ameyo_Emerge\',\'ECC_Ameyo_Engage\',\'ECC_Ameyo_Omni\',\n' +
        '  \'ECC_Ameyo_Fusion_CX\',\'CC - Ameyo On Cloud\')\n' +
        '"Emerge"→INCLUDES(\'ECC_Ameyo_Emerge\',\'Enterprise_CC-Ameyo Emerge\')\n' +
        '"XPress"→(\'Technology-Ameyo_XPress\'),"XPrime"→(\'Technology-Ameyo_XPrime\'),"XPro"→(\'Technology-Ameyo_XPro\')\n' +
        '"CQA"/"quality analytics"→INCLUDES(\'Technology-Cogno_CQA\')\n' +
        '"campaign"→INCLUDES(\'Conversational_AI-Campaign\')\n' +
        '"live chat"/"co-browse"→INCLUDES(\'Conversational_AI-Live_Chat/Co_browsing\')\n' +
        '"Truecaller"→INCLUDES(\'Truecaller\',\'PF_Others_TC_Truecaller\')\n' +
        '"WhatsApp"→INCLUDES(\'Digital_WhatsApp\',\'PF_Messaging_WhatsApp-Whatsapp\',\'Platform-Whatsapp_Voice\',\'PF Messaging - WhatsApp API\')\n' +
        '"SMS"→INCLUDES(\'Digital_Commit SMS\',\'Digital_Without_Commit SMS\',\'Digital-SMS\',\'PF_Messaging_SMS-SMS\')\n' +
        '"voice"/"platform voice"(NOT voicebot)→INCLUDES(\'PF_Voice-Consumption\',\'PF_Voice-Voice\',\n' +
        '  \'PF_Voice-C2C_(CRM)\',\'PF_Voice-Lead_Assist\',\'PF_Voice-Number_Masking\',\'PF_Voice-App2App\',\'PF_Voice-Voice_Blast\')\n' +
        '"Exoinsights"/"speech analytics"→INCLUDES(\'Technology-Cogno_Exoinsights\',\'Speech Log Analytics\')\n' +
        '"Cogno Omni"/"omnichannel"→INCLUDES(\'Conversational_AI-Cogno_Omni\',\'ECC_Ameyo_Omni\')\n\n' +
        '=== LOST DEALS RULE ===\n' +
        'ALWAYS include ALL lost stages for loss queries:\n' +
        '  StageName IN (\'Closed Lost\',\'Closed-No decision\',\'Closed Unknown\',\'Closed Duplicate\',\'Rejected\',\'SDF Rejected\')\n' +
        'NEVER use just StageName=\'Closed Lost\' alone — misses 40-50% of losses.\n\n' +
        '=== DO NOT USE (non-existent fields) ===\n' +
        'MTTR__c, MTTR_Without_Start_Stop__c, Closed_Won(stage), Total_Contract_Value__c,\n' +
        'Annual_Revenue__c(on Opp), Contract_Length__c, Renewal_Date__c(on Opp),\n' +
        'Territory__c(on Opp), Team__c, Department__c(on Opp), Segment__c(on Opp)\n\n' +
        '=== SOQL GOTCHAS ===\n' +
        '1. Multi-picklist: INCLUDES/EXCLUDES infix only. WRONG: INCLUDES(field,val). WRONG: NOT INCLUDES.\n' +
        '2. No alias in ORDER BY. WRONG: ORDER BY total. RIGHT: ORDER BY COUNT(Id) DESC.\n' +
        '3. Won=StageName=\'Order\', NEVER \'Closed Won\'.\n' +
        '4. FY/quarters=explicit dates, NOT fiscal literals. LAST_N_DAYS OK.\n' +
        '5. MRR_Amount__c is NUMBER — no convertCurrency().\n' +
        '6. Owner role: Owner.UserRole.Name. 7. Description: no LIKE filter.\n' +
        '8. Subject: no GROUP BY. 9. No CASE/WHEN or IF/ELSE in SOQL.\n' +
        '10. No arithmetic in SELECT (no Amount*83.33). Fetch raw, let summary compute.\n' +
        '11. DUPLICATE ALIAS: Multiple relationship fields ending with same name cause "duplicate alias" error.\n' +
        '    WRONG: SELECT Owner.Name, Owner.UserRole.Name — both alias to "Name".\n' +
        '    RIGHT: SELECT Owner.Name ownerName, Owner.UserRole.Name roleName.\n' +
        '    ALSO: Account.Name acctName, Owner.Name ownerName; Contact.Name contactName, Account.Name acctName.\n' +
        '    RULE: Whenever you have 2+ relationship fields ending in the same field (Name, Id, Email, etc.), you MUST add explicit aliases.\n' +
        '12. Aggregate queries CANNOT select non-grouped non-aggregated fields. Every non-aggregate field in SELECT MUST be in GROUP BY.\n' +
        '13. NULL comparison: use = null or != null. NEVER = \'null\' or LIKE null or = \'\'.\n' +
        '14. HAVING: only with aggregate filters. WRONG: HAVING StageName=X. RIGHT: HAVING COUNT(Id) > 5.\n' +
        '15. OFFSET max 2000. LIMIT max 2000. OFFSET+LIMIT cannot exceed 2000.\n' +
        '16. Cannot use LIMIT with aggregate queries that have no GROUP BY.\n' +
        '17. Date literals in WHERE must match field type. Date fields: 2026-01-15. DateTime fields: 2026-01-15T00:00:00Z. NEVER mix.\n' +
        '18. COUNT(fieldName) excludes nulls. COUNT() counts all rows. Use COUNT() for total row counts.\n' +
        '19. toLabel() cannot be used in WHERE or ORDER BY. Use picklist API values in filters.\n' +
        '20. Relationship queries max 5 levels. Owner.UserRole.Name is OK (3 levels). Deeper nesting will fail.';

    private static final String SUMMARY_SYSTEM_PROMPT =
        'You are a senior business analyst at Exotel. Think like a VP of Sales reviewing data — don\'t just restate numbers, ANALYZE them.\n\n' +
        'HOW TO ANSWER:\n' +
        '- Lead with the key insight or headline finding, not a data dump.\n' +
        '- Group and categorize data (by region, loss reason, owner, segment, etc.) to reveal patterns.\n' +
        '- Identify what stands out: concentrations, outliers, concerning trends, or bright spots.\n' +
        '- End with a clear "Key Takeaway" or "Action Items" section with specific, actionable recommendations.\n' +
        '- Use tables for structured data (deal lists, breakdowns). Use bullet points for insights.\n' +
        '- If the dataset is small, name specific accounts and deals — don\'t just say "1 deal was lost".\n' +
        '- If the dataset seems unusually small, call it out (e.g. "Only 2 deals matched — this may indicate a data tagging gap").\n' +
        '- ACCURACY FIRST: The SOQL may fetch a wider date range than asked. Always clearly separate data that falls within the user\'s exact timeframe vs edge-case records (e.g. "Within the last 6 months: X deals. Additionally, 1 deal with a future close date of Mar 15 is already marked lost.").\n' +
        '- Never inflate counts or totals — be transparent about what you include and why.\n\n' +
        'CURRENCY RULES: Indian deals (CurrencyIsoCode=INR) MUST be shown in INR (₹). ' +
        'International deals (CurrencyIsoCode=USD/AED) MUST be shown in USD ($). ' +
        'Never convert INR to USD or vice versa. Show each segment in its native currency.\n\n' +
        'QUARTER DEFINITIONS: Q1=Apr-Jun, Q2=Jul-Sep, Q3=Oct-Dec, Q4=Jan-Mar. FY runs April to March.\n\n' +
        'Keep summary under 500 words. Be concise, specific, and actionable.';

    @AuraEnabled
    public static AssistantResponse askQuestion(String userQuestion, String conversationContext) {
        Long startTime = System.currentTimeMillis();
        AssistantResponse resp = new AssistantResponse();
        String initialSoql = null;
        Integer retryCount = 0;
        String errorType = null;

        try {
            // Input validation
            if (String.isBlank(userQuestion)) {
                resp.success = false;
                resp.errorMessage = 'Please enter a question.';
                errorType = 'INPUT_ERROR';
                resp.executionTimeMs = System.currentTimeMillis() - startTime;
                logQuery(userQuestion, null, null, 0, false, resp.errorMessage, errorType, null, resp.executionTimeMs);
                return resp;
            }
            if (userQuestion.length() > 1000) {
                resp.success = false;
                resp.errorMessage = 'Question is too long. Please keep it under 1000 characters.';
                errorType = 'INPUT_ERROR';
                resp.executionTimeMs = System.currentTimeMillis() - startTime;
                logQuery(userQuestion, null, null, 0, false, resp.errorMessage, errorType, null, resp.executionTimeMs);
                return resp;
            }

            // Inject today's date so the LLM can determine the current FY/quarter
            Date today = Date.today();
            Integer fyStartYear = today.month() >= 4 ? today.year() : today.year() - 1;
            String dateContext = '\n[Today is ' + String.valueOf(today) +
                '. Current FY started ' + fyStartYear + '-04-01.]';
            String enrichedQuestion = userQuestion + dateContext;

            // Prepend full conversation history so Claude can resolve follow-ups
            if (String.isNotBlank(conversationContext)) {
                String ctx = conversationContext.length() > 4000
                    ? '...' + conversationContext.substring(conversationContext.length() - 4000)
                    : conversationContext;
                enrichedQuestion = '[Conversation history]\n' + ctx +
                    '\n\n[Current question]\n' + enrichedQuestion;
            }

            // Step 1: Generate SOQL via Claude
            ClaudeApiService.ClaudeResponse soqlResponse =
                ClaudeApiService.sendMessage(SOQL_SYSTEM_PROMPT, enrichedQuestion, 8192);

            // Step 2: Extract and sanitize SOQL
            String soql = SoqlSanitizer.extractSoql(soqlResponse.content);
            initialSoql = soql;
            resp.soqlQuery = soql;

            // Step 3: Validate allowed object
            if (!SoqlSanitizer.isAllowedObject(soql)) {
                throw new AuraHandledException('This query targets a restricted object. Please ask about Opportunities, Accounts, Leads, Cases, or Contacts.');
            }

            // Step 4: Execute SOQL with self-correction retry (up to 2 retries)
            List<SObject> results;
            System.QueryException lastQueryError = null;

            for (Integer attempt = 0; attempt < 3; attempt++) {
                try {
                    results = Database.query(soql);
                    lastQueryError = null;
                    break; // Query succeeded
                } catch (System.QueryException e) {
                    lastQueryError = e;
                    if (attempt < 2) {
                        retryCount++;
                        // Self-correct: send the error back to Claude to fix
                        try {
                            String fixPrompt =
                                'Your SOQL query failed. Analyze the error and return a CORRECTED query.\n' +
                                'Error: ' + e.getMessage() + '\n' +
                                'Failed query: ' + soql + '\n' +
                                'Original request: ' + enrichedQuestion + '\n' +
                                'Return ONLY the fixed SOQL in ```soql ``` code blocks.';
                            ClaudeApiService.ClaudeResponse fixResp =
                                ClaudeApiService.sendMessage(SOQL_SYSTEM_PROMPT, fixPrompt, 8192);
                            String fixedSoql = SoqlSanitizer.extractSoql(fixResp.content);
                            if (!SoqlSanitizer.isAllowedObject(fixedSoql)) {
                                break;
                            }
                            soql = fixedSoql;
                            resp.soqlQuery = soql;
                        } catch (Exception retryEx) {
                            break;
                        }
                    }
                }
            }

            if (lastQueryError != null) {
                throw lastQueryError;
            }

            resp.recordCount = results.size();

            // Step 5: Summarize results via Claude
            String resultsJson = JSON.serialize(results);

            if (resultsJson.length() > 80000) {
                resultsJson = resultsJson.substring(0, 80000) + '\n... [TRUNCATED - ' + results.size() + ' total records]';
            }

            List<Map<String, String>> conversation = new List<Map<String, String>>();
            conversation.add(new Map<String, String>{
                'role' => 'user',
                'content' => userQuestion
            });
            conversation.add(new Map<String, String>{
                'role' => 'assistant',
                'content' => 'I executed this SOQL: ' + soql + '\nReturned ' + results.size() + ' records.'
            });
            conversation.add(new Map<String, String>{
                'role' => 'user',
                'content' => 'Here are the results (' + results.size() + ' records). Provide a business summary:\n\n' + resultsJson
            });

            ClaudeApiService.ClaudeResponse summaryResponse =
                ClaudeApiService.sendConversation(SUMMARY_SYSTEM_PROMPT, conversation, 8192);

            resp.answer = summaryResponse.content;
            resp.success = true;

        } catch (SoqlSanitizer.SoqlValidationException e) {
            resp.success = false;
            resp.errorMessage = 'Could not generate a valid query. Try rephrasing your question. (' + e.getMessage() + ')';
            errorType = 'SOQL_VALIDATION';
        } catch (System.QueryException e) {
            resp.success = false;
            resp.errorMessage = 'Query error: ' + e.getMessage() + (resp.soqlQuery != null ? '\nGenerated SOQL: ' + resp.soqlQuery : '');
            errorType = 'QUERY_ERROR';
        } catch (ClaudeApiService.ClaudeException e) {
            resp.success = false;
            resp.errorMessage = 'AI service error: ' + e.getMessage();
            errorType = 'API_ERROR';
        } catch (System.CalloutException e) {
            resp.success = false;
            resp.errorMessage = 'Could not reach the AI service. Please try again in a moment.';
            errorType = 'CALLOUT_ERROR';
        } catch (Exception e) {
            resp.success = false;
            resp.errorMessage = 'Unexpected error: ' + e.getMessage();
            errorType = 'UNKNOWN';
        }

        resp.executionTimeMs = System.currentTimeMillis() - startTime;

        // Log every query for analytics
        logQuery(userQuestion, initialSoql, resp.soqlQuery, retryCount,
                 resp.success == true, resp.errorMessage, errorType,
                 resp.recordCount, resp.executionTimeMs);

        return resp;
    }

    /**
     * Logs query to AI_Query_Log__c for analytics. Failures silently caught
     * so logging never breaks the main flow.
     */
    private static void logQuery(String question, String initialSoql, String finalSoql,
                                  Integer retryCount, Boolean success, String errorMessage,
                                  String errorType, Integer recordCount, Long executionTimeMs) {
        try {
            AI_Query_Log__c log = new AI_Query_Log__c(
                Question__c = question != null ? question.abbreviate(5000) : null,
                Initial_SOQL__c = initialSoql != null ? initialSoql.abbreviate(5000) : null,
                Final_SOQL__c = finalSoql != null ? finalSoql.abbreviate(5000) : null,
                Retry_Count__c = retryCount,
                Success__c = success,
                Error_Message__c = errorMessage != null ? errorMessage.abbreviate(5000) : null,
                Error_Type__c = errorType,
                Record_Count__c = recordCount,
                Execution_Time_Ms__c = executionTimeMs,
                Batch_Id__c = currentBatchId
            );
            insert log;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to log query: ' + e.getMessage());
        }
    }
}
