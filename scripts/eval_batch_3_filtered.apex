// Eval Batch 3: Filtered Queries (REV-14 to REV-20)
// Run: sf apex run -f scripts/eval_batch_3_filtered.apex -o ameyo

List<List<String>> evals = new List<List<String>>{
    new List<String>{'REV-14', 'Revenue for Voice SKU this year', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-15', 'GP by cluster for Enterprise CC only', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-16', 'Revenue for BFSI cluster in Q3', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-17', 'Show revenue for international region this FY', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-18', 'Revenue where classification is New Sales', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-19', 'Top 5 CSMs by GP this year', 'accounts_revenue__c', 'filtered'},
    new List<String>{'REV-20', 'Revenue for accounts managed by Sahil', 'accounts_revenue__c', 'filtered'}
};

System.debug('========== EVAL BATCH 3: FILTERED ==========');
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
System.debug('\n=== BATCH 3 SUMMARY: ' + passed + '/' + evals.size() + ' passed, ' + failed + ' failed, ' + errors + ' errors ===');
