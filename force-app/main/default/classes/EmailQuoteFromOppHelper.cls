public class EmailQuoteFromOppHelper
{
    
    public static void emailQuoteFromOpp(set<Id> oppId)
    {
        //fetching quotes related to triggred Opportunities
        List<Quote> quoList =[Select Id,OpportunityId From Quote Where OpportunityId In :oppId];
        
       
        List<QuoteDocument> QDList = new List<QuoteDocument>();
         
        //fetching Associated Quote Documents available for the above fetched quotes
        if(!quoList.isEmpty())
            QDList = [Select Id,Name,QuoteId,Quote.OpportunityId,Document 
                      From QuoteDocument Where QuoteId In :quoList];

        //if quote document is available, then primary contact role is fetched along with Opportunity             
        if(!QDList.isEmpty())
        {
            Map<Id,Opportunity> oppCRMap =new Map<Id,Opportunity>([SELECT Id,Name,Owner.Name, (SELECT ContactId,Contact.Email 
                                                                                               FROM OpportunityContactRoles 
                                                                                               Where IsPrimary = True and Contact.Email != Null) 
                                                                   FROM Opportunity Where Id In :oppId]);
            // Initialize the map with oppId as key and list of Quote documents as values.
            Map<Id, List<QuoteDocument>> oppQuoteDocsMap = new Map<Id,List<QuoteDocument>>();
            
            // Populate the map
            for (QuoteDocument qd : QDList)
            {
                Id parentId = qd.Quote.OpportunityId;
                if (parentId != null) 
                {
                    if (!oppQuoteDocsMap.containsKey(parentId))
                    {
                        oppQuoteDocsMap.put(parentId, new List<QuoteDocument>());
                    }
                    oppQuoteDocsMap.get(parentId).add(qd);
                }
            }

            //Instantiate Messaging class for Email Service.
            Messaging.SingleEmailMessage[] messages = new List < Messaging.SingleEmailMessage >();  
            if(!oppCRMap.isEmpty())  //Ensuring Map is not empty to avoid exceptions
            {
                for(Opportunity opp:oppCRMap.values())
                {
                    if(!opp.OpportunityContactRoles.isEmpty() && opp.OpportunityContactRoles[0].Contact.Email != Null)
                    {
                    system.debug(opp.Name); //debugging for our evaluation.
                    system.debug(opp.OpportunityContactRoles[0].Contact.Email);
                    
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(opp.OpportunityContactRoles[0].ContactId); //to whom email to be sent.
                    message.setSenderDisplayName(opp.Owner.Name);
                    
                    message.setTemplateID(Label.emailTemplateId);
                    message.setWhatId(opp.ID); //important for the merge fields in template to work
                    message.toAddresses = new String[]{opp.OpportunityContactRoles[0].Contact.Email};
                        
                        
                        //Quote Pdf Attachment to the email
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    
                   if (oppQuoteDocsMap.containsKey(opp.Id) && oppQuoteDocsMap.get(opp.Id) != null) { 
                     for (QuoteDocument QD:oppQuoteDocsMap.get(opp.Id))
                    {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(QD.Name);
                        efa.setBody(QD.Document);
                        attachments.add(efa);
                    }
                   }
                    message.setFileAttachments(attachments);
                    messages.add(message);
                    }  
                }
                
                //Sending Mail
                try
               {
                             
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success)
                    System.debug('Email sent successfully.');
                else 
                    System.debug('Email failed Sending: '+results[0].errors[0].message);
               }
                Catch(Exception e)
                {
                    system.debug(e);
                }
            }  
            
        }
    }
}