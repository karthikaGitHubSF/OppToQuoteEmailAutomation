trigger OpportunityTrigger on Opportunity (after update) {
    
    //logic less Trigger as per Best Practice
    OppTriggerHandler obj = new OppTriggerHandler();
    obj.doAction();
    

}