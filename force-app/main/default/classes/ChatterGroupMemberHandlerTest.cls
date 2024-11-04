@isTest
public class ChatterGroupMemberHandlerTest {
    @testSetup
    static void setup() {
        // create profile and user for test
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User user1 = new User(
            Alias = 'u1',
            Email = 'u1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'u1_' + String.valueOf(DateTime.now().getTime()) + '@test.com'
        );
        
        insert user1;

        //create chatter group
        CollaborationGroup chatterGroup = new CollaborationGroup(Name = 'Test Chatter Group', CollaborationType = 'Public');
        insert chatterGroup;
    }

    // event "Add"
    @isTest
    static void testProcessGroupMemberChangesInsert() {
        CollaborationGroup chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];

        List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>{
            new CollaborationGroupMember(CollaborationGroupId = chatterGroup.Id, MemberId = user1.Id)
        };

        Test.startTest();

        ChatterGroupMemberHandler.processGroupMemberChanges(newMembers, null, true);

        System.assertEquals(1, newMembers.size(), 'An "Add" event should have been created');

        Test.stopTest();
    }

    // event "Remove"
    @isTest
    static void testProcessGroupMemberChangesRemove() {
        CollaborationGroup chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];

       CollaborationGroupMember existingMember = new CollaborationGroupMember(
            CollaborationGroupId = chatterGroup.Id,
            MemberId = user1.Id
        );
        insert existingMember;

        Map<Id, CollaborationGroupMember> oldMap = new Map<Id, CollaborationGroupMember>{ existingMember.Id => existingMember };

        Test.startTest();

        ChatterGroupMemberHandler.processGroupMemberChanges(null, oldMap, false);

        System.assertEquals(1, oldMap.size(), 'A "Remove" event should have been created');

        Test.stopTest();
    }
}
