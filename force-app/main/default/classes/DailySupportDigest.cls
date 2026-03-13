/**
 * DailySupportDigest - Scheduled Apex job that sends a daily support ticket
 * digest email for key accounts to ceooffice@exotel.com.
 *
 * Schedule: Daily at 9:00 AM IST (weekdays)
 * To schedule:
 *   System.schedule('Daily Support Digest 9AM', '0 0 9 ? * MON-FRI', new DailySupportDigest());
 * To unschedule:
 *   for (CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Daily Support Digest 9AM']) {
 *       System.abortJob(ct.Id);
 *   }
 */
public class DailySupportDigest implements Schedulable {

    // ── Configuration ──────────────────────────────────────────────────
    private static final String RECIPIENT = 'ceooffice@exotel.com';
    private static final String SENDER_DISPLAY_NAME = 'Exotel Support Digest';

    // Customer definitions: Label → SOQL WHERE fragment on Account.Name
    private static final Map<String, String> CUSTOMERS = new Map<String, String>{
        'Redcliffe (Aditya - Founder)' =>
            '(Account.Name LIKE \'%Redcliffe%\' OR Account.Name LIKE \'%REDCLIFFE%\')',
        'HDFC Securities (Girish Oberoi)' =>
            'Account.Name LIKE \'%HDFC Sec%\'',
        'HomeLane (Tanuj)' =>
            'Account.Name LIKE \'%omelane%\'',
        'Apollo (Ajay Bansal)' =>
            '(Account.Name LIKE \'%Apollo 2%\' OR Account.Name LIKE \'%apollo2%\')',
        'Baysys' =>
            '(Account.Name LIKE \'%Baysys%\' OR Account.Name LIKE \'%CBay%\' OR Account.Name LIKE \'%iBay%\')'
    };

    // Statuses that count as "closed"
    private static final Set<String> CLOSED_STATUSES = new Set<String>{
        'Close_successful', 'Close_unsuccessful', 'Closed - No Response', 'Close - Not Approved'
    };

    // Statuses that count as "resolved" (for last-24h metric)
    private static final Set<String> RESOLVED_STATUSES = new Set<String>{
        'Close_successful', 'Close_unsuccessful', 'Resolved'
    };

    // ── Data container ─────────────────────────────────────────────────
    public class CustomerDigest {
        public String name;
        public Integer openCount         = 0;
        public Integer new24h            = 0;
        public Integer resolved24h       = 0;
        public Integer critMajorOpen     = 0;
        public Integer jiraEscalatedOpen = 0;
        public Map<String, Integer> priorityMix = new Map<String, Integer>();
        public String oldestOpen         = 'None';
    }

    // ── Schedulable entry point ────────────────────────────────────────
    public void execute(SchedulableContext ctx) {
        sendDigest();
    }

