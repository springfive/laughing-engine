public class BypassTriggers {
    
    public static Boolean canTrigger() {
        Boolean bypassTriggers = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].BypassTriggers__c;
        return !bypassTriggers;
    }
}