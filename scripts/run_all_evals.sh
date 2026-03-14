#!/bin/bash
# Revenue Eval Runner — runs each eval as a separate Apex execution
# Usage: bash scripts/run_all_evals.sh 2>&1 | tee scripts/eval_baseline_raw.log

RESULTS_FILE="scripts/eval_baseline_results.txt"
TMPFILE="/tmp/eval_single.apex"

echo "========== REVENUE EVAL BASELINE ==========" > "$RESULTS_FILE"
echo "Run date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$RESULTS_FILE"
echo "==========================================" >> "$RESULTS_FILE"

# Define all 40 eval questions
# Format: ID|Question|ExpectedObject|Category
EVALS=(
  "REV-01|What is our total revenue this financial year?|accounts_revenue__c|simple_total"
  "REV-02|How much GP did we make in Q3?|accounts_revenue__c|simple_total"
  "REV-03|Total variable cost this year|accounts_revenue__c|simple_total"
  "REV-04|What is revenue for March 2026?|accounts_revenue__c|simple_total"
  "REV-05|Show me total fixed cost and variable cost for H1|accounts_revenue__c|simple_total"
  "REV-06|Revenue by cluster this FY|accounts_revenue__c|grouped"
  "REV-07|GP by SKU for Q4|accounts_revenue__c|grouped"
  "REV-08|Revenue by region and cluster this year|accounts_revenue__c|grouped"
  "REV-09|Show revenue by product type for last quarter|accounts_revenue__c|grouped"
  "REV-10|Revenue by account manager this FY|accounts_revenue__c|grouped"
  "REV-11|Top 10 customers by revenue this year|accounts_revenue__c|grouped"
  "REV-12|GP by revenue classification for Q2|accounts_revenue__c|grouped"
  "REV-13|Revenue split by currency this FY|accounts_revenue__c|grouped"
  "REV-14|Revenue for Voice SKU this year|accounts_revenue__c|filtered"
  "REV-15|GP by cluster for Enterprise CC only|accounts_revenue__c|filtered"
  "REV-16|Revenue for BFSI cluster in Q3|accounts_revenue__c|filtered"
  "REV-17|Show revenue for international region this FY|accounts_revenue__c|filtered"
  "REV-18|Revenue where classification is New Sales|accounts_revenue__c|filtered"
  "REV-19|Top 5 CSMs by GP this year|accounts_revenue__c|filtered"
  "REV-20|Revenue for accounts managed by Sahil|accounts_revenue__c|filtered"
  "REV-21|Revenue last month|accounts_revenue__c|date_edge"
  "REV-22|Compare Q1 and Q2 revenue|accounts_revenue__c|date_edge"
  "REV-23|Revenue YTD vs same period last year|accounts_revenue__c|date_edge"
  "REV-24|Show monthly revenue trend for this FY|accounts_revenue__c|date_edge"
  "REV-25|Revenue for January to March 2026|accounts_revenue__c|date_edge"
  "REV-26|Revenue by cluster for full FY 2024-25|accounts_revenue__c|large_object"
  "REV-27|Revenue for last 2 years|accounts_revenue__c|large_object"
  "REV-28|Revenue for September 2025|accounts_revenue__c|large_object"
  "REV-29|Revenue by SKU for H2 FY 2025-26|accounts_revenue__c|large_object"
  "REV-30|How much did we earn from retail?|accounts_revenue__c|ambiguous"
  "REV-31|What is our margin by sector?|accounts_revenue__c|ambiguous"
  "REV-32|Show me the numbers for APAC|accounts_revenue__c|ambiguous"
  "REV-33|How are we doing on costs?|accounts_revenue__c|ambiguous"
  "REV-34|Break down this years GP by parent sku|accounts_revenue__c|ambiguous"
  "REV-35|Revenue performance across regions|accounts_revenue__c|ambiguous"
  "REV-36|What are our account credits?|BLOCK|refuse"
  "REV-37|Show the booking to revenue journey|BLOCK|refuse"
  "REV-38|What is our PF QuickSight call volume?|BLOCK|refuse"
  "REV-39|Show revenue AND account credits together|accounts_revenue__c|refuse"
  "REV-40|What is our NRR this quarter?|accounts_revenue__c|refuse"
)

