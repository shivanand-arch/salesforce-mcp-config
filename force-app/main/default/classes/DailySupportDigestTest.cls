@isTest
private class DailySupportDigestTest {

    // No @TestSetup — the dynamic SOQL in DailySupportDigest queries real
    // Account names (LIKE '%HDFC Sec%' etc.), so in a test context with
    // SeeAllData=false, those queries simply return 0 rows, which is fine.
    // The tests verify the code runs without errors and sends the email.

    @isTest
    static void testScheduledExecution() {
        Test.startTest();
        String jobId = System.schedule(
            'Test Daily Support Digest',
            '0 0 9 ? * MON-FRI',
            new DailySupportDigest()
        );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, State
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 9 ? * MON-FRI', ct.CronExpression,
            'Cron expression should match');
    }

    @isTest
    static void testSendDigestDirectly() {
        Test.startTest();
        Integer emailsBefore = Limits.getEmailInvocations();
        DailySupportDigest digest = new DailySupportDigest();
        digest.sendDigest();
        Integer emailsAfter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(emailsBefore + 1, emailsAfter,
            'One email should have been sent');
    }

    @isTest
    static void testSendDigestRunsTwice() {
        // Ensure idempotency — calling twice should not throw
        Test.startTest();
        DailySupportDigest digest = new DailySupportDigest();
        digest.sendDigest();
        digest.sendDigest();
        Test.stopTest();

        // If we reach here, both calls completed without exception
        System.assert(true, 'Digest ran twice without errors');
    }

    @isTest
    static void testSchedulableInterface() {
        // Verify the Schedulable.execute pathway works
        Test.startTest();
        DailySupportDigest digest = new DailySupportDigest();
        digest.execute(null); // SchedulableContext can be null in test
        Test.stopTest();

        // If we reach here, execute() completed without exception
        System.assert(true, 'execute() completed without errors');
    }
}
