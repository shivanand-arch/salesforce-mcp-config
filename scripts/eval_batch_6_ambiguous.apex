// Eval Batch 6: Ambiguous Phrasings (REV-30 to REV-35)
// Run: sf apex run -f scripts/eval_batch_6_ambiguous.apex -o ameyo

List<List<String>> evals = new List<List<String>>{
    new List<String>{'REV-30', 'How much did we earn from retail?', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-31', 'What is our margin by sector?', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-32', 'Show me the numbers for APAC', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-33', 'How are we doing on costs?', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-34', 'Break down this years GP by parent sku', 'accounts_revenue__c', 'ambiguous'},
    new List<String>{'REV-35', 'Revenue performance across regions', 'accounts_revenue__c', 'ambiguous'}
};

System.debug('========== EVAL BATCH 6: AMBIGUOUS ==========');
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
System.debug('\n=== BATCH 6 SUMMARY: ' + passed + '/' + evals.size() + ' passed, ' + failed + ' failed, ' + errors + ' errors ===');
