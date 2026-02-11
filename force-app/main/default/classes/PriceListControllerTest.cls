@isTest
private class PriceListControllerTest {

    @isTest
    static void testPriceListController() {
        // --- Setup date ---
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name='Test Opp', 
            AccountId=acc.Id, 
            StageName='Prospecting', 
            CloseDate=Date.today()
        );
        insert opp;
        
        Quote q = new Quote(
            Name='Test Quote', 
            OpportunityId=opp.Id, 
            Pricebook2Id=Test.getStandardPricebookId()
        );
        insert q;
        
        // Produs minimal - doar required fields
        Product2 prod = new Product2(
            Name='AP01',
            Family='Apartment',
            Description='Apartament test'
        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(), 
            Product2Id=prod.Id, 
            UnitPrice=120000.0, 
            IsActive=true
        );
        insert pbe;
        
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId=q.Id, 
            PricebookEntryId=pbe.Id, 
            Quantity=1.0, 
            UnitPrice=120000.0
        );
        insert qli;

        Test.startTest();
        Test.setCurrentPage(Page.PriceListPage);
        ApexPages.currentPage().getParameters().put('id', q.Id);
        
        PriceListController controller = new PriceListController();
        Test.stopTest();

        System.assertNotEquals(null, controller.quoteDetails, 'Detaliile ofertei ar trebui încărcate.');
        System.assertEquals(1, controller.totalApartamente, 'Ar trebui să fie 1 apartament în total.');
        System.assertEquals(1, controller.priceRows.size(), 'Ar trebui să existe un rând în lista de prețuri.');
        System.assert(controller.priceRows[0].tip.contains('Apartament'), 'Tipul ar trebui tradus ca Apartament.');
    }

    @isTest
    static void testPriceListControllerWithParkingSpots() {
        Account acc = new Account(Name='Test Account 2');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name='Test Opp 2', 
            AccountId=acc.Id, 
            StageName='Prospecting', 
            CloseDate=Date.today()
        );
        insert opp;
        
        Quote q = new Quote(
            Name='Test Quote 2', 
            OpportunityId=opp.Id, 
            Pricebook2Id=Test.getStandardPricebookId()
        );
        insert q;
        
        Product2 apartment = new Product2(
            Name='AP02',
            Family='Apartment',
            Description='Apartament 2 camere'
        );
        insert apartment;
        
        Product2 parkingIndoor = new Product2(
            Name='PA_I_01',
            Family='Parking Spot Indoors',
            Description='Loc parcare subteran'
        );
        insert parkingIndoor;
        
        Product2 parkingOutdoor = new Product2(
            Name='PA_E_01',
            Family='Parking Spot Outdoors',
            Description='Loc parcare exterior'
        );
        insert parkingOutdoor;

        PricebookEntry pbeAp = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(), 
            Product2Id=apartment.Id, 
            UnitPrice=100000.0, 
            IsActive=true
        );
        insert pbeAp;
        
        PricebookEntry pbeParkIndoor = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(), 
            Product2Id=parkingIndoor.Id, 
            UnitPrice=15000.0, 
            IsActive=true
        );
        insert pbeParkIndoor;
        
        PricebookEntry pbeParkOutdoor = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(), 
            Product2Id=parkingOutdoor.Id, 
            UnitPrice=8000.0, 
            IsActive=true
        );
        insert pbeParkOutdoor;
        
        QuoteLineItem qliAp = new QuoteLineItem(
            QuoteId=q.Id, 
            PricebookEntryId=pbeAp.Id, 
            Quantity=1.0, 
            UnitPrice=100000.0
        );
        insert qliAp;
        
        QuoteLineItem qliParkIndoor = new QuoteLineItem(
            QuoteId=q.Id, 
            PricebookEntryId=pbeParkIndoor.Id, 
            Quantity=1.0, 
            UnitPrice=15000.0
        );
        insert qliParkIndoor;
        
        QuoteLineItem qliParkOutdoor = new QuoteLineItem(
            QuoteId=q.Id, 
            PricebookEntryId=pbeParkOutdoor.Id, 
            Quantity=1.0, 
            UnitPrice=8000.0
        );
        insert qliParkOutdoor;

        Test.startTest();
        Test.setCurrentPage(Page.PriceListPage);
        ApexPages.currentPage().getParameters().put('id', q.Id);
        
        PriceListController controller = new PriceListController();
        Test.stopTest();

        System.assertEquals(1, controller.totalApartamente, 'Ar trebui să fie 1 apartament.');
        System.assertEquals(3, controller.priceRows.size(), 'Ar trebui să existe 3 produse.');
        
        Boolean hasApartament = false;
        Boolean hasParkareInterioara = false;
        Boolean hasParkareExterioara = false;
        
        for (PriceListController.PriceRow row : controller.priceRows) {
            if (row.tip.contains('Apartament')) hasApartament = true;
            if (row.tip.contains('Parcare interioara')) hasParkareInterioara = true;
            if (row.tip.contains('Parcare exterioara')) hasParkareExterioara = true;
        }
        
        System.assert(hasApartament, 'Ar trebui Apartament.');
        System.assert(hasParkareInterioara, 'Ar trebui Parcare interioara.');
        System.assert(hasParkareExterioara, 'Ar trebui Parcare exterioara.');
    }

    @isTest
    static void testPriceListControllerEmptyQuote() {
        Account acc = new Account(Name='Test Account 3');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name='Test Opp 3', 
            AccountId=acc.Id, 
            StageName='Prospecting', 
            CloseDate=Date.today()
        );
        insert opp;
        
        Quote q = new Quote(
            Name='Test Quote Empty', 
            OpportunityId=opp.Id, 
            Pricebook2Id=Test.getStandardPricebookId()
        );
        insert q;

        Test.startTest();
        Test.setCurrentPage(Page.PriceListPage);
        ApexPages.currentPage().getParameters().put('id', q.Id);
        
        PriceListController controller = new PriceListController();
        Test.stopTest();

        System.assertEquals(0, controller.totalApartamente, 'Ar trebui 0 apartamente.');
        System.assertEquals(0, controller.priceRows.size(), 'Lista goală.');
        System.assertNotEquals(null, controller.quoteDetails, 'Quote trebuie să existe.');
    }
}