import { LightningElement, api, track } from 'lwc';
import askQuestion from '@salesforce/apex/AiSalesAssistantController.askQuestion';

export default class AskSalesforce extends LightningElement {
    @api chatTitle = 'Ask Salesforce';
    @api placeholderText = 'Ask about pipeline, deals, leads, cases...';

    @track messages = [];
    @track userInput = '';
    @track isLoading = false;

    messageIdCounter = 0;
    conversationHistory = [];

    get showWelcome() {
        return this.messages.length === 0 && !this.isLoading;
    }

    get isSendDisabled() {
        return this.isLoading || !this.userInput || !this.userInput.trim();
    }

    // --- Event Handlers ---

    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    handleKeyUp(event) {
        if (event.key === 'Enter' && !this.isSendDisabled) {
            this.handleSend();
        }
    }

    handleSuggestion(event) {
        const question = event.currentTarget.dataset.question;
        this.userInput = question;
        this.handleSend();
    }

    handleSend() {
        const question = this.userInput.trim();
        if (!question) return;

        // Add user message
        this.addUserMessage(question);
        this.userInput = '';
        this.isLoading = true;

        // Build full conversation history for session memory
        const context = this.conversationHistory.length > 0
            ? this.conversationHistory
                  .map((h, i) => `Q${i + 1}: ${h.question}\nA${i + 1}: ${h.answer}`)
                  .join('\n---\n')
            : '';

        // Call Apex
        askQuestion({ userQuestion: question, conversationContext: context })
            .then(result => {
                if (result.success) {
                    this.addAssistantMessage(
                        result.answer,
                        result.soqlQuery,
                        result.recordCount,
                        result.executionTimeMs
                    );
                    // Add to session history (truncate answer to 500 chars, keep last 10 exchanges)
                    this.conversationHistory.push({
                        question: question,
                        answer: result.answer ? result.answer.substring(0, 500) : ''
                    });
                    if (this.conversationHistory.length > 10) {
                        this.conversationHistory.shift();
                    }
                } else {
                    this.addErrorMessage(result.errorMessage);
                    // Don't clear history on error — previous successful Q&As remain valid context
                }
            })
            .catch(error => {
                const msg = error.body ? error.body.message : 'An unexpected error occurred. Please try again.';
                this.addErrorMessage(msg);
            })
            .finally(() => {
                this.isLoading = false;
                this.scrollToBottom();
            });
    }

    handleSoqlToggle(event) {
        const msgId = parseInt(event.currentTarget.dataset.msgId, 10);
        this.messages = this.messages.map(msg => {
            if (msg.id === msgId) {
                return {
                    ...msg,
                    showSoql: !msg.showSoql,
                    soqlToggleLabel: msg.showSoql ? 'Show SOQL' : 'Hide SOQL'
                };
            }
            return msg;
        });
    }

    // --- Message Builders ---

    addUserMessage(text) {
        const msg = this.createBaseMessage(text);
        msg.isUser = true;
        msg.isAssistant = false;
        msg.isError = false;
        msg.containerClass = 'message-row user';
        msg.bubbleClass = 'message-bubble user';
        this.messages = [...this.messages, msg];
        this.scrollToBottom();
    }

    addAssistantMessage(text, soqlQuery, recordCount, executionTimeMs) {
        const msg = this.createBaseMessage(text);
        msg.isUser = false;
        msg.isAssistant = true;
        msg.isError = false;
        msg.containerClass = 'message-row assistant';
        msg.bubbleClass = 'message-bubble assistant';

        // Format the text - convert markdown-like formatting to HTML
        msg.formattedText = this.formatResponse(text);

        // SOQL
        msg.soqlQuery = soqlQuery;
        msg.showSoql = false;
        msg.soqlToggleLabel = 'Show SOQL';

        // Metadata
        msg.recordCount = recordCount;
        msg.recordCountLabel = recordCount !== null && recordCount !== undefined
            ? recordCount + ' record' + (recordCount !== 1 ? 's' : '')
            : null;
        msg.executionTimeLabel = executionTimeMs !== null && executionTimeMs !== undefined
            ? (executionTimeMs / 1000).toFixed(1) + 's'
            : null;

        this.messages = [...this.messages, msg];
        this.scrollToBottom();
    }

