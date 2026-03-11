/**
 * Service class for communicating with Google Gemini API.
 * Handles HTTP callouts, request building, and response parsing.
 */
public class GeminiApiService {

    public class GeminiException extends Exception {}

    public class GeminiResponse {
        public String content;
        public String finishReason;
    }

    /**
     * Sends a single message to Gemini with a system prompt.
     */
    public static GeminiResponse sendMessage(String systemPrompt, String userMessage, Integer maxTokens) {
        List<Map<String, Object>> contents = new List<Map<String, Object>>();
        contents.add(buildContentPart('user', userMessage));
        return callGeminiApi(systemPrompt, contents, maxTokens);
    }

    /**
     * Sends a multi-turn conversation to Gemini with a system prompt.
     */
    public static GeminiResponse sendConversation(String systemPrompt, List<Map<String, String>> messages, Integer maxTokens) {
        List<Map<String, Object>> contents = new List<Map<String, Object>>();
        for (Map<String, String> msg : messages) {
            String role = msg.get('role');
            String text = msg.get('content');
            // Gemini uses 'user' and 'model' (not 'assistant')
            if (role == 'assistant') {
                role = 'model';
            }
            contents.add(buildContentPart(role, text));
        }
        return callGeminiApi(systemPrompt, contents, maxTokens);
    }

    // Test-visible config override so tests don't depend on deployed Custom Metadata records
    @TestVisible
    private static AI_Assistant_Config__mdt testConfig;
    // When true, forces config to null even if the record exists (for testing missing-config scenario)
    @TestVisible
    private static Boolean testForceNullConfig = false;

    /**
     * Core method: builds and sends the HTTP request to Gemini API.
     */
    private static GeminiResponse callGeminiApi(String systemPrompt, List<Map<String, Object>> contents, Integer maxTokens) {
        // Load config — use test override if available
        AI_Assistant_Config__mdt config;
        if (Test.isRunningTest() && testForceNullConfig) {
            config = null;
        } else if (Test.isRunningTest() && testConfig != null) {
            config = testConfig;
        } else {
            config = AI_Assistant_Config__mdt.getInstance('Gemini_API');
        }
        if (config == null) {
            throw new GeminiException('AI Assistant configuration not found. Please set up the Gemini_API custom metadata record.');
        }

        String apiKey = config.API_Key__c;
        String modelName = config.Model_Name__c != null ? config.Model_Name__c : 'gemini-2.5-flash';
        String endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/'
            + modelName + ':generateContent?key=' + apiKey;

        // Build request body
        Map<String, Object> requestBody = new Map<String, Object>();

        // System instruction
        if (String.isNotBlank(systemPrompt)) {
            Map<String, Object> systemInstruction = new Map<String, Object>();
            List<Map<String, String>> systemParts = new List<Map<String, String>>();
            systemParts.add(new Map<String, String>{ 'text' => systemPrompt });
            systemInstruction.put('parts', systemParts);
            requestBody.put('system_instruction', systemInstruction);
        }

        // Contents (conversation messages)
        requestBody.put('contents', contents);

        // Generation config
        Map<String, Object> genConfig = new Map<String, Object>();
        genConfig.put('maxOutputTokens', maxTokens != null ? maxTokens : 4096);
        genConfig.put('temperature', 0.1);
        requestBody.put('generationConfig', genConfig);

        // Build HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000); // Max 120 seconds
        req.setBody(JSON.serialize(requestBody));

        // Send request
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            String errorMsg = 'Gemini API returned status ' + res.getStatusCode();
            try {
                Map<String, Object> errorBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> error = (Map<String, Object>) errorBody.get('error');
                if (error != null) {
                    errorMsg += ': ' + (String) error.get('message');
                }
            } catch (Exception e) {
                errorMsg += ': ' + res.getBody();
            }
            throw new GeminiException(errorMsg);
        }

        // Parse response
        return parseResponse(res.getBody());
    }

    /**
     * Parses Gemini API response JSON.
     * Handles Gemini 2.5 "thinking" mode where the response contains multiple parts:
     *   - Thinking parts (thought=true) with internal reasoning
     *   - Response parts with the actual answer text
     * We skip thinking parts and concatenate only the actual response text.
     */
    private static GeminiResponse parseResponse(String responseBody) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        List<Object> candidates = (List<Object>) responseMap.get('candidates');
        if (candidates == null || candidates.isEmpty()) {
            throw new GeminiException('No response generated by Gemini.');
        }

        Map<String, Object> firstCandidate = (Map<String, Object>) candidates[0];
        Map<String, Object> content = (Map<String, Object>) firstCandidate.get('content');
        List<Object> parts = (List<Object>) content.get('parts');

        if (parts == null || parts.isEmpty()) {
            throw new GeminiException('Empty response from Gemini.');
        }

        // Gemini 2.5 models return thinking parts (thought=true) and response parts.
        // Concatenate only non-thinking text parts to get the actual answer.
        String responseText = '';
        for (Object partObj : parts) {
            Map<String, Object> part = (Map<String, Object>) partObj;
            // Skip thinking parts — in Apex, null == true evaluates to false
            if (part.get('thought') == true) {
                continue;
            }
            String text = (String) part.get('text');
            if (text != null) {
                responseText += text;
            }
        }

        // Fallback: if all parts were thinking parts, use the last part's text
        if (String.isBlank(responseText)) {
            Map<String, Object> lastPart = (Map<String, Object>) parts[parts.size() - 1];
            responseText = (String) lastPart.get('text');
        }

        if (String.isBlank(responseText)) {
            throw new GeminiException('Empty response from Gemini.');
        }

        GeminiResponse geminiResp = new GeminiResponse();
        geminiResp.content = responseText;
        geminiResp.finishReason = (String) firstCandidate.get('finishReason');

        return geminiResp;
    }

    /**
     * Builds a content part for the Gemini API request.
     */
    private static Map<String, Object> buildContentPart(String role, String text) {
        Map<String, Object> contentPart = new Map<String, Object>();
        contentPart.put('role', role);
        List<Map<String, String>> parts = new List<Map<String, String>>();
        parts.add(new Map<String, String>{ 'text' => text });
        contentPart.put('parts', parts);
        return contentPart;
    }
}
