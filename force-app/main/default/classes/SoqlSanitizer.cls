/**
 * Utility class for validating and sanitizing dynamically generated SOQL queries.
 * Prevents SQL injection, DML abuse, and enforces query limits.
 */
public class SoqlSanitizer {

    public class SoqlValidationException extends Exception {}

    private static final Integer MAX_LIMIT = 2000;
    private static final Integer DEFAULT_LIMIT = 200;

    // Allowlisted objects that can be queried
    private static final Set<String> ALLOWED_OBJECTS = new Set<String>{
        'opportunity', 'account', 'lead', 'case', 'contact',
        'user', 'userrole', 'campaign', 'task', 'event',
        'group', 'opportunityhistory', 'opportunityfieldhistory',
        'casehistory', 'currencytype', 'recordtype',
        'opportunitylineitem', 'product2', 'pricebookentry'
    };

    // Blocked keywords that indicate DML or dangerous operations
    private static final Set<String> BLOCKED_KEYWORDS = new Set<String>{
        'insert', 'update', 'delete', 'upsert', 'merge', 'undelete'
    };

    /**
     * Extracts SOQL from Gemini's response text.
     * Looks for ```soql, ```sql, or raw SELECT patterns.
     */
    public static String extractSoql(String geminiResponse) {
        if (String.isBlank(geminiResponse)) {
            throw new SoqlValidationException('Empty response from AI - no SOQL generated.');
        }

        String soql = null;

        // Pattern 1: ```soql ... ``` or ```sql ... ```
        Pattern codeBlockPattern = Pattern.compile('```(?:soql|sql)\\s*\\n([\\s\\S]*?)\\n\\s*```');
        Matcher codeBlockMatcher = codeBlockPattern.matcher(geminiResponse);
        if (codeBlockMatcher.find()) {
            soql = codeBlockMatcher.group(1).trim();
        }

        // Pattern 2: ``` ... ``` (generic code block)
        if (soql == null) {
            Pattern genericBlockPattern = Pattern.compile('```\\s*\\n([\\s\\S]*?)\\n\\s*```');
            Matcher genericBlockMatcher = genericBlockPattern.matcher(geminiResponse);
            if (genericBlockMatcher.find()) {
                String candidate = genericBlockMatcher.group(1).trim();
                if (candidate.toUpperCase().startsWith('SELECT')) {
                    soql = candidate;
                }
            }
        }

        // Pattern 3: Raw SELECT statement
        if (soql == null) {
            Pattern selectPattern = Pattern.compile('(?i)(SELECT\\s+[\\s\\S]+?FROM\\s+[\\s\\S]+?)(?:\\n\\n|$)');
            Matcher selectMatcher = selectPattern.matcher(geminiResponse);
            if (selectMatcher.find()) {
                soql = selectMatcher.group(1).trim();
            }
        }

        if (soql == null) {
            throw new SoqlValidationException('Could not find a SOQL query in the AI response.');
        }

        // Remove trailing semicolons
        soql = soql.replaceAll(';\\s*$', '').trim();

        return sanitize(soql);
    }

    /**
     * Validates and sanitizes a SOQL query string.
     */
    public static String sanitize(String soqlQuery) {
        if (String.isBlank(soqlQuery)) {
            throw new SoqlValidationException('SOQL query is empty.');
        }

        String trimmed = soqlQuery.trim();

        // Must start with SELECT
        if (!trimmed.toUpperCase().startsWith('SELECT')) {
            throw new SoqlValidationException('Query must be a SELECT statement.');
        }

        // Block semicolons (prevents multi-statement injection)
        if (trimmed.contains(';')) {
            throw new SoqlValidationException('Query contains illegal semicolons.');
        }

        // Block DML keywords at word boundaries
        String upperQuery = trimmed.toUpperCase();
        for (String blocked : BLOCKED_KEYWORDS) {
            Pattern p = Pattern.compile('\\b' + blocked.toUpperCase() + '\\b');
            Matcher m = p.matcher(upperQuery);
            if (m.find()) {
                throw new SoqlValidationException('Query contains blocked keyword: ' + blocked);
            }
        }

        // Auto-fix structural issues before they reach Database.query()
        trimmed = fixBareCount(trimmed);
        trimmed = fixFieldAliases(trimmed);
        trimmed = fixDuplicateAliases(trimmed);
        trimmed = fixDateTimeFormats(trimmed);
        trimmed = enforceLimit(trimmed);

        // Validate GROUP BY fields are groupable (prevents uncatchable System.UnexpectedException)
        validateGroupByFields(trimmed);

        return trimmed;
    }

