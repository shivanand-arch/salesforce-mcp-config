// ============================================================
// Revenue Domain Eval Runner — Baseline for #4 Structured Planner
// Run: sf apex run -f scripts/run_revenue_eval.apex -o ameyo
// ============================================================
// Calls askQuestion() for each eval question, captures SOQL + answer,
// and logs a structured grading report. Does NOT modify any data.
//
// OUTPUT: Check debug logs at Setup > Debug Logs (set AiSalesAssistantController
// to FINE level) or use: sf apex tail log -o ameyo
// ============================================================

// --- Eval Questions ---
// Each entry: [id, question, expectedObject, category]
// Full grading (measures, dimensions, filters) is done manually from the output.

List<List<String>> evals = new List<List<String>>{
    // Category 1: Simple Totals
    new List<String>{'REV-01', 'What is our total revenue this financial year?', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-02', 'How much GP did we make in Q3?', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-03', 'Total variable cost this year', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-04', 'What is revenue for March 2026?', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-05', 'Show me total fixed cost and variable cost for H1', 'accounts_revenue__c', 'simple_total'},

    // Category 2: Grouped by Dimension
    new List<String>{'REV-06', 'Revenue by cluster this FY', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-07', 'GP by SKU for Q4', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-08', 'Revenue by region and cluster this year', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-09', 'Show revenue by product type for last quarter', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-10', 'Revenue by account manager this FY', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-11', 'Top 10 customers by revenue this year', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-12', 'GP by revenue classification for Q2', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-13', 'Revenue split by currency this FY', 'accounts_revenue__c', 'grouped'},

    // Category 3: Filtered Queries
    new List<String>{'REV-14', 'Revenue for Voice SKU this year', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-15', 'GP by cluster for Enterprise CC only', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-16', 'Revenue for BFSI cluster in Q3', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-17', 'Show revenue for international region this FY', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-18', 'Revenue where classification is New Sales', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-19', 'Top 5 CSMs by GP this year', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-20', 'Revenue for accounts managed by Sahil', 'accounts_revenue__c', 'filtered'},

    // Category 4: Date Edge Cases
    new List<String>{'REV-21', 'Revenue last month', 'accounts_revenue__c', 'date_edge'},
    new List<String>{'REV-22', 'Compare Q1 and Q2 revenue', 'accounts_revenue__c', 'date_edge'},
    new List<String>{'REV-23', 'Revenue YTD vs same period last year', 'accounts_revenue__c', 'date_edge'},
    new List<String>{'REV-24', 'Show monthly revenue trend for this FY', 'accounts_revenue__c', 'date_edge'},
    new List<String>{'REV-25', 'Revenue for January to March 2026', 'accounts_revenue__c', 'date_edge'},

    // Category 5: Large-Object Safety
    new List<String>{'REV-26', 'Revenue by cluster for full FY 2024-25', 'accounts_revenue__c', 'large_object'},
    new List<String>{'REV-27', 'Revenue for last 2 years', 'accounts_revenue__c', 'large_object'},
    new List<String>{'REV-28', 'Revenue for September 2025', 'accounts_revenue__c', 'large_object'},
    new List<String>{'REV-29', 'Revenue by SKU for H2 FY 2025-26', 'accounts_revenue__c', 'large_object'},

    // Category 6: Ambiguous Phrasings
    new List<String>{'REV-30', 'How much did we earn from retail?', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-31', 'What is our margin by sector?', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-32', 'Show me the numbers for APAC', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-33', 'How are we doing on costs?', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-34', 'Break down this years GP by parent sku', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-35', 'Revenue performance across regions', 'accounts_revenue__c', 'ambiguous'},

    // Category 7: Should Refuse / Redirect
    new List<String>{'REV-36', 'What are our account credits?', 'BLOCK', 'refuse'},
    new List<String>{'REV-37', 'Show the booking to revenue journey', 'BLOCK', 'refuse'},
    new List<String>{'REV-38', 'What is our PF QuickSight call volume?', 'BLOCK', 'refuse'},
    new List<String>{'REV-39', 'Show revenue AND account credits together', 'accounts_revenue__c', 'refuse'},
    new List<String>{'REV-40', 'What is our NRR this quarter?', 'accounts_revenue__c', 'refuse'}
};

// --- Run Evals ---
System.debug('========== REVENUE EVAL BASELINE ==========');
System.debug('Run date: ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
System.debug('Total evals: ' + evals.size());
System.debug('===========================================');

Integer passed = 0;
Integer failed = 0;
Integer errors = 0;

for (List<String> eval : evals) {
    String evalId = eval[0];
    String question = eval[1];
    String expectedObject = eval[2];
    String category = eval[3];

    System.debug('\n--- ' + evalId + ' [' + category + '] ---');
    System.debug('Q: ' + question);
    System.debug('Expected object: ' + expectedObject);

    try {
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion(question, null);

        // Grade: Domain / Object
        String actualObject = '';
        Boolean domainPass = false;

        if (expectedObject == 'BLOCK') {
            // Should have been blocked — check for template message
            domainPass = resp.success && resp.recordCount == 0
                && (resp.answer != null && (
                    resp.answer.contains('QuickSight')
                    || resp.answer.contains('Tableau Prep')
                    || resp.answer.contains('not available')
                    || resp.answer.contains('not in Salesforce')
                ));
            System.debug('BLOCK check: ' + (domainPass ? 'PASS' : 'FAIL'));
        } else if (resp.soqlQuery != null) {
            actualObject = SoqlSanitizer.extractObjectName(resp.soqlQuery);
            domainPass = (actualObject != null && actualObject.equalsIgnoreCase(expectedObject));
            System.debug('Object: ' + actualObject + ' → ' + (domainPass ? 'PASS' : 'FAIL'));
        } else {
            System.debug('Object: NO SOQL GENERATED → FAIL');
        }

        // Log full output
        System.debug('Success: ' + resp.success);
        System.debug('Records: ' + resp.recordCount);
        System.debug('Time: ' + resp.executionTimeMs + 'ms');
        System.debug('SOQL: ' + (resp.soqlQuery != null ? resp.soqlQuery.abbreviate(500) : 'null'));
        System.debug('Answer: ' + (resp.answer != null ? resp.answer.abbreviate(300) : 'null'));

        // Check for multi-query (auto-split indicator)
        if (resp.soqlQuery != null && resp.soqlQuery.contains('---')) {
            Integer queryCount = resp.soqlQuery.split('---').size();
            System.debug('Multi-query: ' + queryCount + ' queries');
        }

        if (domainPass) {
            passed++;
            System.debug('RESULT: PASS');
        } else {
            failed++;
            System.debug('RESULT: FAIL');
        }

    } catch (Exception e) {
        errors++;
        System.debug('RESULT: ERROR — ' + e.getMessage());
    }
}

System.debug('\n========== EVAL SUMMARY ==========');
System.debug('Passed: ' + passed + '/' + evals.size());
System.debug('Failed: ' + failed + '/' + evals.size());
System.debug('Errors: ' + errors + '/' + evals.size());
System.debug('Domain accuracy: ' + (evals.size() > 0 ? String.valueOf((passed * 100) / evals.size()) : '0') + '%');
System.debug('==================================');
