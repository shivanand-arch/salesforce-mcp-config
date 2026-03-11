@isTest
private class AiSalesAssistantControllerTest {

    private static void setupTestConfig() {
        ClaudeApiService.testConfig = new AI_Assistant_Config__mdt(
            DeveloperName = 'Gemini_API',
            API_Key__c = 'test-api-key-12345',
            Model_Name__c = 'claude-sonnet-4-6',
            Max_Tokens__c = 4096
        );
    }

    /**
     * Multi-call mock: first call returns SOQL, second call returns summary.
     */
    private class MockClaudeTwoCalls implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            if (callCount == 1) {
                // First call: SOQL generation — use simple query that works in any org
                res.setBody('{"id":"msg_01","type":"message","role":"assistant","content":[{"type":"text","text":"```soql\\nSELECT Id, Name FROM Account LIMIT 5\\n```"}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":100,"output_tokens":50}}');
            } else {
                // Second call: Summary
                res.setBody('{"id":"msg_02","type":"message","role":"assistant","content":[{"type":"text","text":"I found 5 accounts in the system."}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":200,"output_tokens":30}}');
            }
            return res;
        }
    }

    private class MockClaudeInvalidSoql implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"msg_03","type":"message","role":"assistant","content":[{"type":"text","text":"I cannot generate a query for that request. Please provide more details."}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":100,"output_tokens":20}}');
            return res;
        }
    }

    /**
     * Mock that returns bad SOQL first (triggers retry), then fixed SOQL, then summary.
     */
    private class MockClaudeWithRetry implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            if (callCount == 1) {
                // First call: return SOQL with non-existent field to trigger QueryException
                res.setBody('{"id":"msg_01","type":"message","role":"assistant","content":[{"type":"text","text":"```soql\\nSELECT Id, ZZZ_No_Such_Field__c FROM Account LIMIT 5\\n```"}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":100,"output_tokens":50}}');
            } else if (callCount == 2) {
                // Retry call: return fixed SOQL
                res.setBody('{"id":"msg_02","type":"message","role":"assistant","content":[{"type":"text","text":"```soql\\nSELECT Id, Name FROM Account LIMIT 5\\n```"}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":100,"output_tokens":50}}');
            } else {
                // Summary call
                res.setBody('{"id":"msg_03","type":"message","role":"assistant","content":[{"type":"text","text":"After correcting the query, I found accounts in the system."}],"model":"claude-sonnet-4-6","stop_reason":"end_turn","usage":{"input_tokens":200,"output_tokens":30}}');
            }
            return res;
        }
    }

    private class MockClaudeApiFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"type":"error","error":{"type":"api_error","message":"Internal server error"}}');
            return res;
        }
    }

    @isTest
    static void testAskQuestion_Success() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeTwoCalls());

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('Show me some accounts', null);
        Test.stopTest();

        System.assertEquals(true, resp.success, 'Should succeed: ' + resp.errorMessage);
        System.assertNotEquals(null, resp.answer, 'Answer should not be null');
        System.assertNotEquals(null, resp.soqlQuery, 'SOQL should not be null');
        System.assert(resp.soqlQuery.contains('SELECT'), 'SOQL should contain SELECT');
        System.assertNotEquals(null, resp.executionTimeMs, 'Execution time should be set');
    }

    @isTest
    static void testAskQuestion_WithConversationContext() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeTwoCalls());

        String context = 'Q: Who are the most active SDRs?\nA: Sakshi Jadhav leads with 618 leads created this fiscal year.';

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('Who is the best performer among them?', context);
        Test.stopTest();

        System.assertEquals(true, resp.success, 'Should succeed with conversation context: ' + resp.errorMessage);
        System.assertNotEquals(null, resp.answer, 'Answer should not be null');
    }

    @isTest
    static void testAskQuestion_EmptyInput() {
        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('', null);
        Test.stopTest();

        System.assertEquals(false, resp.success, 'Should fail for empty input');
        System.assertNotEquals(null, resp.errorMessage, 'Should have error message');
        System.assert(resp.errorMessage.contains('enter a question'), 'Should ask to enter question: ' + resp.errorMessage);
    }

    @isTest
    static void testAskQuestion_NullInput() {
        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion(null, null);
        Test.stopTest();

        System.assertEquals(false, resp.success, 'Should fail for null input');
    }

    @isTest
    static void testAskQuestion_TooLongInput() {
        String longInput = '';
        for (Integer i = 0; i < 110; i++) {
            longInput += 'abcdefghij'; // 1100 characters
        }

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion(longInput, null);
        Test.stopTest();

        System.assertEquals(false, resp.success, 'Should fail for long input');
        System.assert(resp.errorMessage.contains('1000'), 'Should mention character limit: ' + resp.errorMessage);
    }

    @isTest
    static void testAskQuestion_InvalidSoqlResponse() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeInvalidSoql());

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('Do something weird', null);
        Test.stopTest();

        System.assertEquals(false, resp.success, 'Should fail for invalid SOQL');
        System.assert(resp.errorMessage.contains('Could not generate') || resp.errorMessage.contains('valid query'),
            'Should mention query issue: ' + resp.errorMessage);
    }

    @isTest
    static void testAskQuestion_ApiFailure() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeApiFailure());

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('Count all accounts', null);
        Test.stopTest();

        System.assertEquals(false, resp.success, 'Should fail on API error');
        System.assertNotEquals(null, resp.errorMessage, 'Should have error message');
    }

    @isTest
    static void testAskQuestion_RetryOnQueryError() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockClaudeWithRetry());

        Test.startTest();
        AiSalesAssistantController.AssistantResponse resp =
            AiSalesAssistantController.askQuestion('Show me some accounts', null);
        Test.stopTest();

        System.assertEquals(true, resp.success, 'Should succeed after self-correction retry: ' + resp.errorMessage);
        System.assertNotEquals(null, resp.answer, 'Should have answer after retry');
        // The final SOQL should be the corrected one
        System.assert(resp.soqlQuery.contains('Name'), 'Corrected SOQL should select Name');
        System.assert(!resp.soqlQuery.contains('ZZZ_No_Such_Field'), 'Should not contain the bad field');
    }

    @isTest
    static void testAssistantResponse_Serialization() {
        AiSalesAssistantController.AssistantResponse resp = new AiSalesAssistantController.AssistantResponse();
        resp.answer = 'Test answer';
        resp.soqlQuery = 'SELECT Id FROM Account';
        resp.recordCount = 5;
        resp.success = true;
        resp.errorMessage = null;
        resp.executionTimeMs = 1234;

        String jsonStr = JSON.serialize(resp);
        System.assert(jsonStr.contains('Test answer'), 'Should serialize answer');
        System.assert(jsonStr.contains('1234'), 'Should serialize execution time');
    }
}
