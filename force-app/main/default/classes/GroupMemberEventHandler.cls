public class GroupMemberEventHandler {
    public static void processGroupMemberEvents(List<GroupMemberEvent__e> events) {
        List<GroupMember> newPublicGroupMembers = new List<GroupMember>();
        List<GroupMember> publicGroupMembersToDelete = new List<GroupMember>();

        for (GroupMemberEvent__e event : events) {
            String groupName = event.GroupName__c;
            Id userId = Id.valueOf(event.UserId__c);

            Id publicGroupId = getOrCreatePublicGroup(groupName);

            if (event.Action__c == 'Add') {
                newPublicGroupMembers.add(new GroupMember(GroupId = publicGroupId, UserOrGroupId = userId));
            } else if (event.Action__c == 'Remove') {
                List<GroupMember> groupMembersToDelete = [
                    SELECT Id FROM GroupMember WHERE GroupId = :publicGroupId AND UserOrGroupId = :userId
                ];
                if (!groupMembersToDelete.isEmpty()) {
                    publicGroupMembersToDelete.addAll(groupMembersToDelete);
                }
            }
        }

        if (!newPublicGroupMembers.isEmpty()) {
            insert newPublicGroupMembers;
        }
        if (!publicGroupMembersToDelete.isEmpty()) {
            delete publicGroupMembersToDelete;
        }
    }

    private static Id getOrCreatePublicGroup(String groupName) {
        List<Group> publicGroups = [SELECT Id FROM Group WHERE Name = :groupName LIMIT 1];
    
        if (publicGroups.isEmpty()) {
            Group publicGroup = new Group(Name = groupName, Type = 'Regular');
            insert publicGroup;
            return publicGroup.Id;
        } else {
            return publicGroups[0].Id;
        }
    }
}