    // ── Public so it can be called ad-hoc for testing ──────────────────
    public void sendDigest() {
        DateTime since24h = DateTime.now().addHours(-24);
        List<CustomerDigest> digests = new List<CustomerDigest>();

        for (String custLabel : CUSTOMERS.keySet()) {
            String acctFilter = CUSTOMERS.get(custLabel);
            CustomerDigest cd = buildDigest(custLabel, acctFilter, since24h);
            digests.add(cd);
        }

        String htmlBody = buildEmailHtml(digests);
        String todayStr = DateTime.now().format('MMM dd, yyyy');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ RECIPIENT });
        mail.setSubject('\uD83C\uDFAF Daily Support Digest \u2014 ' + todayStr);
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName(SENDER_DISPLAY_NAME);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    // ── Build digest for one customer ──────────────────────────────────
    private CustomerDigest buildDigest(String custLabel, String acctFilter, DateTime since24h) {
        CustomerDigest cd = new CustomerDigest();
        cd.name = custLabel;

        // Fetch all open cases for this customer in one query
        String soql = 'SELECT Id, Priority, Status, CreatedDate, Is_Jira_Escalated__c, '
                     + 'CaseNumber, Subject '
                     + 'FROM Case '
                     + 'WHERE ' + acctFilter
                     + ' AND Status NOT IN :closedStatuses '
                     + 'ORDER BY CreatedDate ASC';

        // We can't use bind variables in dynamic SOQL with local vars easily,
        // so we'll query all open + recently modified and filter in Apex.
        List<Case> openCases = queryOpenCases(acctFilter);
        cd.openCount = openCases.size();

        // Priority mix & Critical/Major count
        for (Case c : openCases) {
            String p = c.Priority != null ? c.Priority : 'Unknown';
            if (cd.priorityMix.containsKey(p)) {
                cd.priorityMix.put(p, cd.priorityMix.get(p) + 1);
            } else {
                cd.priorityMix.put(p, 1);
            }
            if (p == 'Critical' || p == 'Major') {
                cd.critMajorOpen++;
            }
            if (c.Is_Jira_Escalated__c == true) {
                cd.jiraEscalatedOpen++;
            }
        }

        // Oldest open
        if (!openCases.isEmpty()) {
            Case oldest = openCases[0]; // already sorted ASC
            String dt = oldest.CreatedDate != null ? oldest.CreatedDate.format('yyyy-MM-dd') : '?';
            String subj = oldest.Subject != null ? oldest.Subject.abbreviate(60) : '(no subject)';
            cd.oldestOpen = '#' + oldest.CaseNumber + ' (' + oldest.Priority + ') - ' + subj + ' [' + dt + ']';
        }

        // New in last 24h
        cd.new24h = countNew24h(acctFilter, since24h);

        // Resolved in last 24h
        cd.resolved24h = countResolved24h(acctFilter, since24h);

        return cd;
    }

    // ── Query helpers (dynamic SOQL to inject Account.Name filter) ─────
    private List<Case> queryOpenCases(String acctFilter) {
        String soql = 'SELECT Id, Priority, Status, CreatedDate, Is_Jira_Escalated__c, '
                     + 'CaseNumber, Subject '
                     + 'FROM Case '
                     + 'WHERE ' + acctFilter
                     + ' AND Status NOT IN ('
                     + '\'Close_successful\',\'Close_unsuccessful\','
                     + '\'Closed - No Response\',\'Close - Not Approved\''
                     + ') ORDER BY CreatedDate ASC LIMIT 2000';
        return Database.query(soql);
    }

    private Integer countNew24h(String acctFilter, DateTime since) {
        String soql = 'SELECT COUNT() FROM Case '
                     + 'WHERE ' + acctFilter
                     + ' AND CreatedDate >= :since';
        return Database.countQuery(soql);
    }

    private Integer countResolved24h(String acctFilter, DateTime since) {
        String soql = 'SELECT COUNT() FROM Case '
                     + 'WHERE ' + acctFilter
                     + ' AND Status IN ('
                     + '\'Close_successful\',\'Close_unsuccessful\',\'Resolved\''
                     + ') AND LastModifiedDate >= :since';
        return Database.countQuery(soql);
    }

    // ── HTML email builder ─────────────────────────────────────────────
    private String buildEmailHtml(List<CustomerDigest> digests) {
        String todayStr = DateTime.now().format('MMM dd, yyyy');
        String ts = DateTime.now().format('MMM dd, yyyy h:mm a z');

        String html = '<html><body style="font-family:Arial,sans-serif;color:#333;max-width:800px;">'
            + '<h2 style="color:#1a73e8;">\uD83C\uDFAF Daily Support Digest \u2014 ' + todayStr + '</h2>'
            + '<p>Here\'s today\'s support snapshot for your key accounts:</p>';

        // Per-customer sections
        for (CustomerDigest cd : digests) {
            String statusColor = cd.critMajorOpen > 0 ? '#e74c3c' : '#27ae60';
            String statusIcon  = cd.critMajorOpen > 0 ? '\uD83D\uDD34' : '\uD83D\uDFE2';

            html += '<h3 style="border-bottom:2px solid ' + statusColor + ';padding-bottom:4px;">'
                  + statusIcon + ' ' + escapeHtml(cd.name) + '</h3>';

            html += '<table border="1" cellpadding="8" cellspacing="0" '
                  + 'style="border-collapse:collapse;width:100%;font-size:14px;">';

            html += row('Open Tickets', '<b>' + cd.openCount + '</b>', true);
            html += row('New (24h)', String.valueOf(cd.new24h), false);
            html += row('Resolved (24h)', String.valueOf(cd.resolved24h), false);

            String critVal = cd.critMajorOpen > 0
                ? '<span style="color:red;font-weight:bold;">' + cd.critMajorOpen + ' \u26A0\uFE0F</span>'
                : '0 \u2705';
            html += row('Critical/Major Open', critVal, false);
            html += row('Jira Escalations', String.valueOf(cd.jiraEscalatedOpen), false);

            // Priority mix
            String mixStr = '';
            if (cd.priorityMix.isEmpty()) {
                mixStr = '\u2014';
            } else {
                List<String> parts = new List<String>();
                for (String p : cd.priorityMix.keySet()) {
                    parts.add(p + ':' + cd.priorityMix.get(p));
                }
                mixStr = String.join(parts, ', ');
            }
            html += row('Priority Mix', mixStr, false);
            html += row('Oldest Open', '<span style="font-size:12px;">' + escapeHtml(cd.oldestOpen) + '</span>', false);

            html += '</table><br/>';
        }

        // Summary table
        html += '<hr style="margin:24px 0;">'
              + '<h3>\uD83D\uDCCA Summary</h3>'
              + '<table border="1" cellpadding="8" cellspacing="0" '
              + 'style="border-collapse:collapse;width:100%;font-size:14px;">'
              + '<tr style="background:#1a73e8;color:white;">'
              + '<th>Customer</th><th>Open</th><th>New</th><th>Resolved</th>'
              + '<th>\uD83D\uDD34 Crit/Maj</th><th>Jira</th></tr>';

        Integer totalOpen = 0, totalNew = 0, totalResolved = 0, totalCrit = 0, totalJira = 0;
        for (CustomerDigest cd : digests) {
            String critStyle = cd.critMajorOpen > 0 ? ' style="color:red;font-weight:bold;"' : '';
            html += '<tr>'
                  + '<td>' + escapeHtml(cd.name.split('\\(')[0].trim()) + '</td>'
                  + '<td><b>' + cd.openCount + '</b></td>'
                  + '<td>' + cd.new24h + '</td>'
                  + '<td>' + cd.resolved24h + '</td>'
                  + '<td' + critStyle + '>' + cd.critMajorOpen + '</td>'
                  + '<td>' + cd.jiraEscalatedOpen + '</td>'
                  + '</tr>';
            totalOpen += cd.openCount;
            totalNew += cd.new24h;
            totalResolved += cd.resolved24h;
            totalCrit += cd.critMajorOpen;
            totalJira += cd.jiraEscalatedOpen;
        }

        String totalCritStyle = totalCrit > 0 ? ' style="color:red;"' : '';
        html += '<tr style="background:#f0f0f0;font-weight:bold;">'
              + '<td>TOTAL</td>'
              + '<td>' + totalOpen + '</td>'
              + '<td>' + totalNew + '</td>'
              + '<td>' + totalResolved + '</td>'
              + '<td' + totalCritStyle + '>' + totalCrit + '</td>'
              + '<td>' + totalJira + '</td>'
              + '</tr></table>';

        html += '<p style="color:gray;font-size:11px;margin-top:20px;">'
              + 'Auto-generated by Salesforce Scheduled Apex \u00B7 ' + ts + '</p>';
        html += '</body></html>';

        return html;
    }

    // ── Utility ────────────────────────────────────────────────────────
    private String row(String label, String value, Boolean highlight) {
        String bg = highlight ? ' style="background:#f8f9fa;"' : '';
        return '<tr' + bg + '><td><b>' + escapeHtml(label) + '</b></td><td>' + value + '</td></tr>';
    }

    private String escapeHtml(String text) {
        if (text == null) return '';
        return text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;');
    }
}
