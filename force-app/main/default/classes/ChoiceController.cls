public with sharing class ChoiceController {
    @AuraEnabled
    public static void createOrUpdateChoice(Id partyId, String comment) {

        Choice__c choice;

        try {
            List<Choice__c> choices = [SELECT Id, Party__c FROM Choice__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
            if (!choices.isEmpty()) {
                choice = choices[0];
            } else {
                choice = new Choice__c(User__c = UserInfo.getUserId());
            }

            choice.Party__c = partyId;
            choice.Comment__c = comment;
            choice.LastVoteDate__c = Date.today();
            upsert choice;
            
        } catch (Exception e) {
            System.debug('Error during choice saving: ' + e.getMessage());
            throw new AuraHandledException('Failed to save choice: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Choice__c getUserChoice() {
        try {
            List<Choice__c> choices = [SELECT Id, Party__c, Comment__c FROM Choice__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
            return choices.isEmpty() ? null : choices[0];
        } catch (Exception e) {
            System.debug('Error fetching user choice: ' + e.getMessage());
            throw new AuraHandledException('Failed to retrieve user choice: ' + e.getMessage());
        }
    }
}
