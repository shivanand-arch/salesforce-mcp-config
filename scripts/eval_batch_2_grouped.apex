// Eval Batch 2: Grouped by Dimension (REV-06 to REV-13)
// Run: sf apex run -f scripts/eval_batch_2_grouped.apex -o ameyo

List<List<String>> evals = new List<List<String>>{
    new List<String>{'REV-06', 'Revenue by cluster this FY', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-07', 'GP by SKU for Q4', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-08', 'Revenue by region and cluster this year', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-09', 'Show revenue by product type for last quarter', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-10', 'Revenue by account manager this FY', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-11', 'Top 10 customers by revenue this year', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-12', 'GP by revenue classification for Q2', 'accounts_revenue__c', 'grouped'},
    new List<String>{'REV-13', 'Revenue split by currency this FY', 'accounts_revenue__c', 'grouped'}
};

System.debug('========== EVAL BATCH 2: GROUPED ==========');
System.debug('Run date: ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
Integer passed = 0; Integer failed = 0; Integer errors = 0;

for (List<String> eval : evals) {
    String evalId = eval[0]; String question = eval[1];
    String expectedObject = eval[2]; String category = eval[3];
    System.debug('\n--- ' + evalId + ' [' + category + '] ---');
    System.debug('Q: ' + question);
    try {
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion(question, null);
        String actualObject = '';
        Boolean domainPass = false;
        if (resp.soqlQuery != null) {
            actualObject = SoqlSanitizer.extractObjectName(resp.soqlQuery);
            domainPass = (actualObject != null && actualObject.equalsIgnoreCase(expectedObject));
            System.debug('Object: ' + actualObject + ' -> ' + (domainPass ? 'PASS' : 'FAIL'));
        } else {
            System.debug('Object: NO SOQL GENERATED -> FAIL');
        }
        System.debug('Success: ' + resp.success);
        System.debug('Records: ' + resp.recordCount);
        System.debug('Time: ' + resp.executionTimeMs + 'ms');
        System.debug('SOQL: ' + (resp.soqlQuery != null ? resp.soqlQuery.abbreviate(500) : 'null'));
        System.debug('Answer: ' + (resp.answer != null ? resp.answer.abbreviate(300) : 'null'));
        if (resp.soqlQuery != null && resp.soqlQuery.contains('---')) {
            System.debug('Multi-query: ' + resp.soqlQuery.split('---').size() + ' queries');
        }
        if (domainPass) { passed++; System.debug('RESULT: PASS'); }
        else { failed++; System.debug('RESULT: FAIL'); }
    } catch (Exception e) {
        errors++;
        System.debug('RESULT: ERROR - ' + e.getMessage());
    }
}
System.debug('\n=== BATCH 2 SUMMARY: ' + passed + '/' + evals.size() + ' passed, ' + failed + ' failed, ' + errors + ' errors ===');
