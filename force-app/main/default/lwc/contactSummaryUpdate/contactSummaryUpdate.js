import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGroupedContactCounts from '@salesforce/apex/ContactSummaryController.getGroupedContactCounts';
import saveContactSummaries    from '@salesforce/apex/ContactSummaryController.saveContactSummaries';

export default class ContactSummaryUpdate extends LightningElement {
    _recordId; // Account Id from Quick Action
    @api
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadSummary();
        }
    }
    get recordId() {
        return this._recordId;
    }

    tableData = [];
    error;
    columns = [
        { label: 'Type', fieldName: 'type' },
        { label: 'State', fieldName: 'state' },
        { label: '# of Contacts', fieldName: 'count', type: 'number' }
    ];
    selectedRows = [];

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        // console.log('Rows selected: ' + JSON.stringify(this.selectedRows));
    }

    loadSummary() {
        if (!this.recordId) {
            return; 
        }
        getGroupedContactCounts({ accountIds: [this.recordId] })
        .then(result => {
            this.tableData = result[this.recordId];
        })
        .catch(error => {
            this.error = error.body?.message || error.message;
        });
    }

    async handleSave() {
        if (!this.selectedRows.length) {
            this.showToast('Warning', 'Please select at least one row.', 'warning');
            return;
        }

        const selectionsByAccount = {
            [this.recordId]: this.selectedRows
        };
        const payloadJson = JSON.stringify(selectionsByAccount);
        console.log('Sending bulk-ready JSON payload:', payloadJson);

        try {
            await saveContactSummaries({ jsonPayload: payloadJson });
            this.showToast('Success', 'Contact summaries updated.', 'success');
            this.closeAction();
        } catch (error) {
            // const message = error.body?.message || error.message || 'An unexpected error occurred.';
            // this.showToast('Error', message, 'error');

            let errorMessage = 'An unexpected error occurred.';
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message.replace(/\n/g, '<br/>');
            }
            this.error = errorMessage;
        }
    }

    closeAction() {
        console.log('closeAction() called.');
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.error = '';
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // 'success', 'error', 'warning', 'info'
        });
        this.dispatchEvent(evt);
    }
}