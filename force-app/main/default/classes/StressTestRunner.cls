/**
 * Queueable job that runs stress test questions through AiSalesAssistantController.
 * Processes one question per execution and chains to the next.
 *
 * Usage from Developer Console Execute Anonymous:
 *   StressTestRunner.runAll();           // Run all 75 questions
 *   StressTestRunner.runCategory('pipeline');  // Run one category
 *   StressTestRunner.runSingle(0);       // Run question at index 0
 */
public class StressTestRunner implements Queueable, Database.AllowsCallouts {

    private List<String> questions;
    private Integer currentIndex;
    private String batchId;

    public StressTestRunner(List<String> questions, Integer startIndex, String batchId) {
        this.questions = questions;
        this.currentIndex = startIndex;
        this.batchId = batchId;
    }

    public void execute(QueueableContext context) {
        if (currentIndex >= questions.size()) {
            System.debug('StressTest COMPLETE. Batch: ' + batchId + ', Total: ' + questions.size());
            return;
        }

        String question = questions.get(currentIndex);
        System.debug('StressTest [' + (currentIndex + 1) + '/' + questions.size() + '] ' + question);

        // Set batch ID so the controller logs it
        AiSalesAssistantController.currentBatchId = batchId;

        try {
            AiSalesAssistantController.AssistantResponse resp =
                AiSalesAssistantController.askQuestion(question, null);
            System.debug('StressTest Result: success=' + resp.success +
                ', records=' + resp.recordCount +
                ', retries=' + (resp.soqlQuery != null ? 'logged' : 'n/a') +
                ', time=' + resp.executionTimeMs + 'ms');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'StressTest EXCEPTION: ' + e.getMessage());
        }

        // Clear batch ID
        AiSalesAssistantController.currentBatchId = null;

