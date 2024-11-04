@isTest
public class PartyControllerTest {
    @isTest
    static void testGetAllParties() {
        Party__c party = new Party__c(Party_Name__c='Green Alliance', Description__c='A progressive environmental party', PartyCode__c='GA');
        insert party;

        List<Party__c> parties = PartyController.getAllParties();
        System.assertNotEquals(0, parties.size(), 'Expected parties to be returned');
        System.assertEquals('Green Alliance', parties[0].Party_Name__c, 'Expected name to match inserted party');
    }
}
