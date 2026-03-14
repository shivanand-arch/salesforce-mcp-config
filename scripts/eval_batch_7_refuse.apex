// Eval Batch 7: Should Refuse / Redirect (REV-36 to REV-40)
// Run: sf apex run -f scripts/eval_batch_7_refuse.apex -o ameyo

List<List<String>> evals = new List<List<String>>{
    new List<String>{'REV-36', 'What are our account credits?', 'BLOCK', 'refuse'},
    new List<String>{'REV-37', 'Show the booking to revenue journey', 'BLOCK', 'refuse'},
    new List<String>{'REV-38', 'What is our PF QuickSight call volume?', 'BLOCK', 'refuse'},
    new List<String>{'REV-39', 'Show revenue AND account credits together', 'accounts_revenue__c', 'refuse'},
    new List<String>{'REV-40', 'What is our NRR this quarter?', 'accounts_revenue__c', 'refuse'}
};

System.debug('========== EVAL BATCH 7: REFUSE/REDIRECT ==========');
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

        if (expectedObject == 'BLOCK') {
            // Should have been blocked - check for template message
            domainPass = resp.success && resp.recordCount == 0
                && (resp.answer != null && (
                    resp.answer.contains('QuickSight')
                    || resp.answer.contains('Tableau Prep')
                    || resp.answer.contains('not available')
                    || resp.answer.contains('not in Salesforce')
                    || resp.answer.contains('AWS')
                    || resp.answer.contains('external')
                ));
            System.debug('BLOCK check: ' + (domainPass ? 'PASS' : 'FAIL'));
        } else if (resp.soqlQuery != null) {
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
System.debug('\n=== BATCH 7 SUMMARY: ' + passed + '/' + evals.size() + ' passed, ' + failed + ' failed, ' + errors + ' errors ===');
