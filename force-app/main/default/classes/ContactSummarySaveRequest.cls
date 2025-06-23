public with sharing class ContactSummarySaveRequest {
    // A no-argument constructor is required for Flow to use this as an Apex-Defined variable.
    public ContactSummarySaveRequest() {}

    @AuraEnabled @InvocableVariable(required=true)
    public Id accountId;
    
    @AuraEnabled @InvocableVariable(required=true)
    public List<ContactSummary> selectedSummaries;
}