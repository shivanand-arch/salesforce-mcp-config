@isTest
private class StressTestRunnerTest {

    private static void setupTestConfig() {
        ClaudeApiService.testConfig = new AI_Assistant_Config__mdt(
            DeveloperName = 'Gemini_API',
            API_Key__c = 'test-api-key-12345',
            Model_Name__c = 'claude-sonnet-4-6',
            Max_Tokens__c = 4096
        );
    }

    private class MockClaudeSuccess implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            if (Math.mod(callCount, 2) == 1) {
                // Odd calls: SOQL generation
                res.setBody('{"id":"msg_01","type":"message","role":"assistant","content":[{"type":"text","text":"```soql\\nSELECT Id, Name FROM Account LIMIT 5\\n```"}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":100,"output_tokens":50}}');
            } else {
                // Even calls: Summary
                res.setBody('{"id":"msg_02","type":"message","role":"assistant","content":[{"type":"text","text":"Found 5 accounts."}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":200,"output_tokens":30}}');
            }
            return res;
        }
    }

    @isTest
    static void testGetAllQuestions() {
        List<String> questions = StressTestRunner.getAllQuestions();
        System.assertEquals(75, questions.size(), 'Should have 75 stress test questions');
        for (String q : questions) {
            System.assert(String.isNotBlank(q), 'No blank questions allowed');
        }
    }

    @isTest
    static void testGetCategoryMap() {
        Map<String, List<Integer>> cats = StressTestRunner.getCategoryMap();
        System.assertEquals(7, cats.size(), 'Should have 7 categories');
        System.assert(cats.containsKey('pipeline'), 'Should have pipeline category');
        System.assert(cats.containsKey('sdr'), 'Should have sdr category');
        System.assert(cats.containsKey('loss'), 'Should have loss category');
        System.assert(cats.containsKey('case'), 'Should have case category');
        System.assert(cats.containsKey('account'), 'Should have account category');
        System.assert(cats.containsKey('international'), 'Should have international category');
        System.assert(cats.containsKey('complex'), 'Should have complex category');
    }

    @isTest
    static void testRunSingle() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeSuccess());

        Test.startTest();
        Id jobId = StressTestRunner.runSingle(0);
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Should return job ID');

        // Verify log was created
        List<AI_Query_Log__c> logs = [
            SELECT Question__c, Success__c, Batch_Id__c
            FROM AI_Query_Log__c
            WHERE Batch_Id__c LIKE 'STRESS-%'
        ];
        System.assertEquals(1, logs.size(), 'Should have 1 log entry');
        System.assert(logs[0].Batch_Id__c.startsWith('STRESS-SINGLE-'), 'Batch ID should be STRESS-SINGLE-*');
    }

    @isTest
    static void testRunSingleInvalidIndex() {
        Id jobId = StressTestRunner.runSingle(-1);
        System.assertEquals(null, jobId, 'Should return null for invalid index');

        jobId = StressTestRunner.runSingle(999);
        System.assertEquals(null, jobId, 'Should return null for out-of-range index');
    }

    @isTest
    static void testRunCategoryInvalid() {
        Id jobId = StressTestRunner.runCategory('nonexistent');
        System.assertEquals(null, jobId, 'Should return null for invalid category');
    }

    @isTest
    static void testQueryLogging() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeSuccess());

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('Show me some accounts', null);
        Test.stopTest();

        // Verify log was created
        List<AI_Query_Log__c> logs = [
            SELECT Question__c, Initial_SOQL__c, Final_SOQL__c, Retry_Count__c,
                   Success__c, Error_Type__c, Execution_Time_Ms__c, Record_Count__c
            FROM AI_Query_Log__c
        ];
        System.assertEquals(1, logs.size(), 'Should have 1 log entry');
        System.assertEquals('Show me some accounts', logs[0].Question__c);
        System.assertEquals(true, logs[0].Success__c);
        System.assertEquals(0, logs[0].Retry_Count__c);
        System.assertNotEquals(null, logs[0].Execution_Time_Ms__c);
    }

    @isTest
    static void testQueryLoggingOnError() {
        setupTestConfig();

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('', null);
        Test.stopTest();

        List<AI_Query_Log__c> logs = [
            SELECT Question__c, Success__c, Error_Type__c, Error_Message__c
            FROM AI_Query_Log__c
        ];
        System.assertEquals(1, logs.size(), 'Should log even on input error');
        System.assertEquals(false, logs[0].Success__c);
        System.assertEquals('INPUT_ERROR', logs[0].Error_Type__c);
    }

    @isTest
    static void testPrintAnalytics() {
        // Create sample log records
        List<AI_Query_Log__c> logs = new List<AI_Query_Log__c>();
        for (Integer i = 0; i < 5; i++) {
            logs.add(new AI_Query_Log__c(
                Question__c = 'Test question ' + i,
                Success__c = i < 4, // 4 success, 1 failure
                Retry_Count__c = i == 2 ? 1 : 0,
                Error_Type__c = i == 4 ? 'QUERY_ERROR' : null,
                Error_Message__c = i == 4 ? 'Test error' : null,
                Execution_Time_Ms__c = 1000 + (i * 500),
                Batch_Id__c = 'STRESS-TEST-123'
            ));
        }
        insert logs;

        Test.startTest();
        // Should not throw
        StressTestRunner.printAnalytics('STRESS-TEST-123');
        StressTestRunner.printAnalytics(null); // All stress tests
        Test.stopTest();
    }
}
