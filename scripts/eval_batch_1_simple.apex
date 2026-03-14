// Eval Batch 1: Simple Totals (REV-01 to REV-05)
// Run: sf apex run -f scripts/eval_batch_1_simple.apex -o ameyo

List<List<String>> evals = new List<List<String>>{
    new List<String>{'REV-01', 'What is our total revenue this financial year?', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-02', 'How much GP did we make in Q3?', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-03', 'Total variable cost this year', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-04', 'What is revenue for March 2026?', 'accounts_revenue__c', 'simple_total'},
    new List<String>{'REV-05', 'Show me total fixed cost and variable cost for H1', 'accounts_revenue__c', 'simple_total'}
};

System.debug('========== EVAL BATCH 1: SIMPLE TOTALS ==========');
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
System.debug('\n=== BATCH 1 SUMMARY: ' + passed + '/' + evals.size() + ' passed, ' + failed + ' failed, ' + errors + ' errors ===');
