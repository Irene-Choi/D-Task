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

    // @InvocableMethod(label='Get Contact Summary Data ContactSummaryWrapper' description='Returns ContactSummaryWrapper')
    // public static List<ContactSummaryWrapper> getContactSummaryData(List<ContactSummaryInput> inputs) {
    //     Id accountId = inputs[0].accountId;
    //     List<ContactSummary> result = new List<ContactSummary>();

    //     for (AggregateResult ar : [
    //         SELECT Type__c type, MailingStateCode state, COUNT(Id) cnt
    //         FROM Contact
    //         WHERE AccountId = :accountId
    //         GROUP BY Type__c, MailingStateCode
    //     ]) {
    //         ContactSummary row = new ContactSummary();
    //         row.type = (String) ar.get('type');
    //         row.state = (String) ar.get('state');
    //         row.count = (Integer) ar.get('cnt');
    //         // row.selected = false;
    //         result.add(row);
    //     }

    //     ContactSummaryWrapper response = new ContactSummaryWrapper();
    //     response.summaries = result;
    //     return new List<ContactSummaryWrapper>{response};
    // }

    // @InvocableMethod(label='Get Contact Summary Data ContactSummary' description='Returns ContactSummary')
    // public static List<ContactSummary> getContactSummaryData(List<ContactSummaryInput> inputs) {
    //     Id accountId = inputs[0].accountId;
    //     List<ContactSummary> result = new List<ContactSummary>();

    //     for (AggregateResult ar : [
    //         SELECT Type__c type, MailingStateCode state, COUNT(Id) cnt
    //         FROM Contact
    //         WHERE AccountId = :accountId
    //         GROUP BY Type__c, MailingStateCode
    //     ]) {
    //         ContactSummary row = new ContactSummary();
    //         row.type = (String) ar.get('type');
    //         row.state = (String) ar.get('state');
    //         row.count = (Integer) ar.get('cnt');
    //         row.selected = false;
    //         result.add(row);
    //     }
    //     return result;
    // }
}