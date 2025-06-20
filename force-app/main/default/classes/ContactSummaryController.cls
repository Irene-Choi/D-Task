public with sharing class ContactSummaryController {
    
    public class ContactGroupWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public String state;
        @AuraEnabled public Integer count;

        public ContactGroupWrapper() {}

        public ContactGroupWrapper(String type, String state, Integer count) {
            this.type = type;
            this.state = state;
            this.count = count;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<ContactGroupWrapper>> getGroupedContactCounts(List<Id> accountIds) {
        // system.debug('accountIds: ' + accountIds);
        Map<Id, List<ContactGroupWrapper>> resultMap = new Map<Id, List<ContactGroupWrapper>>();

        for (AggregateResult ar : [
            SELECT AccountId, Type__c, MailingStateCode, COUNT(Id) cnt
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId, Type__c, MailingStateCode
        ]) {
            Id accId = (Id) ar.get('AccountId');
            String type = (String) ar.get('Type__c');
            String state = (String) ar.get('MailingStateCode');
            Integer count = (Integer) ar.get('cnt');

            ContactGroupWrapper wrapper = new ContactGroupWrapper(type, state, count);

            if (!resultMap.containsKey(accId)) {
                resultMap.put(accId, new List<ContactGroupWrapper>());
            }
            resultMap.get(accId).add(wrapper);
        }
        // system.debug('resultMap: ' + resultMap);

        return resultMap;
    }

    @AuraEnabled
    public static void saveContactSummaries(String jsonPayload) {
        Map<Id, List<ContactGroupWrapper>> accountToSelections = 
            (Map<Id, List<ContactGroupWrapper>>)JSON.deserialize(
                jsonPayload,
                Map<Id, List<ContactGroupWrapper>>.class
            );

        if (accountToSelections == null || accountToSelections.isEmpty()) {
            throw new AuraHandledException('Invalid input.');
        }
        // system.debug('accountToSelections: ' + accountToSelections);
        Set<Id> accountIds = accountToSelections.keySet();

        List<Contact_Summary__c> toUpsert = new List<Contact_Summary__c>();

        for (Id accId : accountToSelections.keySet()) {
            List<ContactGroupWrapper> selectedRows = accountToSelections.get(accId);
            for (ContactGroupWrapper wrapper : selectedRows) {
                String uniqueKey = accId + '-' + wrapper.type + '-' + wrapper.state;

                toUpsert.add(new Contact_Summary__c(
                    Account__c = accId,
                    Contact_Type__c = wrapper.type,       
                    State__c = wrapper.state,        
                    Contact_Count__c = wrapper.count,
                    Unique_Key__c = uniqueKey 
                ));
            }
        }

        if (!toUpsert.isEmpty()) {
            Database.UpsertResult[] results = Database.upsert(toUpsert, Contact_Summary__c.Fields.Unique_Key__c, true);
            List<String> failed = new List<String>();

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    String err = results[i].getErrors()[0].getMessage();
                    Contact_Summary__c failedRec = toUpsert[i];
                    failed.add('Type: ' + failedRec.Contact_Type__c + ', State: ' + failedRec.State__c + ' — ' + err);
                }
            }

            if (!failed.isEmpty()) {
                throw new AuraHandledException(String.join(failed, '\n'));
            }
        }
    }
}