        // Chain to next question
        if (currentIndex + 1 < questions.size()) {
            System.enqueueJob(new StressTestRunner(questions, currentIndex + 1, batchId));
        } else {
            System.debug('StressTest ALL DONE. Batch: ' + batchId);
        }
    }

    // =========================================================================
    // 75 Stress Test Questions — Organized by Category
    // =========================================================================

    public static List<String> getAllQuestions() {
        List<String> q = new List<String>();

        // --- PIPELINE & REVENUE (15) ---
        q.add('What is our total pipeline value this FY?');
        q.add('How many deals are currently in Negotiation stage?');
        q.add('Show me all deals closing this month');
        q.add('What is the average deal size for new customer opportunities?');
        q.add('How many deals are above 10 lakhs in value?');
        q.add('What is our pipeline breakdown by product type?');
        q.add('Show me deals stuck in Proposal stage for more than 30 days');
        q.add('What is the total committed booking value this FY?');
        q.add('How many deals have we won this quarter?');
        q.add('What is our overall win rate this FY?');
        q.add('Show me the top 10 largest deals in the pipeline');
        q.add('What is the total MRR of all won deals this FY?');
        q.add('How many deals are in each stage right now?');
        q.add('What is the pipeline by deal type — subscription vs on-premise?');
        q.add('Show me all POC deals with their expected close dates');

        // --- SDR & LEADS (10) ---
        q.add('How many leads were created this month?');
        q.add('Who are the top SDRs by lead creation this FY?');
        q.add('What is the SDR lead to opportunity conversion rate this FY?');
        q.add('Show me all IS Generated opportunities this quarter');
        q.add('How many ChatGPT leads do we have this FY?');
        q.add('What is the lead source breakdown this FY?');
        q.add('Which SDR has the most converted leads this quarter?');
        q.add('Show me dead leads this month with their reasons');
        q.add('How many leads are in each status right now?');
        q.add('What is the average MRR amount for qualified leads?');

        // --- LOSS ANALYSIS (10) ---
        q.add('How many deals did we lose this quarter?');
        q.add('What are the top loss reasons this FY?');
        q.add('Show me all lost deals above 5 lakhs this FY');
        q.add('What is the loss rate by account region?');
        q.add('Which competitors did we lose to the most this FY?');
        q.add('Show me lost deals where competition included Ameyo competitors');
        q.add('What is the loss breakdown by product type?');
        q.add('Compare the average deal size of lost deals vs won deals this FY');
        q.add('Who lost the most deals this quarter by owner?');
        q.add('Show me lost deals with no loss reason filled in');

        // --- CASE / SUPPORT (10) ---
        q.add('How many support cases were created this month?');
        q.add('What is the average resolution time in minutes for closed cases this month?');
        q.add('Show me all critical priority cases that are still open');
        q.add('How many cases are currently escalated?');
        q.add('What is the case origin breakdown this month?');
        q.add('How many P1 tickets were resolved this week?');
        q.add('Show me top 10 accounts by case volume this FY');
        q.add('What is the SLA violation count this quarter?');
        q.add('How many cases are in each status right now?');
        q.add('Show me all Jira-escalated cases this month');

        // --- ACCOUNT (10) ---
        q.add('How many customer accounts do we have?');
        q.add('Show me accounts with Red RAG status');
        q.add('Which accounts have the highest MRR opportunities?');
        q.add('How many SAAS premium accounts are there?');
        q.add('Show me top 10 accounts by total opportunity amount');
        q.add('What is the account breakdown by business unit?');
        q.add('How many accounts went live this quarter?');
        q.add('Show me accounts with AMC expiring this quarter');
        q.add('Which accounts have the most escalation cases?');
        q.add('How many enterprise accounts are in BFSI vertical?');

        // --- INTERNATIONAL & CURRENCY (10) ---
        q.add('Show me all USD deals this quarter');
        q.add('What is the international pipeline by account region?');
        q.add('How many AED deals are in negotiation stage?');
        q.add('Show me deals owned by the international sales team');
        q.add('What is the total pipeline for ME region?');
        q.add('Show me the Africa team deals this FY');
        q.add('Compare international vs domestic win count this FY');
        q.add('How many deals does the APAC team have in the pipeline?');
        q.add('Show me all USD deals above 10000 in amount');
        q.add('What is the total won deal value in USD this FY?');

        // --- COMPLEX / EDGE CASES (10) ---
        q.add('Show me the deal stage funnel — count of deals in each stage');
        q.add('Which product type has the highest win rate?');
        q.add('What is the average sales cycle in days for won deals this FY?');
        q.add('Show me deals that have both voicebot and chatbot in product type');
        q.add('How many AMC renewal deals are due this quarter?');
        q.add('What is the MRR breakdown by product dimension for won deals?');
        q.add('Show me the top 5 largest lost deals this FY');
        q.add('Which CSMs handle the most accounts?');
        q.add('What is the case MTTR without start stop for this month?');
        q.add('Show me all deals where owner role contains SDR');

        return q;
    }

    public static Map<String, List<Integer>> getCategoryMap() {
        Map<String, List<Integer>> cats = new Map<String, List<Integer>>();
        cats.put('pipeline', indexRange(0, 14));
        cats.put('sdr', indexRange(15, 24));
        cats.put('loss', indexRange(25, 34));
        cats.put('case', indexRange(35, 44));
        cats.put('account', indexRange(45, 54));
        cats.put('international', indexRange(55, 64));
        cats.put('complex', indexRange(65, 74));
        return cats;
    }

    private static List<Integer> indexRange(Integer fromIdx, Integer toIdx) {
        List<Integer> r = new List<Integer>();
        for (Integer i = fromIdx; i <= toIdx; i++) {
            r.add(i);
        }
        return r;
    }

    // =========================================================================
    // Convenience launchers
    // =========================================================================

    /** Run all 75 questions. */
    public static Id runAll() {
        String batchId = 'STRESS-' + String.valueOf(Datetime.now().getTime());
        List<String> questions = getAllQuestions();
        Id jobId = System.enqueueJob(new StressTestRunner(questions, 0, batchId));
        System.debug('StressTest started. Batch: ' + batchId + ', Questions: ' + questions.size() + ', Job: ' + jobId);
        return jobId;
    }

    /** Run questions for a specific category. */
    public static Id runCategory(String category) {
        Map<String, List<Integer>> cats = getCategoryMap();
        List<Integer> indices = cats.get(category.toLowerCase());
        if (indices == null) {
            System.debug('Unknown category: ' + category + '. Options: ' + cats.keySet());
            return null;
        }
        List<String> allQ = getAllQuestions();
        List<String> subset = new List<String>();
        for (Integer idx : indices) {
            subset.add(allQ.get(idx));
        }
        String batchId = 'STRESS-' + category.toUpperCase() + '-' + String.valueOf(Datetime.now().getTime());
        Id jobId = System.enqueueJob(new StressTestRunner(subset, 0, batchId));
        System.debug('StressTest category "' + category + '" started. Batch: ' + batchId + ', Questions: ' + subset.size());
        return jobId;
    }

    /** Run a single question by index (0-based). */
    public static Id runSingle(Integer questionIndex) {
        List<String> allQ = getAllQuestions();
        if (questionIndex < 0 || questionIndex >= allQ.size()) {
            System.debug('Invalid index. Range: 0-' + (allQ.size() - 1));
            return null;
        }
        List<String> single = new List<String>{ allQ.get(questionIndex) };
        String batchId = 'STRESS-SINGLE-' + String.valueOf(Datetime.now().getTime());
        Id jobId = System.enqueueJob(new StressTestRunner(single, 0, batchId));
        System.debug('StressTest single Q[' + questionIndex + ']: "' + single.get(0) + '". Batch: ' + batchId);
        return jobId;
    }

    // =========================================================================
    // Analytics Queries (run from Developer Console)
    // =========================================================================

    /** Print detailed info for queries that hit retry. */
    public static void printRetryDetails() {
        List<AI_Query_Log__c> retried = [
            SELECT Question__c, Initial_SOQL__c, Final_SOQL__c, Retry_Count__c,
                   Success__c, Error_Message__c, Execution_Time_Ms__c, Batch_Id__c
            FROM AI_Query_Log__c
            WHERE Batch_Id__c LIKE 'STRESS-%' AND Retry_Count__c > 0
            ORDER BY CreatedDate
            LIMIT 50
        ];
        System.debug('=== RETRY DETAIL ANALYSIS (' + retried.size() + ' queries) ===');
        for (AI_Query_Log__c r : retried) {
            System.debug('---');
            System.debug('Q: ' + r.Question__c);
            System.debug('  Batch: ' + r.Batch_Id__c);
            System.debug('  Retries: ' + r.Retry_Count__c + ' | Success: ' + r.Success__c);
            String initSoql = r.Initial_SOQL__c;
            if (initSoql != null && initSoql.length() > 300) {
                initSoql = initSoql.substring(0, 300);
            }
            System.debug('  Initial SOQL: ' + initSoql);
            String finalSoql = r.Final_SOQL__c;
            if (finalSoql != null && finalSoql.length() > 300) {
                finalSoql = finalSoql.substring(0, 300);
            }
            System.debug('  Final SOQL: ' + finalSoql);
            String errMsg = r.Error_Message__c;
            if (errMsg != null && errMsg.length() > 300) {
                errMsg = errMsg.substring(0, 300);
            }
            System.debug('  Error: ' + errMsg);
            System.debug('  Time: ' + r.Execution_Time_Ms__c + 'ms');
        }
    }

    /** Print per-batch summary. */
    public static void printBatchSummary() {
        List<AggregateResult> batches = [
            SELECT Batch_Id__c batchId, COUNT(Id) cnt, SUM(Retry_Count__c) retries
            FROM AI_Query_Log__c
            WHERE Batch_Id__c LIKE 'STRESS-%'
            GROUP BY Batch_Id__c
            ORDER BY Batch_Id__c
        ];
        System.debug('=== PER-BATCH SUMMARY ===');
        Integer totalAll = 0;
        for (AggregateResult b : batches) {
            String bid = (String)b.get('batchId');
            Integer cnt = (Integer)b.get('cnt');
            Decimal retries = (Decimal)b.get('retries');
            totalAll += cnt;
            System.debug('Batch: ' + bid + ' | Questions: ' + cnt + ' | Total Retries: ' + retries);
        }
        System.debug('Grand Total: ' + totalAll + ' questions across ' + batches.size() + ' batches');
    }

    /** Print questions that were NOT logged (identify missing ones). */
    public static void printMissingQuestions() {
        List<String> allQ = getAllQuestions();
        Set<String> loggedQuestions = new Set<String>();
        for (AI_Query_Log__c log : [SELECT Question__c FROM AI_Query_Log__c WHERE Batch_Id__c LIKE 'STRESS-%']) {
            loggedQuestions.add(log.Question__c);
        }
        System.debug('=== MISSING QUESTIONS ===');
        System.debug('Total expected: ' + allQ.size() + ' | Total logged: ' + loggedQuestions.size());
        Integer missing = 0;
        for (Integer i = 0; i < allQ.size(); i++) {
            if (!loggedQuestions.contains(allQ.get(i))) {
                missing++;
                System.debug('MISSING [' + i + ']: ' + allQ.get(i));
            }
        }
        System.debug('Total missing: ' + missing);
    }

    /** Get summary analytics for a batch (or all batches). */
    public static void printAnalytics(String batchId) {
        String whereClause = String.isNotBlank(batchId)
            ? 'WHERE Batch_Id__c = \'' + String.escapeSingleQuotes(batchId) + '\''
            : 'WHERE Batch_Id__c LIKE \'STRESS-%\'';

        // Overall counts
        List<AggregateResult> totalAgg = Database.query(
            'SELECT COUNT(Id) total, AVG(Execution_Time_Ms__c) avgTime, AVG(Retry_Count__c) avgRetries ' +
            'FROM AI_Query_Log__c ' + whereClause
        );
        List<AggregateResult> successAgg = Database.query(
            'SELECT COUNT(Id) cnt FROM AI_Query_Log__c ' + whereClause + ' AND Success__c = true'
        );
        List<AggregateResult> failAgg = Database.query(
            'SELECT COUNT(Id) cnt FROM AI_Query_Log__c ' + whereClause + ' AND Success__c = false'
        );

        if (!totalAgg.isEmpty()) {
            AggregateResult r = totalAgg.get(0);
            Integer total = (Integer)r.get('total');
            Integer successes = !successAgg.isEmpty() ? (Integer)successAgg.get(0).get('cnt') : 0;
            Integer failures = !failAgg.isEmpty() ? (Integer)failAgg.get(0).get('cnt') : 0;

            System.debug('=== STRESS TEST ANALYTICS ===');
            System.debug('Total queries: ' + total);
            System.debug('Successes: ' + successes);
            System.debug('Failures: ' + failures);
            if (total > 0) {
                Decimal rate = ((Decimal)successes / total) * 100;
                System.debug('Success rate: ' + rate.setScale(1) + '%');
            }
            System.debug('Avg execution time: ' + r.get('avgTime') + 'ms');
            System.debug('Avg retries: ' + r.get('avgRetries'));
        }

        // Error breakdown
        List<AggregateResult> errors = Database.query(
            'SELECT Error_Type__c, COUNT(Id) cnt ' +
            'FROM AI_Query_Log__c ' + whereClause + ' AND Success__c = false ' +
            'GROUP BY Error_Type__c ORDER BY COUNT(Id) DESC'
        );
        if (!errors.isEmpty()) {
            System.debug('--- Error Breakdown ---');
            for (AggregateResult er : errors) {
                System.debug(er.get('Error_Type__c') + ': ' + er.get('cnt'));
            }
        }

        // Retry stats
        List<AggregateResult> retriedTotal = Database.query(
            'SELECT COUNT(Id) cnt FROM AI_Query_Log__c ' + whereClause + ' AND Retry_Count__c > 0'
        );
        List<AggregateResult> retriedSuccess = Database.query(
            'SELECT COUNT(Id) cnt FROM AI_Query_Log__c ' + whereClause + ' AND Retry_Count__c > 0 AND Success__c = true'
        );
        Integer retriedCount = !retriedTotal.isEmpty() ? (Integer)retriedTotal.get(0).get('cnt') : 0;
        Integer retriedSuccessCount = !retriedSuccess.isEmpty() ? (Integer)retriedSuccess.get(0).get('cnt') : 0;
        if (retriedCount > 0) {
            System.debug('--- Retry Stats ---');
            System.debug('Queries that needed retry: ' + retriedCount);
            System.debug('Retries that succeeded: ' + retriedSuccessCount);
            Decimal retryRate = ((Decimal)retriedSuccessCount / retriedCount) * 100;
            System.debug('Retry success rate: ' + retryRate.setScale(1) + '%');
        }

        // Failed queries detail
        List<AI_Query_Log__c> failed = Database.query(
            'SELECT Question__c, Error_Type__c, Error_Message__c, Initial_SOQL__c, Retry_Count__c ' +
            'FROM AI_Query_Log__c ' + whereClause + ' AND Success__c = false ' +
            'ORDER BY CreatedDate LIMIT 50'
        );
        if (!failed.isEmpty()) {
            System.debug('--- Failed Queries ---');
            for (AI_Query_Log__c f : failed) {
                System.debug('Q: ' + f.Question__c);
                String errMsg = f.Error_Message__c;
                if (errMsg != null && errMsg.length() > 200) {
                    errMsg = errMsg.substring(0, 200);
                }
                System.debug('  Error: ' + f.Error_Type__c + ' - ' + errMsg);
                String soqlSnippet = f.Initial_SOQL__c;
                if (soqlSnippet != null && soqlSnippet.length() > 200) {
                    soqlSnippet = soqlSnippet.substring(0, 200);
                }
                System.debug('  SOQL: ' + soqlSnippet);
                System.debug('  Retries: ' + f.Retry_Count__c);
            }
        }
    }

    /** Print all successful queries with their generated SOQL for documentation. */
    public static void printSuccessfulQueries() {
        List<AI_Query_Log__c> logs = [
            SELECT Question__c, Final_SOQL__c, Record_Count__c, Retry_Count__c,
                   Execution_Time_Ms__c, Batch_Id__c
            FROM AI_Query_Log__c
            WHERE Batch_Id__c LIKE 'STRESS-%' AND Success__c = true
            ORDER BY CreatedDate ASC
        ];
        System.debug('=== SUCCESSFUL QUERIES (' + logs.size() + ') ===');
        for (AI_Query_Log__c l : logs) {
            System.debug('Q: ' + l.Question__c);
            System.debug('SOQL: ' + l.Final_SOQL__c);
            System.debug('Records: ' + l.Record_Count__c + ' | Retries: ' + l.Retry_Count__c + ' | Time: ' + l.Execution_Time_Ms__c + 'ms');
            System.debug('---');
        }
    }
}
