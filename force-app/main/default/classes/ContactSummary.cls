/**
 * @description Apex-Defined data type for a single contact summary row.
 *              MUST be a top-level public class to be visible to Flow as a variable type.
 */
public class ContactSummary {
    // A no-argument constructor is required for Flow to use this as an Apex-Defined variable.
    public ContactSummary() {}

    @AuraEnabled @InvocableVariable(label='Type')
    public String type;

    @AuraEnabled @InvocableVariable(label='State')
    public String state;

    @AuraEnabled @InvocableVariable(label='Contact Count')
    public Integer count;
}