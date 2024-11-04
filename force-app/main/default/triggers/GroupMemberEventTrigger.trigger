trigger GroupMemberEventTrigger on GroupMemberEvent__e (after insert) {
    System.debug('event trigger: ');
    GroupMemberEventHandler.processGroupMemberEvents(Trigger.new);
}
