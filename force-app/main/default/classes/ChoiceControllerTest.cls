@isTest
public class ChoiceControllerTest {
    // create user for test
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }

    @isTest
    static void testCreateOrUpdateChoice() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Party__c party = new Party__c(Party_Name__c='Freedom Movement', Description__c='Liberal party', PartyCode__c='FM');
            insert party;

            ChoiceController.createOrUpdateChoice(party.Id, 'Great party!');
            
            Choice__c choice = [SELECT Party__c, Comment__c FROM Choice__c WHERE User__c = :testUser.Id LIMIT 1];
            System.assertEquals(party.Id, choice.Party__c, 'Expected party ID to match selected party');
            System.assertEquals('Great party!', choice.Comment__c, 'Expected comment to match input');
        }
    }

    @isTest
    static void testGetUserChoice() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            Party__c party = new Party__c(Party_Name__c='Green Alliance', Description__c='Environmental party', PartyCode__c='GA');
            insert party;

            Choice__c choice = new Choice__c(User__c = testUser.Id, Party__c = party.Id, Comment__c='Supporting green policies');
            insert choice;

            Choice__c fetchedChoice = ChoiceController.getUserChoice();
            System.assertNotEquals(null, fetchedChoice, 'Expected a choice to be returned');
            System.assertEquals('Supporting green policies', fetchedChoice.Comment__c, 'Expected comment to match saved comment');
        }
    }
}
