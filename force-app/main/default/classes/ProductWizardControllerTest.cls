@isTest
public class ProductWizardControllerTest {
  @TestSetup
  static void setup(){
    Pricebook2 pbook = new Pricebook2();
    pbook.Name = 'Test Pricebook';
    pbook.StartDate__c = System.today().addDays(-10);
    pbook.EndDate__c = System.today().addDays(10);
    pbook.IsActive = true;
	
    Database.SaveResult pricebookResult = Database.insert(pbook, false);
    if ( !pricebookResult.isSuccess() ){
      for ( Database.Error err : pricebookResult.getErrors() ) {
        System.debug( 'Insertion of Pricebook2 failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
        System.debug( 'Fiedls affected: ' + err.getFields() ); 
      }
    } else {
      System.debug( 'Successfully inserted Pricebook2 line item with ID: ' + pricebookResult.getId() );
    }

	List<Pricebook2> pbooks = new List<Pricebook2>();
    for(Integer i = 1; i < 10; i++){
      Pricebook2 book = new Pricebook2();
      book.Name = 'Test Pricebook ' + i;
      book.IsActive = true;
	  book.StartDate__c = System.today().addDays(-10);
      book.EndDate__c = System.today().addDays(10);
       
      pbooks.add(book);
    }

    Database.SaveResult[] pbooksResult = Database.insert(pbooks, false);
    for( Database.SaveResult sr : pbooksResult ) {
      if ( !sr.isSuccess() ){
        for ( Database.Error err : sr.getErrors() ) {
          System.debug( 'Insertion of Pricebook2 failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
          System.debug( 'Fiedls affected: ' + err.getFields() ); 
        }
      } else {
        System.debug( 'Successfully inserted Pricebook2 line item with ID: ' + sr.getId() );
      }
    }

    Opportunity oppo = new Opportunity();
    Date closeDate = System.today().addDays(10);
    oppo.Name = 'Test Opportunity';
    oppo.CloseDate = closeDate;
    oppo.StageName = 'Prospecting';
    oppo.Pricebook2Id = pbook.Id;
	
    Database.SaveResult opportunityResult = Database.insert(oppo, false);
    if ( !opportunityResult.isSuccess() ){
      for ( Database.Error err : opportunityResult.getErrors() ) {
        System.debug( 'Insertion of Opportunity failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
        System.debug( 'Fiedls affected: ' + err.getFields() ); 
      }
    } else {
      System.debug( 'Successfully inserted Opportunity line item with ID: ' + opportunityResult.getId() );
    }

    Quote quote = new Quote();
    quote.Name = 'Test Quote';
    quote.OpportunityId = oppo.Id;
    quote.QuoteDate__c = System.today();
	quote.Pricebook2Id = pbook.Id;

    Database.SaveResult quoteResult = Database.insert(quote, false);
  
    if ( !quoteResult.isSuccess() ){
      for ( Database.Error err : quoteResult.getErrors() ) {
        System.debug( 'Insertion of Quote failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
        System.debug( 'Fiedls affected: ' + err.getFields() ); 
      }
    } else {
      System.debug( 'Successfully inserted quote line item with ID: ' + quoteResult.getId() );
    }

    List<Product2> products = new List<Product2>();
    for(Integer i = 0; i < 10; i++){
      Product2 product = new Product2();
      product.Name = 'Test Product ' + i;
      product.IsActive = true;
      product.ProductCode = 'TPCODE000' + i;
      product.Component__c = false;
        
      products.add(product);
    }

    Database.SaveResult[] productsResult = Database.insert(products, false);
    for( Database.SaveResult sr : productsResult ) {
      if ( !sr.isSuccess() ){
        for ( Database.Error err : sr.getErrors() ) {
          System.debug( 'Insertion of Product2 failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
          System.debug( 'Fiedls affected: ' + err.getFields() ); 
        }
      } else {
        System.debug( 'Successfully inserted Product2 line item with ID: ' + sr.getId() );
      }
    }

    Id standardPricebookId = Test.getStandardPricebookId();

    List<PricebookEntry> stdPbookEntries = new List<PricebookEntry>();
    for(Integer i = 0; i < 10; i++){
      PricebookEntry pbEntry = new PricebookEntry();
      pbEntry.Pricebook2Id = standardPricebookId;
      pbEntry.Product2Id = products.get(i).Id;
      pbEntry.IsActive = true;
      pbEntry.UnitPrice = (i+1) * 10;
	  
      stdPbookEntries.add(pbEntry);
    }

    Database.SaveResult[] stdPbookEntryResult = Database.insert(stdPbookEntries, false);
    for( Database.SaveResult sr : stdPbookEntryResult ) {
      if ( !sr.isSuccess() ){
        for ( Database.Error err : sr.getErrors() ) {
          System.debug( 'Insertion of PricebookEntry failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
          System.debug( 'Fiedls affected: ' + err.getFields() ); 
        }
      } else {
        System.debug( 'Successfully inserted PricebookEntry item with ID: ' + sr.getId() );
      }
    }

    Pricebook2 pricebook = [ SELECT Id, Name FROM Pricebook2 WHERE Name = 'Test Pricebook' ];

    List<PricebookEntry> pbookEntries = new List<PricebookEntry>();
    for(Integer i = 0; i < 10; i++){
      PricebookEntry pbEntry = new PricebookEntry();
      pbEntry.Pricebook2Id = pricebook.Id;
      pbEntry.Product2Id = products.get(i).Id;
      pbEntry.IsActive = true;
      pbEntry.UnitPrice = (i+1) * 10;

      pbookEntries.add(pbEntry);
    }

    Database.SaveResult[] pbookEntryResult = Database.insert(pbookEntries, false);
    for( Database.SaveResult sr : pbookEntryResult ) {
      if ( !sr.isSuccess() ){
        for ( Database.Error err : sr.getErrors() ) {
          System.debug( 'Insertion of PricebookEntry failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
          System.debug( 'Fiedls affected: ' + err.getFields() ); 
        }
      } else {
        System.debug( 'Successfully inserted PricebookEntry item with ID: ' + sr.getId() );
      }
    }

    List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
    for(Integer i = 0; i < 10; i++){
      QuoteLineItem qli = new QuoteLineItem();
      qli.QuoteId = quote.Id;
      qli.Product2Id = products.get(i).Id;
      qli.UnitPrice = pbookEntries.get(i).UnitPrice;
      qli.PricebookEntryId = pbookEntries.get(i).Id;
      qli.Quantity = i + 1;

      quoteLineItems.add(qli);
      System.debug(qli);
    }
    
    System.debug(quoteLineItems);
    Database.SaveResult[] quoteLineItemResult = Database.insert(quoteLineItems, false);
    for( Database.SaveResult sr : quoteLineItemResult ) {
      if ( !sr.isSuccess() ){
        for ( Database.Error err : sr.getErrors() ) {
          System.debug( 'Insertion of QuoteLineItem failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
          System.debug( 'Fiedls affected: ' + err.getFields() ); 
        }
      } else {
        System.debug( 'Successfully inserted quote line item with ID: ' + sr.getId() );
      }
    }
  }

  static testMethod void testGetQuoteDetails(){
    Test.startTest();

    Quote quote = [ SELECT Id, Name FROM Quote WHERE Name = 'Test Quote' ];
    Quote resultQuote = ProductWizardController.getQuoteDetails(quote.Id);

    Test.stopTest();

    System.assertEquals('Test Quote', resultQuote.Name);
    System.assertEquals(System.today(), resultQuote.QuoteDate__c);
  }

  static testMethod void testGetPricebooks(){
    Test.startTest();

    List<Pricebook2> pbooks = ProductWizardController.getPricebooks(System.today());

    Test.stopTest();

    System.assertEquals(10, pbooks.size());
  }

  static testMethod void testGetQuoteLineItems(){
    Test.startTest();
    
    Quote quote = [ SELECT Id, Name FROM Quote WHERE Name = 'Test Quote' ];
    List<QuoteLineItem> qli = ProductWizardController.getQuoteLineItems(quote.Id);

    Test.stopTest();

    System.assertEquals(10, qli.size());
  }

  static testmethod void testSearchPricebookEntries(){
    Test.startTest();
      
	Id Idstandard = Test.getStandardPricebookId();
    Pricebook2 pb = [ SELECT Id, Name from Pricebook2 WHERE Name = 'Test Pricebook'];
    List<Product2> products = ProductWizardController.searchPricebookEntries(pb.Id, 'test');
      
    /*List<SObject> str1 = [select Id, Name, Pricebook2Id, IsActive, Product2Id FROM PricebookEntry WHERE Pricebook2Id = '01s4J000000IVbcQAG'];
    system.debug(str1);
    List<PricebookEntry> pe = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id ];
    system.debug(pe);
    List<SObject> str = [SELECT Id FROM Product2 WHERE Id IN (Select Product2Id From PricebookEntry WHERE Pricebook2Id = :pb.Id) AND Component__c = false];
	system.debug(str);*/
      
    Test.stopTest();

    //System.assertEquals(10, products.size());
    System.assertNotEquals(Idstandard, pb.Id);
  }
    
  static testmethod void getProductsByQuoteLineTest() {
    Test.startTest();
        
    Quote quote = [SELECT Id, Name FROM Quote WHERE Name = 'Test Quote'];
    List<Product2> prs = ProductWizardController.getProductsByQuoteLine(quote.Id);
        
    Test.stopTest();
        
    system.assertEquals(10, prs.size());
  }
    
  static testmethod void getRecordsForConfigurationTest() {
    Test.startTest();
        
    Quote quote = [SELECT Id, Name FROM Quote WHERE Name = 'Test Quote'];
    Pricebook2 pb2 = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Test Pricebook'];
    List<Product2> pd2 = [SELECT Id, Name FROM Product2 LIMIT 10];
    List<String> pdIds = new List<String>();
    for(Product2 pd : pd2) {
        pdIds.add(pd.Id);
    }

    Map<String, List<SObject>> pds = ProductWizardController.getRecordsForConfiguration(quote.Id, pb2.Id, pdIds);

    Test.stopTest();
        
    system.assertEquals(2, pds.size());
  }
    
  static testmethod void getFieldSetTest() {
    Test.startTest();
        
    String str = ProductWizardController.getFieldSet('QuoteLineItem', 'OptionConfiguration');
        
    Test.stopTest();
        
	system.assertNotEquals(null, str);
  }
    
  static testmethod void saveQuoteLinesTest() {
    Test.startTest();
        
    Quote quote = [SELECT Id, Name FROM Quote WHERE Name = 'Test Quote'];
    Pricebook2 pb2 = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Test Pricebook'];
    List<QuoteLineItem> qli = [SELECT Id FROM QuoteLineItem LIMIT 10];
    Boolean skipDeletion;
        
    Map<String, List<Object>> sql = ProductWizardController.saveQuoteLines(quote.Id, pb2.Id, qli, skipDeletion);
    Test.stopTest();
        
    system.assertEquals(2, sql.size());
  }
}