    /**
     * Validates that the queried object is in the allowlist.
     */
    public static Boolean isAllowedObject(String soqlQuery) {
        String objectName = extractObjectName(soqlQuery);
        return objectName != null && ALLOWED_OBJECTS.contains(objectName.toLowerCase());
    }

    /**
     * Extracts the main object name from a SOQL FROM clause.
     */
    public static String extractObjectName(String soqlQuery) {
        Pattern fromPattern = Pattern.compile('(?i)FROM\\s+(\\w+)');
        Matcher fromMatcher = fromPattern.matcher(soqlQuery);
        if (fromMatcher.find()) {
            return fromMatcher.group(1);
        }
        return null;
    }

    /**
     * Converts bare COUNT() to COUNT(Id) so Database.query() returns AggregateResult.
     * SELECT COUNT() FROM X → SELECT COUNT(Id) FROM X
     * Database.query() cannot handle COUNT() — it requires Database.countQuery() instead.
     * Using COUNT(Id) ensures consistent AggregateResult handling.
     */
    private static String fixBareCount(String soqlQuery) {
        // Match COUNT() or COUNT( ) with optional whitespace inside
        return soqlQuery.replaceAll('(?i)\\bCOUNT\\s*\\(\\s*\\)', 'COUNT(Id)');
    }

    /**
     * Removes column aliases from non-aggregate SELECT fields.
     * SOQL only supports aliases on aggregate functions in GROUP BY queries.
     * E.g., "Account.Name acctName" → "Account.Name"
     *        "Owner.Name ownerName" → "Owner.Name"
     * But keeps: "COUNT(Id) totalDeals" (aggregate alias - valid in SOQL)
     */
    private static String fixFieldAliases(String soqlQuery) {
        String upper = soqlQuery.toUpperCase();
        Integer fromIdx = upper.indexOf(' FROM ');
        if (fromIdx < 0) return soqlQuery;

        Integer selectStart = upper.indexOf('SELECT ') + 7;
        String selectBody = soqlQuery.substring(selectStart, fromIdx);
        String rest = soqlQuery.substring(fromIdx);

        List<String> fields = selectBody.split(',');
        List<String> fixedFields = new List<String>();
        Boolean anyFixed = false;

        for (String f : fields) {
            String trimmedField = f.trim();
            // Skip aggregate functions - they can have aliases
            if (trimmedField.contains('(')) {
                fixedFields.add(trimmedField);
                continue;
            }

            // Split by whitespace to detect "fieldPath alias" pattern
            List<String> tokens = trimmedField.split('\\s+');
            if (tokens.size() == 2 && !isReservedKeyword(tokens[1])) {
                // This has an alias on a non-aggregate field — remove it
                fixedFields.add(tokens[0]);
                anyFixed = true;
            } else {
                fixedFields.add(trimmedField);
            }
        }

        if (!anyFixed) return soqlQuery;
        return 'SELECT ' + String.join(fixedFields, ', ') + rest;
    }

