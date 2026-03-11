@isTest
private class GeminiApiServiceTest {

    private static void setupTestConfig() {
        GeminiApiService.testConfig = new AI_Assistant_Config__mdt(
            DeveloperName = 'Gemini_API',
            API_Key__c = 'test-api-key-12345',
            Model_Name__c = 'gemini-2.5-flash',
            Max_Tokens__c = 4096
        );
    }

    private class MockGeminiSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"candidates":[{"content":{"parts":[{"text":"```soql\\nSELECT COUNT(Id) FROM Opportunity WHERE StageName = \'Order\'\\n```"}]},"finishReason":"STOP"}]}');
            return res;
        }
    }

    private class MockGeminiError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":{"message":"Bad request","code":400}}');
            return res;
        }
    }

    private class MockGeminiEmptyResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"candidates":[]}');
            return res;
        }
    }

    @isTest
    static void testSendMessage_Success() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockGeminiSuccess());
        Test.startTest();
        GeminiApiService.GeminiResponse resp = GeminiApiService.sendMessage(
            'You are a SOQL expert.',
            'Count all won deals',
            1024
        );
        Test.stopTest();

        System.assertNotEquals(null, resp, 'Response should not be null');
        System.assertNotEquals(null, resp.content, 'Content should not be null');
        System.assert(resp.content.contains('SELECT'), 'Response should contain SOQL');
    }

    @isTest
    static void testSendConversation_Success() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockGeminiSuccess());

        List<Map<String, String>> messages = new List<Map<String, String>>();
        messages.add(new Map<String, String>{ 'role' => 'user', 'content' => 'Count deals' });
        messages.add(new Map<String, String>{ 'role' => 'assistant', 'content' => 'Here is the query' });
        messages.add(new Map<String, String>{ 'role' => 'user', 'content' => 'Summarize results' });

        Test.startTest();
        GeminiApiService.GeminiResponse resp = GeminiApiService.sendConversation(
            'Summarize data.',
            messages,
            2048
        );
        Test.stopTest();

        System.assertNotEquals(null, resp, 'Response should not be null');
    }

    @isTest
    static void testSendMessage_ApiError() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockGeminiError());

        Test.startTest();
        try {
            GeminiApiService.sendMessage('Test', 'Test', 1024);
            System.assert(false, 'Should have thrown exception');
        } catch (GeminiApiService.GeminiException e) {
            System.assert(e.getMessage().contains('400'), 'Error should contain status code: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSendMessage_EmptyResponse() {
        setupTestConfig();
        Test.setMock(HttpCalloutMock.class, new MockGeminiEmptyResponse());

        Test.startTest();
        try {
            GeminiApiService.sendMessage('Test', 'Test', 1024);
            System.assert(false, 'Should have thrown exception');
        } catch (GeminiApiService.GeminiException e) {
            System.assert(e.getMessage().toLowerCase().contains('no response') || e.getMessage().toLowerCase().contains('empty'),
                'Should mention no/empty response: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSendMessage_NoConfig() {
        // Force null config — should throw config-not-found error
        GeminiApiService.testConfig = null;
        GeminiApiService.testForceNullConfig = true;
        Test.setMock(HttpCalloutMock.class, new MockGeminiSuccess());

        Test.startTest();
        try {
            GeminiApiService.sendMessage('Test', 'Test', 1024);
            System.assert(false, 'Should have thrown exception for missing config');
        } catch (GeminiApiService.GeminiException e) {
            System.assert(e.getMessage().contains('configuration not found'),
                'Should mention missing config: ' + e.getMessage());
        }
        Test.stopTest();
    }
}
