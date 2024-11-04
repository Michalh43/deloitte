trigger ChatterGroupMemberTrigger on CollaborationGroupMember (after insert, after delete) {
    if (Trigger.isInsert) {
        ChatterGroupMemberHandler.processGroupMemberChanges(Trigger.new, null, true);
    } else if (Trigger.isDelete) {
        ChatterGroupMemberHandler.processGroupMemberChanges(null, Trigger.oldMap, false);
    }
}