PASSED=0
FAILED=0
ERRORS=0
TOTAL=${#EVALS[@]}
COUNT=0

for eval_entry in "${EVALS[@]}"; do
  IFS='|' read -r EVAL_ID QUESTION EXPECTED_OBJ CATEGORY <<< "$eval_entry"
  COUNT=$((COUNT + 1))

  echo ""
  echo "=== [$COUNT/$TOTAL] $EVAL_ID [$CATEGORY] ==="
  echo "Q: $QUESTION"
  echo "Expected: $EXPECTED_OBJ"

  # Escape single quotes in question for Apex string
  ESCAPED_Q=$(echo "$QUESTION" | sed "s/'/\\\\\\'/g")

  # Write single-question Apex to temp file
  cat > "$TMPFILE" << APEX_EOF
AiSalesAssistantController.AssistantResponse resp =
    AiSalesAssistantController.askQuestion('${ESCAPED_Q}', null);
String actualObject = '';
if (resp.soqlQuery != null) {
    actualObject = SoqlSanitizer.extractObjectName(resp.soqlQuery);
}
System.debug('EVALDATA_ID: $EVAL_ID');
System.debug('EVALDATA_OBJ: ' + actualObject);
System.debug('EVALDATA_SUCCESS: ' + resp.success);
System.debug('EVALDATA_RECORDS: ' + resp.recordCount);
System.debug('EVALDATA_TIME: ' + resp.executionTimeMs);
System.debug('EVALDATA_SOQL: ' + (resp.soqlQuery != null ? resp.soqlQuery.abbreviate(800) : 'NULL'));
System.debug('EVALDATA_ANSWER: ' + (resp.answer != null ? resp.answer.abbreviate(500) : 'NULL'));
System.debug('EVALDATA_MULTI: ' + (resp.soqlQuery != null && resp.soqlQuery.contains('---') ? resp.soqlQuery.split('---').size() : 0));
APEX_EOF

  # Run it
  OUTPUT=$(npx sf apex run -f "$TMPFILE" -o ameyo 2>&1)
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "RESULT: ERROR (exit code $EXIT_CODE)"
    # Check if it's a compile error vs runtime error
    if echo "$OUTPUT" | grep -q "Compile Error"; then
      echo "Compile error detected"
    fi
    ERRORS=$((ERRORS + 1))
    echo "$EVAL_ID|$CATEGORY|ERROR|exit_$EXIT_CODE|||" >> "$RESULTS_FILE"
    continue
  fi

  # Extract results — filter to USER_DEBUG lines only (exclude Execute Anonymous echo)
  ACTUAL_OBJ=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_OBJ:' | head -1 | sed 's/.*EVALDATA_OBJ: //')
  SUCCESS=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_SUCCESS:' | head -1 | sed 's/.*EVALDATA_SUCCESS: //')
  RECORDS=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_RECORDS:' | head -1 | sed 's/.*EVALDATA_RECORDS: //')
  EVAL_TIME=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_TIME:' | head -1 | sed 's/.*EVALDATA_TIME: //')
  SOQL=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_SOQL:' | head -1 | sed 's/.*EVALDATA_SOQL: //')
  ANSWER=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_ANSWER:' | head -1 | sed 's/.*EVALDATA_ANSWER: //')
  MULTI=$(echo "$OUTPUT" | grep 'USER_DEBUG.*EVALDATA_MULTI:' | head -1 | sed 's/.*EVALDATA_MULTI: //')

  # Grade
  RESULT="UNKNOWN"
  if [ "$EXPECTED_OBJ" = "BLOCK" ]; then
    if [ "$RECORDS" = "0" ] && echo "$ANSWER" | grep -qiE "QuickSight|Tableau Prep|not available|not in Salesforce|AWS|external"; then
      RESULT="PASS"
      PASSED=$((PASSED + 1))
    else
      RESULT="FAIL"
      FAILED=$((FAILED + 1))
    fi
  elif [ -n "$ACTUAL_OBJ" ] && [ "$ACTUAL_OBJ" != "NULL" ] && [ "$(echo "$ACTUAL_OBJ" | tr '[:upper:]' '[:lower:]')" = "$(echo "$EXPECTED_OBJ" | tr '[:upper:]' '[:lower:]')" ]; then
    RESULT="PASS"
    PASSED=$((PASSED + 1))
  else
    RESULT="FAIL"
    FAILED=$((FAILED + 1))
  fi

  echo "Object: $ACTUAL_OBJ -> $RESULT"
  echo "Success: $SUCCESS | Records: $RECORDS | Time: ${EVAL_TIME}ms | Multi: $MULTI"
  echo "SOQL: ${SOQL:0:200}"
  echo "Answer: ${ANSWER:0:150}"
  echo ">>> RESULT: $RESULT"

  echo "$EVAL_ID|$CATEGORY|$RESULT|$ACTUAL_OBJ|$SUCCESS|$RECORDS|$EVAL_TIME|$MULTI|${SOQL:0:300}" >> "$RESULTS_FILE"

  # Small delay to avoid API rate limiting
  sleep 2
done

echo ""
echo "========== EVAL SUMMARY =========="
echo "Passed: $PASSED/$TOTAL"
echo "Failed: $FAILED/$TOTAL"
echo "Errors: $ERRORS/$TOTAL"
if [ $TOTAL -gt 0 ]; then
  ACCURACY=$(( (PASSED * 100) / TOTAL ))
  echo "Domain accuracy: ${ACCURACY}%"
fi
echo "=================================="

echo "" >> "$RESULTS_FILE"
echo "========== SUMMARY ==========" >> "$RESULTS_FILE"
echo "Passed: $PASSED/$TOTAL" >> "$RESULTS_FILE"
echo "Failed: $FAILED/$TOTAL" >> "$RESULTS_FILE"
echo "Errors: $ERRORS/$TOTAL" >> "$RESULTS_FILE"
echo "=============================" >> "$RESULTS_FILE"

echo ""
echo "Results saved to: $RESULTS_FILE"
echo "Full log: scripts/eval_baseline_raw.log (if piped with tee)"

# Cleanup
rm -f "$TMPFILE"
