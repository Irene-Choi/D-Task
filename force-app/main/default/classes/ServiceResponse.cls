public class ServiceResponse {
    @AuraEnabled @InvocableVariable public Boolean isSuccess = false;
    @AuraEnabled @InvocableVariable public Integer statusCode;
    @AuraEnabled @InvocableVariable public String responseBody;
    @AuraEnabled @InvocableVariable public String errorMessage;

    public ServiceResponse() {}

    public ServiceResponse(Boolean isSuccess, Integer statusCode, String responseBody, String errorMessage) {
        this.isSuccess = isSuccess;
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.errorMessage = errorMessage;
    }
}