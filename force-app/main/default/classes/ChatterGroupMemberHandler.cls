public class ChatterGroupMemberHandler {
    public static void processGroupMemberChanges(List<CollaborationGroupMember> newMembers, Map<Id, CollaborationGroupMember> oldMap, Boolean isInsert) {
        List<GroupMemberEvent__e> events = new List<GroupMemberEvent__e>();

        if (isInsert) {
            for (CollaborationGroupMember member : newMembers) {
                String groupName = [SELECT Name FROM CollaborationGroup WHERE Id = :member.CollaborationGroupId].Name;
                events.add(new GroupMemberEvent__e(
                    Action__c = 'Add',
                    UserId__c = String.valueOf(member.MemberId),
                    GroupName__c = groupName
                ));
            }
        } else {
            for (CollaborationGroupMember member : oldMap.values()) {
                String groupName = [SELECT Name FROM CollaborationGroup WHERE Id = :member.CollaborationGroupId].Name;
                events.add(new GroupMemberEvent__e(
                    Action__c = 'Remove',
                    UserId__c = String.valueOf(member.MemberId),
                    GroupName__c = groupName
                ));
            }
        }

        if (!events.isEmpty()) {
            EventBus.publish(events);
        }
    }
}
