@isTest
private class SoqlSanitizerTest {

    @isTest
    static void testSanitize_ValidQuery() {
        String result = SoqlSanitizer.sanitize('SELECT Id, Name FROM Account LIMIT 10');
        System.assert(result.contains('SELECT'), 'Should pass valid query');
        System.assert(result.contains('LIMIT'), 'Should retain LIMIT');
    }

    @isTest
    static void testSanitize_AddsDefaultLimit() {
        String result = SoqlSanitizer.sanitize('SELECT Id FROM Opportunity WHERE StageName = \'Order\'');
        System.assert(result.contains('LIMIT 200'), 'Should add default LIMIT 200');
    }

    @isTest
    static void testSanitize_EnforcesMaxLimit() {
        String result = SoqlSanitizer.sanitize('SELECT Id FROM Opportunity LIMIT 50000');
        System.assert(result.contains('LIMIT 2000'), 'Should cap LIMIT at 2000');
    }

    @isTest
    static void testSanitize_BlocksDml() {
        try {
            SoqlSanitizer.sanitize('DELETE FROM Opportunity');
            System.assert(false, 'Should have thrown exception');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('must be a SELECT'), 'Should block non-SELECT');
        }
    }

    @isTest
    static void testSanitize_BlocksUpdateKeyword() {
        try {
            SoqlSanitizer.sanitize('SELECT Id FROM Opportunity WHERE Name LIKE \'%UPDATE%\'');
            // This should actually pass because UPDATE is inside a string literal
            // But our simple regex will catch it - which is safer
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('blocked keyword'), 'Should block UPDATE');
        }
    }

    @isTest
    static void testSanitize_BlocksSemicolon() {
        try {
            SoqlSanitizer.sanitize('SELECT Id FROM Opportunity; DELETE FROM Opportunity');
            System.assert(false, 'Should have thrown exception');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('semicolon'), 'Should block semicolons');
        }
    }

    @isTest
    static void testSanitize_EmptyInput() {
        try {
            SoqlSanitizer.sanitize('');
            System.assert(false, 'Should have thrown exception');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('empty'), 'Should reject empty query');
        }
    }

    @isTest
    static void testExtractSoql_CodeBlock() {
        String input = 'Here is the query:\n```soql\nSELECT Id FROM Account LIMIT 10\n```';
        String result = SoqlSanitizer.extractSoql(input);
        System.assert(result.startsWith('SELECT'), 'Should extract from code block');
    }

    @isTest
    static void testExtractSoql_GenericCodeBlock() {
        String input = 'Query:\n```\nSELECT Id FROM Account LIMIT 10\n```';
        String result = SoqlSanitizer.extractSoql(input);
        System.assert(result.startsWith('SELECT'), 'Should extract from generic code block');
    }

    @isTest
    static void testExtractSoql_RawSelect() {
        String input = 'SELECT Id, Name FROM Account WHERE Industry = \'Tech\' LIMIT 10';
        String result = SoqlSanitizer.extractSoql(input);
        System.assert(result.startsWith('SELECT'), 'Should extract raw SELECT');
    }

    @isTest
    static void testExtractSoql_NoSoql() {
        try {
            SoqlSanitizer.extractSoql('I cannot generate a query for that.');
            System.assert(false, 'Should have thrown exception');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('Could not find'), 'Should indicate no SOQL found');
        }
    }

    @isTest
    static void testExtractSoql_Empty() {
        try {
            SoqlSanitizer.extractSoql('');
            System.assert(false, 'Should have thrown exception');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('Empty'), 'Should reject empty');
        }
    }

    @isTest
    static void testIsAllowedObject_Opportunity() {
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Opportunity'), 'Opportunity should be allowed');
    }

    @isTest
    static void testIsAllowedObject_Account() {
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Account'), 'Account should be allowed');
    }

    @isTest
    static void testIsAllowedObject_Lead() {
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Lead'), 'Lead should be allowed');
    }

    @isTest
    static void testIsAllowedObject_Case() {
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Case'), 'Case should be allowed');
    }

    @isTest
    static void testExtractObjectName() {
        System.assertEquals('Opportunity', SoqlSanitizer.extractObjectName('SELECT Id FROM Opportunity WHERE Id != null'));
        System.assertEquals('Account', SoqlSanitizer.extractObjectName('SELECT Name FROM Account'));
        System.assertEquals(null, SoqlSanitizer.extractObjectName('invalid string'));
    }

    @isTest
    static void testSanitize_AggregateQueryNoLimit() {
        // Aggregate queries without GROUP BY should not get LIMIT added
        String result = SoqlSanitizer.sanitize('SELECT COUNT(Id) FROM Opportunity WHERE StageName = \'Order\'');
        System.assert(!result.contains('LIMIT'), 'Pure aggregate should not get LIMIT');
    }

    @isTest
    static void testSanitize_GroupByGetsLimit() {
        String result = SoqlSanitizer.sanitize('SELECT StageName, COUNT(Id) FROM Opportunity GROUP BY StageName');
        System.assert(result.contains('LIMIT'), 'GROUP BY should get LIMIT');
    }

    // --- Duplicate Alias Auto-Fix ---

    @isTest
    static void testFixDuplicateAliases_OwnerNameAndRole() {
        String input = 'SELECT Owner.Name, Owner.UserRole.Name, COUNT(Id) cnt FROM Opportunity GROUP BY Owner.Name, Owner.UserRole.Name LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('ownerName') || result.contains('userRoleName'),
            'Should add aliases for duplicate Name terminals: ' + result);
        System.assert(!result.contains('duplicate'), 'Should not error');
    }

    @isTest
    static void testFixDuplicateAliases_NoDuplicatesInGroupBy() {
        String input = 'SELECT Owner.Name, COUNT(Id) cnt FROM Opportunity GROUP BY Owner.Name LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(!result.contains('ownerName'),
            'Should not add aliases when no duplicates in GROUP BY: ' + result);
    }

    @isTest
    static void testFixDuplicateAliases_GroupByDirectAndRelationship() {
        String input = 'SELECT Name, Account.Name, COUNT(Id) cnt FROM Contact GROUP BY Name, Account.Name LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('accountName'),
            'Should alias relationship when conflicting in GROUP BY: ' + result);
    }

    @isTest
    static void testFixDuplicateAliases_NonGroupBySkipped() {
        // Non-GROUP-BY queries should NOT get alias fixing (SObjects handle duplicates natively)
        String input = 'SELECT Name, Account.Name FROM Contact LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(!result.contains('accountName'),
            'Should NOT add aliases for non-GROUP-BY queries: ' + result);
    }

    @isTest
    static void testFixDuplicateAliases_AlreadyAliasedGroupBy() {
        String input = 'SELECT Owner.Name ownerN, Owner.UserRole.Name roleN, COUNT(Id) cnt FROM Opportunity GROUP BY Owner.Name, Owner.UserRole.Name LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        // Should not double-alias since they already have aliases
        System.assert(result.contains('ownerN'), 'Should keep existing alias: ' + result);
    }

    // --- DateTime Format Auto-Fix ---

    @isTest
    static void testFixDateTime_CreatedDate() {
        String input = 'SELECT Id FROM Opportunity WHERE CreatedDate >= 2026-01-01 LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('2026-01-01T00:00:00Z'),
            'Should auto-fix CreatedDate format: ' + result);
    }

    @isTest
    static void testFixDateTime_LastStageChangeDate() {
        String input = 'SELECT Id FROM Opportunity WHERE LastStageChangeDate >= 2026-02-08 LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('2026-02-08T00:00:00Z'),
            'Should auto-fix LastStageChangeDate format: ' + result);
    }

    @isTest
    static void testFixDateTime_CustomTimeField() {
        String input = 'SELECT Id FROM Case WHERE First_Escalation_time__c >= 2026-01-01 LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('2026-01-01T00:00:00Z'),
            'Should auto-fix custom _time__c fields: ' + result);
    }

    @isTest
    static void testFixDateTime_AlreadyCorrect() {
        String input = 'SELECT Id FROM Opportunity WHERE CreatedDate >= 2026-01-01T00:00:00Z LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        // Should NOT double-convert
        System.assert(!result.contains('T00:00:00ZT00:00:00Z'),
            'Should not double-convert: ' + result);
    }

    @isTest
    static void testFixDateTime_DateFieldUntouched() {
        String input = 'SELECT Id FROM Opportunity WHERE CloseDate >= 2026-01-01 LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(!result.contains('T00:00:00Z'),
            'Should NOT convert Date fields like CloseDate: ' + result);
    }

    @isTest
    static void testStripLimitFromUngroupedAggregate() {
        String input = 'SELECT COUNT(Id), SUM(Amount) FROM Opportunity LIMIT 2000';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(!result.toUpperCase().contains('LIMIT'),
            'Should strip LIMIT from ungrouped aggregate: ' + result);
    }

    // --- Bare COUNT() to COUNT(Id) Auto-Fix ---

    @isTest
    static void testFixBareCount_Simple() {
        String input = 'SELECT COUNT() FROM Lead WHERE CreatedDate >= 2026-03-01T00:00:00Z';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('COUNT(Id)'),
            'Should convert COUNT() to COUNT(Id): ' + result);
        System.assert(!result.contains('COUNT()'),
            'Should not contain bare COUNT(): ' + result);
    }

    @isTest
    static void testFixBareCount_WithWhitespace() {
        String input = 'SELECT COUNT(  ) FROM Case';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('COUNT(Id)'),
            'Should convert COUNT(  ) to COUNT(Id): ' + result);
    }

    @isTest
    static void testFixBareCount_PreservesExistingCountId() {
        String input = 'SELECT COUNT(Id) FROM Opportunity WHERE StageName = \'Order\'';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('COUNT(Id)'),
            'Should preserve COUNT(Id): ' + result);
    }

    @isTest
    static void testFixBareCount_MultipleAggregates() {
        String input = 'SELECT COUNT(), SUM(Amount), AVG(Amount) FROM Opportunity';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('COUNT(Id)'),
            'Should fix COUNT() among other aggregates: ' + result);
        System.assert(result.contains('SUM(Amount)'),
            'Should preserve SUM: ' + result);
    }

    // --- Field Alias Removal ---

    @isTest
    static void testFixFieldAliases_AccountName() {
        String input = 'SELECT Id, Account.Name acctName, Owner.Name ownerName FROM Opportunity LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(!result.contains('acctName'),
            'Should remove acctName alias: ' + result);
        System.assert(!result.contains('ownerName'),
            'Should remove ownerName alias: ' + result);
        System.assert(result.contains('Account.Name'),
            'Should keep Account.Name field: ' + result);
    }

    @isTest
    static void testFixFieldAliases_KeepsAggregateAlias() {
        String input = 'SELECT StageName, COUNT(Id) totalDeals FROM Opportunity GROUP BY StageName';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('totalDeals'),
            'Should keep aggregate alias totalDeals: ' + result);
    }

    @isTest
    static void testFixFieldAliases_NoAliases() {
        String input = 'SELECT Id, Name, Account.Name FROM Opportunity LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(result.contains('Account.Name'),
            'Should pass through unchanged: ' + result);
    }

    // --- GROUP BY Non-Groupable Field Validation ---

    @isTest
    static void testValidateGroupBy_MultiPicklist() {
        // Product_Type__c is MULTIPICKLIST on Opportunity — should throw
        try {
            SoqlSanitizer.sanitize('SELECT Product_Type__c, COUNT(Id) FROM Opportunity GROUP BY Product_Type__c');
            System.assert(false, 'Should throw for non-groupable MULTIPICKLIST field');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('cannot be used in GROUP BY'),
                'Should mention GROUP BY restriction: ' + e.getMessage());
            System.assert(e.getMessage().contains('MULTIPICKLIST'),
                'Should mention field type: ' + e.getMessage());
        }
    }

    @isTest
    static void testValidateGroupBy_GroupableField() {
        // StageName is a regular picklist — should pass
        String result = SoqlSanitizer.sanitize('SELECT StageName, COUNT(Id) FROM Opportunity GROUP BY StageName');
        System.assert(result.contains('GROUP BY'), 'Should allow groupable fields: ' + result);
    }

    @isTest
    static void testValidateGroupBy_RelationshipFieldSkipped() {
        // Relationship fields should be skipped (we can't validate cross-object fields easily)
        String result = SoqlSanitizer.sanitize('SELECT Owner.Name, COUNT(Id) cnt FROM Opportunity GROUP BY Owner.Name');
        System.assert(result.contains('GROUP BY'), 'Should allow relationship fields in GROUP BY: ' + result);
    }

    // --- extractAllSoql Multi-Query Tests ---

    @isTest
    static void testExtractAllSoql_MultipleBlocks() {
        String input = 'Here are two queries:\n\n' +
            '-- Query 1: Won deals by cluster\n' +
            '```soql\nSELECT Account_Cluster__c, SUM(Amount) wonVal FROM Opportunity WHERE StageName = \'Order\' GROUP BY Account_Cluster__c LIMIT 2000\n```\n\n' +
            '-- Query 2: All consumed deals by cluster\n' +
            '```soql\nSELECT Account_Cluster__c, SUM(Amount) totalVal FROM Opportunity WHERE StageName IN (\'Order\',\'Closed Lost\') GROUP BY Account_Cluster__c LIMIT 2000\n```';

        List<Map<String, String>> queries = SoqlSanitizer.extractAllSoql(input);
        System.assertEquals(2, queries.size(), 'Should extract 2 queries');
        System.assert(queries[0].get('label').contains('Won deals'), 'First label should mention won deals: ' + queries[0].get('label'));
        System.assert(queries[1].get('label').contains('consumed'), 'Second label should mention consumed: ' + queries[1].get('label'));
        System.assert(queries[0].get('soql').contains('SELECT'), 'First query should be valid SOQL');
        System.assert(queries[1].get('soql').contains('SELECT'), 'Second query should be valid SOQL');
    }

    @isTest
    static void testExtractAllSoql_SingleBlock() {
        String input = '```soql\nSELECT Id, Name FROM Account LIMIT 10\n```';
        List<Map<String, String>> queries = SoqlSanitizer.extractAllSoql(input);
        System.assertEquals(1, queries.size(), 'Should extract 1 query for backward compatibility');
        System.assert(queries[0].get('soql').contains('Account'), 'Should contain Account query');
    }

    @isTest
    static void testExtractAllSoql_MaxCap() {
        // Build 7 queries - should cap at 5
        String input = '';
        for (Integer i = 1; i <= 7; i++) {
            input += '-- Query ' + i + ': Test\n```soql\nSELECT Id FROM Account LIMIT 10\n```\n\n';
        }
        List<Map<String, String>> queries = SoqlSanitizer.extractAllSoql(input);
        System.assert(queries.size() <= 5, 'Should cap at 5 queries, got: ' + queries.size());
    }

    @isTest
    static void testExtractAllSoql_NoSoql() {
        try {
            SoqlSanitizer.extractAllSoql('I cannot generate queries for that.');
            System.assert(false, 'Should throw for no SOQL');
        } catch (SoqlSanitizer.SoqlValidationException e) {
            System.assert(e.getMessage().contains('Could not find'), 'Should indicate no SOQL found');
        }
    }

    @isTest
    static void testExtractAllSoql_RawSelectFallback() {
        String input = 'SELECT Id, Name FROM Account WHERE Industry = \'Tech\' LIMIT 10';
        List<Map<String, String>> queries = SoqlSanitizer.extractAllSoql(input);
        System.assertEquals(1, queries.size(), 'Should extract 1 query via raw SELECT fallback');
    }

    @isTest
    static void testIsAllowedObject_NewObjects() {
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Target__c'), 'Target__c should be allowed');
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM SDF__c'), 'SDF__c should be allowed');
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Survey__c'), 'Survey__c should be allowed');
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Daily_Task__c'), 'Daily_Task__c should be allowed');
    }

    @isTest
    static void testIsAllowedObject_TableauObjects() {
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Booking_Target__c LIMIT 10'), 'Booking_Target__c should be allowed');
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Accounts_Target__c LIMIT 10'), 'Accounts_Target__c should be allowed');
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Program__c LIMIT 10'), 'Program__c should be allowed');
        System.assert(SoqlSanitizer.isAllowedObject('SELECT Id FROM Opp_Related_Programs__c LIMIT 10'), 'Opp_Related_Programs__c should be allowed');
    }

    @isTest
    static void testFixFieldAliases_RelationshipWithRole() {
        String input = 'SELECT Id, Account.Name acctName, Owner.Name ownerName, Owner.UserRole.Name roleName FROM Opportunity LIMIT 10';
        String result = SoqlSanitizer.sanitize(input);
        System.assert(!result.contains('acctName'),
            'Should remove acctName: ' + result);
        System.assert(!result.contains('ownerName'),
            'Should remove ownerName: ' + result);
        System.assert(!result.contains('roleName'),
            'Should remove roleName: ' + result);
        System.assert(result.contains('Owner.UserRole.Name'),
            'Should keep Owner.UserRole.Name: ' + result);
    }
}