    addErrorMessage(text) {
        const msg = this.createBaseMessage(text);
        msg.isUser = false;
        msg.isAssistant = false;
        msg.isError = true;
        msg.containerClass = 'message-row assistant';
        msg.bubbleClass = 'message-bubble error';
        this.messages = [...this.messages, msg];
        this.scrollToBottom();
    }

    createBaseMessage(text) {
        const now = new Date();
        return {
            id: this.messageIdCounter++,
            text: text,
            timestamp: now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        };
    }

    // --- Formatting ---

    formatResponse(text) {
        if (!text) return '';

        const lines = text.split('\n');
        const outputParts = [];
        let i = 0;

        while (i < lines.length) {
            // Detect markdown table: line contains | and next lines also contain |
            if (this.isTableRow(lines[i]) && i + 1 < lines.length && this.isTableRow(lines[i + 1])) {
                const tableLines = [];
                while (i < lines.length && this.isTableRow(lines[i])) {
                    tableLines.push(lines[i]);
                    i++;
                }
                outputParts.push(this.buildHtmlTable(tableLines));
            } else {
                outputParts.push(this.formatLine(lines[i]));
                i++;
            }
        }

        return outputParts.join('');
    }

    isTableRow(line) {
        if (!line) return false;
        const trimmed = line.trim();
        return trimmed.startsWith('|') && trimmed.endsWith('|') && trimmed.length > 2;
    }

    buildHtmlTable(tableLines) {
        if (tableLines.length < 2) return tableLines.map(l => this.formatLine(l)).join('');

        const parseRow = (line) =>
            line.trim().split('|').slice(1, -1).map(cell => this.escapeHtml(cell.trim()));

        const headerCells = parseRow(tableLines[0]);

        // Check if second row is separator (---|---|---)
        const isSeparator = /^\|[\s\-:]+(\|[\s\-:]+)+\|$/.test(tableLines[1].trim());
        const dataStart = isSeparator ? 2 : 1;

        let html = '<table style="width:100%;border-collapse:collapse;margin:0.5rem 0;font-size:0.82rem;">';

        // Header
        html += '<thead><tr>';
        for (const cell of headerCells) {
            html += '<th style="background:#f0f3f7;padding:0.4rem 0.6rem;border:1px solid #d8dde6;text-align:left;font-weight:600;color:#032d60;">';
            html += cell.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>');
            html += '</th>';
        }
        html += '</tr></thead>';

        // Body
        html += '<tbody>';
        for (let r = dataStart; r < tableLines.length; r++) {
            const cells = parseRow(tableLines[r]);
            html += '<tr>';
            for (let c = 0; c < cells.length; c++) {
                const cellContent = (cells[c] || '').replace(/\*\*(.+?)\*\*/g, '<b>$1</b>');
                html += '<td style="padding:0.35rem 0.6rem;border:1px solid #e5e5e5;">' + cellContent + '</td>';
            }
            html += '</tr>';
        }
        html += '</tbody></table>';

        return html;
    }

    formatLine(line) {
        let html = this.escapeHtml(line);

        // Headers: ### -> h4, ## -> h3 (keep them compact in chat)
        if (html.match(/^#{3,}\s+/)) {
            html = '<b>' + html.replace(/^#{3,}\s+/, '') + '</b><br/>';
            return html;
        }
        if (html.match(/^#{2}\s+/)) {
            html = '<br/><b style="font-size:1.05em;">' + html.replace(/^#{2}\s+/, '') + '</b><br/>';
            return html;
        }
        if (html.match(/^#\s+/)) {
            html = '<br/><b style="font-size:1.1em;">' + html.replace(/^#\s+/, '') + '</b><br/>';
            return html;
        }

        // Horizontal rule
        if (/^-{3,}$/.test(html.trim()) || /^\*{3,}$/.test(html.trim())) {
            return '<br/>';
        }

        // Bold
        html = html.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>');

        // Bullet points
        html = html.replace(/^[\-\*]\s+(.+)$/, '&#8226; $1');

        // Numbered lists
        html = html.replace(/^\d+\.\s+(.+)$/, '&#8226; $1');

        return html + '<br/>';
    }

    escapeHtml(text) {
        return text
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }

    // --- Utilities ---

    scrollToBottom() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const container = this.refs.chatContainer;
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }, 100);
    }
}
