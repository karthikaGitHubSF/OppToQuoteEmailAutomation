@isTest
public class EmailQuoteFromOppHelperTest {

    @testSetup
    static void loadData()
    {
        // Create Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create Contact
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe',Email = 'johndoe@example.com', AccountId = testAccount.Id);
        insert testContact;

        // Create Opportunity
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                                                      StageName = 'Prospecting',
                                                      CloseDate = Date.today().addDays(30),
                                                      AccountId = testAccount.Id,
                                                      Email_Quotes__c = false);
        insert testOpportunity;

        // Create Opportunity Contact Role
        OpportunityContactRole contactRole = new OpportunityContactRole(ContactId = testContact.Id,
                                                                         OpportunityId = testOpportunity.Id,
                                                                         IsPrimary = true);
        insert contactRole;

        // Create Quote
        Quote testQuote = new Quote(Name = 'Test Quote', OpportunityId = testOpportunity.Id);
        insert testQuote;

        //creating quotedoc
        Blob documentBody = Blob.toPdf('Sample PDF content');
        QuoteDocument testQuoteDocument = new QuoteDocument(QuoteId = testQuote.Id,
                                                             Document = documentBody);
        insert testQuoteDocument;
    }
    
    @isTest
    static void testEmailQuoteFromOpp() {

        List<Opportunity> oppTest = [Select Id,Email_Quotes__c From Opportunity];
        // Update Opportunity to trigger the logic
        oppTest[0].Email_Quotes__c = true;
        update oppTest;

        // Verify that emails were sent
        Integer sentEmails = Limits.getEmailInvocations();
        System.assertEquals(1, sentEmails, 'One email should have been sent.');

     }
}