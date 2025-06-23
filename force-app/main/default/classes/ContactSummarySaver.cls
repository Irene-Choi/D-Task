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
}