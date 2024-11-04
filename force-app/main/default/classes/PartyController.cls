public with sharing class PartyController {
    @AuraEnabled(cacheable=true)
    public static List<Party__c> getAllParties() {
        return [SELECT Id, Party_Name__c, Description__c, PartyCode__c, LeaderName__c FROM Party__c];
    }
}
