public with sharing class ContactSummaryController {
    @AuraEnabled(cacheable=true)
    public static Map<Id, List<ContactSummary>> getGroupedContactCounts(List<Id> accountIds) {
        // system.debug('accountIds: ' + accountIds);
        Map<Id, List<ContactSummary>> resultMap = new Map<Id, List<ContactSummary>>();

        for (AggregateResult ar : [
            SELECT AccountId, Type__c type, MailingStateCode state, COUNT(Id) cnt
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId, Type__c, MailingStateCode
        ]) {
            Id accId = (Id) ar.get('AccountId');
            ContactSummary row = new ContactSummary();
            row.type = (String) ar.get('type');
            row.state = (String) ar.get('state');
            row.count = (Integer) ar.get('cnt');

            if (!resultMap.containsKey(accId)) {
                resultMap.put(accId, new List<ContactSummary>());
            }
            resultMap.get(accId).add(row);
        }

        return resultMap;
    }

    @AuraEnabled
    public static ServiceResponse saveContactSummaries(String jsonPayload) {
        ServiceResponse resp = new ServiceResponse();

        Map<Id, List<ContactSummary>> accountToSelections = 
            (Map<Id, List<ContactSummary>>)JSON.deserialize(
                jsonPayload,
                Map<Id, List<ContactSummary>>.class
            );

        if (accountToSelections == null || accountToSelections.isEmpty()) {
            resp.errorMessage = 'Please select at least one row.';
            return resp;
            // throw new AuraHandledException('Invalid input.');
        }
        system.debug('accountToSelections: ' + accountToSelections);
        Set<Id> accountIds = accountToSelections.keySet();

        List<Contact_Summary__c> toUpsert = new List<Contact_Summary__c>();

        for (Id accId : accountToSelections.keySet()) {
            List<ContactSummary> selectedRows = accountToSelections.get(accId);
            for (ContactSummary wrapper : selectedRows) {
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
            try {
                Database.UpsertResult[] results = Database.upsert(toUpsert, Contact_Summary__c.Fields.Unique_Key__c, true);
            } catch (DMLException e) {
                List<String> errors = new List<String>();
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    errors.add(e.getDmlMessage(i));
                }
                resp.errorMessage = String.join(errors, '\n');
            } catch (Exception e) {
                resp.errorMessage  = e.getMessage();
            }
        }

        // if (!toUpsert.isEmpty()) {
        //     Database.UpsertResult[] results = Database.upsert(toUpsert, Contact_Summary__c.Fields.Unique_Key__c, false); // partial success allowed
        //     List<String> failed = new List<String>();

        //     for (Integer i = 0; i < results.size(); i++) {
        //         if (!results[i].isSuccess()) {
        //             String err = results[i].getErrors()[0].getMessage();
        //             Contact_Summary__c failedRec = toUpsert[i];
        //             failed.add('Type: ' + failedRec.Contact_Type__c + ', State: ' + failedRec.State__c + ' — ' + err);
        //         }
        //     }

        //     if (!failed.isEmpty()) {
        //         resp.errorMessage  = String.join(failed, '\n');
        //         // throw new AuraHandledException(String.join(failed, '\n'));
        //     } else {
        //         resp.isSuccess = true;
        //     }
        // }
        return resp;
    }
}