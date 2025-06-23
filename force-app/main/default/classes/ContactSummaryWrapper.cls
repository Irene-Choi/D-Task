public with sharing class ContactSummaryWrapper {
    public ContactSummaryWrapper() {}
    @AuraEnabled @InvocableVariable
    public List<ContactSummary> summaries;
}