    /**
     * Auto-fixes duplicate alias conflicts in SELECT clause.
     * E.g., Owner.Name + Owner.UserRole.Name both auto-alias to "Name" — adds explicit aliases.
     */
    private static String fixDuplicateAliases(String soqlQuery) {
        String upper = soqlQuery.toUpperCase();
        // Only fix aliases in GROUP BY queries where AggregateResult needs distinct keys
        // Regular queries return SObjects which handle relationship fields natively
        if (!upper.contains('GROUP BY')) return soqlQuery;
        Integer fromIdx = upper.indexOf(' FROM ');
        if (fromIdx < 0) return soqlQuery;

        // Work only with the SELECT portion
        Integer selectStart = upper.indexOf('SELECT ') + 7;
        String selectBody = soqlQuery.substring(selectStart, fromIdx);
        String rest = soqlQuery.substring(fromIdx);

        // Split by comma to get individual fields
        List<String> fields = selectBody.split(',');

        // First pass: count terminal field names to find duplicates
        Map<String, Integer> terminalCounts = new Map<String, Integer>();
        for (String f : fields) {
            String fieldId = f.trim().split('\\s+')[0]; // field part before any alias
            if (fieldId.contains('(')) continue; // Skip aggregate functions
            String terminal;
            if (fieldId.contains('.')) {
                String[] parts = fieldId.split('\\.');
                terminal = parts[parts.size() - 1];
            } else {
                terminal = fieldId;
            }
            Integer cnt = terminalCounts.get(terminal);
            terminalCounts.put(terminal, cnt == null ? 1 : cnt + 1);
        }

        // Check if any duplicates exist
        Boolean needsFix = false;
        for (Integer cnt : terminalCounts.values()) {
            if (cnt > 1) { needsFix = true; break; }
        }
        if (!needsFix) return soqlQuery;

        // Second pass: add aliases to relationship fields with duplicate terminals
        List<String> fixedFields = new List<String>();
        Set<String> usedAliases = new Set<String>();

        for (String f : fields) {
            String trimmed = f.trim();
            String[] tokens = trimmed.split('\\s+');
            String fieldId = tokens[0];
            Boolean hasAlias = tokens.size() > 1 && !isReservedKeyword(tokens[1]);

            if (!hasAlias && !fieldId.contains('(') && fieldId.contains('.')) {
                String[] parts = fieldId.split('\\.');
                String terminal = parts[parts.size() - 1];
                Integer cnt = terminalCounts.get(terminal);

                if (cnt != null && cnt > 1) {
                    // Build alias from path: Owner.Name → ownerName, Owner.UserRole.Name → userRoleName
                    String alias = '';
                    for (Integer i = 0; i < parts.size() - 1; i++) {
                        String p = parts[i];
                        alias += p.substring(0, 1).toLowerCase() + p.substring(1);
                    }
                    alias += terminal;

                    // Ensure uniqueness
                    String baseAlias = alias;
                    Integer suffix = 2;
                    while (usedAliases.contains(alias.toLowerCase())) {
                        alias = baseAlias + suffix;
                        suffix++;
                    }
                    usedAliases.add(alias.toLowerCase());

                    fixedFields.add(fieldId + ' ' + alias);
                    continue;
                }
            }
            fixedFields.add(trimmed);
        }

        return 'SELECT ' + String.join(fixedFields, ', ') + rest;
    }

    private static Boolean isReservedKeyword(String token) {
        Set<String> keywords = new Set<String>{
            'FROM', 'WHERE', 'GROUP', 'ORDER', 'HAVING', 'LIMIT',
            'AND', 'OR', 'ASC', 'DESC', 'BY', 'NULLS', 'OFFSET'
        };
        return keywords.contains(token.toUpperCase());
    }

    /**
     * Auto-fixes DateTime fields that have bare date format (YYYY-MM-DD → YYYY-MM-DDT00:00:00Z).
     */
    private static String fixDateTimeFormats(String soqlQuery) {
        // Standard DateTime fields — always DateTime regardless of object
        soqlQuery = soqlQuery.replaceAll(
            '(?i)\\b(CreatedDate|LastModifiedDate|SystemModstamp|LastStageChangeDate|StopStartDate)\\s*(>=|<=|!=|=|>|<)\\s*(\\d{4}-\\d{2}-\\d{2})(?!T)',
            '$1 $2 $3T00:00:00Z'
        );
        // Custom DateTime fields ending in _time__c or _DateTime__c
        soqlQuery = soqlQuery.replaceAll(
            '(?i)(\\w+(?:_time__c|_DateTime__c))\\s*(>=|<=|!=|=|>|<)\\s*(\\d{4}-\\d{2}-\\d{2})(?!T)',
            '$1 $2 $3T00:00:00Z'
        );
        return soqlQuery;
    }

