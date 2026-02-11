// ========================================
// QUOTE ANNEX CONTROLLER TEST - COMPLET
// ========================================
// Include toate testele originale + noi teste pentru getRoomTypeAndLobbyPdfsAsBase64

@isTest
private class QuoteAnnexControllerTest {

    /**
     * @description Creează datele necesare pentru toate metodele de test.
     */
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Test Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Test Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;

        // Produs cu annex
        Product2 prodWithAnnex = new Product2(Name='Test Prod Annex', ProductCode='AV3_AP11');
        insert prodWithAnnex;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(), 
            Product2Id=prodWithAnnex.Id, 
            UnitPrice=100000, 
            IsActive=true
        );
        insert pbe;
        
        // Adaugă produsul la ofertă
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId=q.Id, 
            PricebookEntryId=pbe.Id, 
            Quantity=1, 
            UnitPrice=100000
        );
        insert qli;
    }

    /**
     * @description Testează logica de identificare a anexelor necesare pe baza codurilor de produs.
     */
    @isTest
    static void testGetRequiredPdfResourceNames() {
        Quote q = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        
        Test.startTest();
        List<String> result = QuoteAnnexController.getRequiredPdfResourceNames(q.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Ar trebui să găsească o singură anexă pe baza codului de produs adăugat.');
        System.assertEquals('AV3_AP11', result[0], 'Numele resursei returnate este incorect.');
    }
    
    /**
     * @description Testează generarea paginilor Visualforce ca PDF.
     *              În context de test, acestea returnează un string de test.
     */
    @isTest
    static void testPdfGenerationMethods() {
        Quote q = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        
        Test.startTest();
        String summaryPdf = QuoteAnnexController.generateQuoteSummaryPdfAsBase64(q.Id);
        String priceListPdf = QuoteAnnexController.generatePriceListPdfAsBase64(q.Id);
        Test.stopTest();
        
        System.assert(summaryPdf != null, 'Metoda de generare a sumarului PDF nu ar trebui să returneze null.');
        System.assert(priceListPdf != null, 'Metoda de generare a listei de prețuri PDF nu ar trebui să returneze null.');
    }
    
    /**
     * @description Testează cazul în care se solicită o resursă statică inexistentă.
     */
    @isTest
    static void testErrorHandlingForStaticResource() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            QuoteAnnexController.getSinglePdfAsBase64('NUME_CARE_NU_EXISTA_NICIODATA');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Ar trebui să se arunce o excepție de tip AuraHandledException pentru resurse inexistente.');
    }

    /**
     * @description Testează obținerea URL-urilor pentru apartamente din ofertă.
     */
    @isTest
    static void testGetApartmentPdfUrls() {
        Quote q = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        
        Test.startTest();
        List<String> urls = QuoteAnnexController.getApartmentPdfUrls(q.Id);
        Test.stopTest();
        
        System.assertEquals(1, urls.size(), 'Ar trebui să găsească un URL de apartament.');
        System.assert(urls[0].contains('AV3_AP11'), 'URL-ul ar trebui să conțină codul produsului.');
        System.assert(urls[0].contains('https://forms.impactsa.ro/avproducts/'), 'URL-ul ar trebui să aibă baza corectă.');
    }

    /**
     * @description Testează descărcarea PDF-ului agentului.
     *              Mock-ează HTTP call-ul pentru a testa logica fără a face apeluri reale.
     */
    @isTest
    static void testGetAgentPdfAsBase64() {
        Quote q = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        
        // Mock HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        String agentPdf = QuoteAnnexController.getAgentPdfAsBase64(q.Id);
        Test.stopTest();
        
        System.assert(agentPdf != null, 'PDF-ul agentului nu ar trebui să fie null.');
        System.assert(agentPdf.length() > 0, 'PDF-ul agentului nu ar trebui să fie gol.');
    }

    /**
     * @description Testează obținerea URL-urilor pentru apartamente când quote-ul nu are produse.
     */
    @isTest
    static void testGetApartmentPdfUrlsEmpty() {
        Account acc = new Account(Name='Test Account 2');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Test Opp 2', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Test Quote Empty', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        
        Test.startTest();
        List<String> urls = QuoteAnnexController.getApartmentPdfUrls(q.Id);
        Test.stopTest();
        
        System.assertEquals(0, urls.size(), 'Ar trebui să fie 0 URL-uri pentru ofertă fără produse.');
    }

    /**
     * @description Testează descărcarea unui PDF de pe URL.
     *              Mock-ează HTTP call-ul.
     */
    @isTest
    static void testDownloadPdfFromUrlAsBase64() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        String pdf = QuoteAnnexController.downloadPdfFromUrlAsBase64('https://forms.impactsa.ro/avproducts/AV3_AP11.pdf');
        Test.stopTest();
        
        System.assert(pdf != null, 'PDF descărcat nu ar trebui să fie null.');
        System.assert(pdf.length() > 0, 'PDF descărcat nu ar trebui să fie gol.');
    }

    /**
     * @description Testează error handling când HTTP call eșuează.
     */
    @isTest
    static void testDownloadPdfFromUrlAsBase64Failure() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            QuoteAnnexController.downloadPdfFromUrlAsBase64('https://forms.impactsa.ro/avproducts/INEXISTENT.pdf');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Ar trebui să se arunce excepție pentru HTTP 404.');
    }

    /**
     * @description Testează getQuoteName
     */
    @isTest
    static void testGetQuoteName() {
        Quote q = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        
        Test.startTest();
        String quoteName = QuoteAnnexController.getQuoteName(q.Id);
        Test.stopTest();
        
        System.assertEquals('Test Quote', quoteName, 'Ar trebui să returneze numele ofertei corect.');
    }

    // ===== TESTE PENTRU NOUA METODA =====

    /**
     * @description Test getRoomTypeAndLobbyPdfsAsBase64 - happy path cu 2 și 3 camere
     */
    @isTest
    static void testGetRoomTypeAndLobbyPdfsAsBase64WithRooms() {
        Account acc = new Account(Name='Room Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Room Test Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Room Test Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        
        // Creează produse cu NumberofRooms__c
        Product2 prod2cam = new Product2(Name='2 Camere', ProductCode='AP2CAM', NumberofRooms__c=2);
        Product2 prod3cam = new Product2(Name='3 Camere', ProductCode='AP3CAM', NumberofRooms__c=3);
        insert new List<Product2>{prod2cam, prod3cam};
        
        // Pricebook entries
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2cam.Id, UnitPrice=100, IsActive=true),
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod3cam.Id, UnitPrice=100, IsActive=true)
        };
        insert pbes;
        
        // Adaugă QLI
        insert new List<QuoteLineItem>{
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[0].Id, Quantity=1, UnitPrice=100),
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[1].Id, Quantity=1, UnitPrice=100)
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        List<String> result = QuoteAnnexController.getRoomTypeAndLobbyPdfsAsBase64(q.Id);
        Test.stopTest();
        
        // Ar trebui lobby + 2cam + 3cam = minim 3 elemente
        System.assert(result.size() >= 3, 'Ar trebui să returneze minim 3 PDF-uri (lobby + 2cam + 3cam)');
    }

    /**
     * @description Test getRoomTypeAndLobbyPdfsAsBase64 - ofertă fără produse cu NumberofRooms__c
     */
    @isTest
    static void testGetRoomTypeAndLobbyPdfsAsBase64NoRooms() {
        Account acc = new Account(Name='No Rooms Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='No Rooms Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='No Rooms Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        
        Test.startTest();
        List<String> result = QuoteAnnexController.getRoomTypeAndLobbyPdfsAsBase64(q.Id);
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Fără produse cu NumberofRooms__c, ar trebui să returneze listă goală.');
    }

    /**
     * @description Test getRoomTypeAndLobbyPdfsAsBase64 - single room type (doar 4 camere)
     */
    @isTest
    static void testGetRoomTypeAndLobbyPdfsAsBase64SingleRoom() {
        Account acc = new Account(Name='Single Room Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Single Room Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Single Room Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        
        // Doar 4 camere
        Product2 prod4cam = new Product2(Name='4 Camere', ProductCode='AP4CAM', NumberofRooms__c=4);
        insert prod4cam;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(), 
            Product2Id=prod4cam.Id, 
            UnitPrice=100, 
            IsActive=true
        );
        insert pbe;
        
        insert new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbe.Id, Quantity=1, UnitPrice=100);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        List<String> result = QuoteAnnexController.getRoomTypeAndLobbyPdfsAsBase64(q.Id);
        Test.stopTest();
        
        // lobby + 4cam = minim 2
        System.assert(result.size() >= 2, 'Ar trebui lobby + 4cam');
    }

    /**
     * @description Test getRoomTypeAndLobbyPdfsAsBase64 - duplicate room types (2 apartamente cu 3 camere)
     */
    @isTest
    static void testGetRoomTypeAndLobbyPdfsAsBase64DuplicateRooms() {
        Account acc = new Account(Name='Duplicate Room Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Duplicate Room Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Duplicate Room Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        
        // Creează 2 produse cu 3 camere
        Product2 prod3camA = new Product2(Name='3 Camere A', ProductCode='AP3A', NumberofRooms__c=3);
        Product2 prod3camB = new Product2(Name='3 Camere B', ProductCode='AP3B', NumberofRooms__c=3);
        insert new List<Product2>{prod3camA, prod3camB};
        
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod3camA.Id, UnitPrice=100, IsActive=true),
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod3camB.Id, UnitPrice=100, IsActive=true)
        };
        insert pbes;
        
        insert new List<QuoteLineItem>{
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[0].Id, Quantity=1, UnitPrice=100),
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[1].Id, Quantity=1, UnitPrice=100)
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        List<String> result = QuoteAnnexController.getRoomTypeAndLobbyPdfsAsBase64(q.Id);
        Test.stopTest();
        
        // lobby + 3cam (o singură dată!) = 2 elemente
        System.assert(result.size() == 2, 'Ar trebui lobby + 3cam o singură dată (deși sunt 2 apartamente cu 3 camere)');
    }

    /**
     * @description Test getRoomTypeAndLobbyPdfsAsBase64 - mixed room types (2, 3, 5 camere)
     */
    @isTest
    static void testGetRoomTypeAndLobbyPdfsAsBase64MixedRooms() {
        Account acc = new Account(Name='Mixed Rooms Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Mixed Rooms Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Mixed Rooms Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        
        // 2, 3, 5 camere
        Product2 prod2cam = new Product2(Name='2 Camere', ProductCode='AP2', NumberofRooms__c=2);
        Product2 prod3cam = new Product2(Name='3 Camere', ProductCode='AP3', NumberofRooms__c=3);
        Product2 prod5cam = new Product2(Name='5 Camere', ProductCode='AP5', NumberofRooms__c=5);
        insert new List<Product2>{prod2cam, prod3cam, prod5cam};
        
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2cam.Id, UnitPrice=100, IsActive=true),
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod3cam.Id, UnitPrice=100, IsActive=true),
            new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod5cam.Id, UnitPrice=100, IsActive=true)
        };
        insert pbes;
        
        insert new List<QuoteLineItem>{
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[0].Id, Quantity=1, UnitPrice=100),
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[1].Id, Quantity=1, UnitPrice=100),
            new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbes[2].Id, Quantity=1, UnitPrice=100)
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        List<String> result = QuoteAnnexController.getRoomTypeAndLobbyPdfsAsBase64(q.Id);
        Test.stopTest();
        
        // lobby + 2cam + 3cam + 5cam = 4 elemente
        System.assert(result.size() == 4, 'Ar trebui lobby + 2cam + 3cam + 5cam');
    }

    // ===== MOCK CLASSES =====

    /**
     * @description Mock HTTP Response pentru apeluri reușite.
     */
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/pdf');
            response.setBody(EncodingUtil.base64Encode(Blob.valueOf('Mock PDF Content')));
            response.setStatusCode(200);
            return response;
        }
    }

    /**
     * @description Mock HTTP Response pentru apeluri eșuate (404).
     */
    public class MockHttpResponseFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/plain');
            response.setBody('Not Found');
            response.setStatusCode(404);
            return response;
        }
    }
}