public with sharing class ContactSummaryFetcher {

    public class ContactSummaryInput {
        @InvocableVariable(required=true)
        public Id accountId;
    }
    
    @InvocableMethod(label='Get Contact Summary Data from ContactSummaryController' description='Returns Contact summary list map')
    public static List<ContactSummaryWrapper> getContactSummaryData(List<ContactSummaryInput> inputs) {
        Id accountId = inputs[0].accountId;
        List<ContactSummary> result = new List<ContactSummary>();
        result = ContactSummaryController.getGroupedContactCounts(new List<Id>{accountId}).get(accountId);

        ContactSummaryWrapper response = new ContactSummaryWrapper();
        response.summaries = result;
        return new List<ContactSummaryWrapper>{response};
    }
}