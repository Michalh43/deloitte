@isTest
public class GroupMemberEventHandlerTest {
    @testSetup
    static void setup() {
        // Creating mock users with unique usernames
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String uniqueSuffix = String.valueOf(DateTime.now().getTime()); // Creating a unique timestamp

        User user1 = new User(
            Alias = 'u1',
            Email = 'u1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'u1_' + uniqueSuffix + '@test.com' // Adding a unique suffix to username
        );
        
        User user2 = new User(
            Alias = 'u2',
            Email = 'u2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'u2_' + uniqueSuffix + '@test.com' // Adding a unique suffix to username
        );
        
        insert new List<User>{user1, user2};

        // Creating a mock Chatter Group
        CollaborationGroup chatterGroup = new CollaborationGroup(Name = 'Test Chatter Group', CollaborationType = 'Public');
        insert chatterGroup;

        // Creating a mock Public Group
        Group publicGroup = new Group(Name = 'Test Chatter Group', Type = 'Regular');
        insert publicGroup;
    }

    @isTest
    static void testProcessGroupMemberEvents() {
        // Fetching the ID of the Chatter Group created in setup
        CollaborationGroup chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];
        User user2 = [SELECT Id FROM User WHERE Alias = 'u2' LIMIT 1];

        // Creating mock group events
        List<GroupMemberEvent__e> events = new List<GroupMemberEvent__e>{
            new GroupMemberEvent__e(GroupName__c = 'Test Chatter Group', UserId__c = user1.Id, Action__c = 'Add'),
            new GroupMemberEvent__e(GroupName__c = 'Test Chatter Group', UserId__c = user2.Id, Action__c = 'Add')
        };

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();

        // Checking if members were added to the Public Group
        Group publicGroup = [SELECT Id FROM Group WHERE Name = 'Test Chatter Group' LIMIT 1];
        List<GroupMember> publicGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id];
        System.assertEquals(2, publicGroupMembers.size(), 'There should be two members in the Public Group');
    }

    @isTest
    static void testProcessGroupMemberChangesInsert() {
        CollaborationGroup chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];

        //create new member in chatter
        CollaborationGroupMember newMember = new CollaborationGroupMember(
            CollaborationGroupId = chatterGroup.Id,
            MemberId = user1.Id
        );

        insert newMember;

        Test.startTest();
        List<CollaborationGroupMember> newMembers = [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE Id = :newMember.Id];
        
        ChatterGroupMemberHandler.processGroupMemberChanges(newMembers, null, true);
        
       Test.getEventBus().deliver();

        Test.stopTest();

        Group publicGroup = [SELECT Id FROM Group WHERE Name = 'Test Chatter Group' LIMIT 1];
        List<GroupMember> publicGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id];
        
        System.assert(!publicGroupMembers.isEmpty(), 'There should be at least one member in the Public Group');
        System.assert(publicGroupMembers[0].UserOrGroupId == user1.Id, 'The member added in the Chatter Group should be present in the Public Group');
    }

    @isTest
    static void testProcessGroupMemberChangesRemove() {
        CollaborationGroup chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];
    
        CollaborationGroupMember member = new CollaborationGroupMember(
            CollaborationGroupId = chatterGroup.Id,
            MemberId = user1.Id
        );
        insert member;
    
        List<GroupMemberEvent__e> addEvent = new List<GroupMemberEvent__e>{
            new GroupMemberEvent__e(GroupName__c = 'Test Chatter Group', UserId__c = user1.Id, Action__c = 'Add')
        };
        EventBus.publish(addEvent);
    
        List<GroupMemberEvent__e> events = new List<GroupMemberEvent__e>{
            new GroupMemberEvent__e(GroupName__c = 'Test Chatter Group', UserId__c = user1.Id, Action__c = 'Remove')
        };
    
        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();
    
       Group publicGroup = [SELECT Id FROM Group WHERE Name = 'Test Chatter Group' LIMIT 1];
        List<GroupMember> publicGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id];
        System.debug('Public Group Members after remove event: ' + publicGroupMembers);
    
        publicGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id AND UserOrGroupId = :user1.Id];
        System.assertEquals(1, publicGroupMembers.size(), 'The member deleted from the Chatter Group should not be present in the Public Group');
    }
    
}