    /**
     * Validates that GROUP BY fields are groupable.
     * MULTIPICKLIST, TEXTAREA, BLOB, and formula fields of certain types cannot be grouped.
     * Throws SoqlValidationException (catchable) BEFORE Database.query() runs,
     * preventing the uncatchable System.UnexpectedException.
     */
    private static void validateGroupByFields(String soqlQuery) {
        String upper = soqlQuery.toUpperCase();
        if (!upper.contains('GROUP BY')) return;

        // Extract the object name
        String objectName = extractObjectName(soqlQuery);
        if (objectName == null) return;

        // Get schema for the object
        Schema.SObjectType sot = Schema.getGlobalDescribe().get(objectName);
        if (sot == null) return;

        Map<String, Schema.SObjectField> fieldMap = sot.getDescribe().fields.getMap();

        // Extract GROUP BY field list
        Pattern gbPattern = Pattern.compile('(?i)GROUP\\s+BY\\s+(.+?)(?:\\s+HAVING|\\s+ORDER|\\s+LIMIT|\\s*$)');
        Matcher gbMatcher = gbPattern.matcher(soqlQuery);
        if (!gbMatcher.find()) return;

        String groupByClause = gbMatcher.group(1).trim();
        List<String> groupByFields = groupByClause.split(',');

        for (String gbField : groupByFields) {
            String fieldName = gbField.trim().toLowerCase();
            // Skip relationship fields (e.g., Owner.Name) — they're on related objects
            if (fieldName.contains('.')) continue;
            // Skip standard aggregate expressions
            if (fieldName.contains('(')) continue;

            Schema.SObjectField field = fieldMap.get(fieldName);
            if (field != null) {
                Schema.DescribeFieldResult dfr = field.getDescribe();
                if (!dfr.isGroupable()) {
                    throw new SoqlValidationException(
                        'Field \'' + dfr.getName() + '\' (' + dfr.getType().name() +
                        ') cannot be used in GROUP BY. Use a different field or remove from GROUP BY. ' +
                        'Non-groupable field types include: MultiPicklist, LongTextArea, RichText.'
                    );
                }
            }
        }
    }

    /**
     * Ensures the query has a LIMIT clause within allowed bounds.
     * Special case: aggregate queries WITHOUT GROUP BY must NOT have LIMIT (Salesforce error).
     */
    private static String enforceLimit(String soqlQuery) {
        String upperQ = soqlQuery.toUpperCase();
        Boolean isAggregate = upperQ.contains('COUNT(') || upperQ.contains('SUM(')
            || upperQ.contains('AVG(') || upperQ.contains('MIN(') || upperQ.contains('MAX(');
        Boolean hasGroupBy = upperQ.contains('GROUP BY');

        // Aggregate without GROUP BY: MUST NOT have LIMIT — strip any existing one
        if (isAggregate && !hasGroupBy) {
            Pattern limitPattern = Pattern.compile('(?i)\\s*\\bLIMIT\\s+\\d+');
            soqlQuery = limitPattern.matcher(soqlQuery).replaceAll('');
            return soqlQuery.trim();
        }

        // All other queries: enforce LIMIT within bounds
        Pattern limitPattern = Pattern.compile('(?i)\\bLIMIT\\s+(\\d+)');
        Matcher limitMatcher = limitPattern.matcher(soqlQuery);

        if (limitMatcher.find()) {
            Integer existingLimit = Integer.valueOf(limitMatcher.group(1));
            if (existingLimit > MAX_LIMIT) {
                soqlQuery = soqlQuery.substring(0, limitMatcher.start())
                    + 'LIMIT ' + MAX_LIMIT
                    + soqlQuery.substring(limitMatcher.end());
            }
        } else {
            soqlQuery = soqlQuery + ' LIMIT ' + DEFAULT_LIMIT;
        }

        return soqlQuery;
    }
}
