/**
 * @description Provides an invocable method to save (upsert) contact summary records.
 */
public with sharing class ContactSummarySaver {

    @InvocableMethod(label='Save Contact Summaries using ContactSummaryController' description='Creates or updates Contact Summary records.')
    public static List<ServiceResponse> saveContactSummaries(List<ContactSummarySaveRequest> requests) {
        system.debug('ContactSummarySaver requests: ' + requests);
        Map<Id, List<ContactSummary>> accountToSummaries = new Map<Id, List<ContactSummary>>();
        for (ContactSummarySaveRequest req : requests) {
            if (req.accountId != null && req.selectedSummaries != null && !req.selectedSummaries.isEmpty()) {
                if (accountToSummaries.containsKey(req.accountId)) {
                    accountToSummaries.get(req.accountId).addAll(req.selectedSummaries);
                } else {
                    accountToSummaries.put(req.accountId, req.selectedSummaries);
                }
            }
        }
        string jsonPayload = JSON.serialize(accountToSummaries);
        system.debug('jsonPayload: ' + jsonPayload);
        ServiceResponse response = ContactSummaryController.saveContactSummaries(jsonPayload);
        
        List<ServiceResponse> results = new List<ServiceResponse>();
        results.add(response);
        return results;
    }

    // @InvocableMethod(label='Save Contact Summaries' description='Creates or updates Contact Summary records.')
    // public static void saveContactSummaries(List<ContactSummaryWrappers.SaveRequest> requests) {
        
    //     List<Contact_Summary__c> summariesToUpsert = new List<Contact_Summary__c>();

    //     for (ContactSummaryWrappers.SaveRequest request : requests) {
    //         if (request.accountId == null || request.selectedSummaries == null) continue;
            
    //         for (ContactSummaryWrappers.ContactSummary selected : request.selectedSummaries) {
    //             summariesToUpsert.add(new Contact_Summary__c(
    //                 Account__c = request.accountId,
    //                 Contact_Type__c = selected.type,
    //                 State__c = selected.state,
    //                 Contact_Count__c = selected.contactCount,
    //                 Unique_Key__c = request.accountId + '-' + selected.type + '-' + selected.state
    //             ));
    //         }
    //     }
        
    //     if (!summariesToUpsert.isEmpty()) {
    //         try {
    //             Database.upsert(summariesToUpsert, Contact_Summary__c.Fields.Unique_Key__c, false);
    //         } catch (Exception e) {
    //             throw new AuraHandledException(e.getMessage());
    //         }
    //     }
    // }
}