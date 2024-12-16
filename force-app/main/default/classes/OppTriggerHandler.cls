public class OppTriggerHandler {
    
    List<Opportunity> triggerNewlist;
    List<Opportunity> triggerOldlist;
    Map<id,Opportunity> triggerNewMap;
    Map<id,Opportunity> triggerOldMap;
    
    set<Id> oppIdToProcess = new set<Id>();
    
    public OppTriggerHandler()
    {
        triggerNewlist =  (List<Opportunity>)Trigger.New;
        triggerOldlist = (List<Opportunity>)Trigger.Old;
        triggerNewMap =  (Map<id,Opportunity>)Trigger.NewMap;
        triggerOldMap =  (Map<id,Opportunity>)Trigger.OldMap;
    }
    
    public void doAction()
    {
        switch on Trigger.operationType
        {
            When After_Update
            {
                for(Opportunity opp:triggerNewlist)
                {
                    if(opp.Email_Quotes__c == true)  // Checking if Email Quotes checkbox was checked or not.
                    {
                        if(triggerOldMap.get(opp.Id).Email_Quotes__c == false) // Ensuring Opportunity is triggered for Email_Quotes__c update only.
                        {      
                            oppIdToProcess.add(opp.Id); //collecting those ids to process
                            
                        }
                    }
                }
                EmailQuoteFromOppHelper.emailQuoteFromOpp(oppIdToProcess); //Best Practice - Seperation principle, this logic will be handled by helper class.
            }
        }   
            
            
    }

}