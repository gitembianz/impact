@isTest(SeeAllData=true)
private class ProformaGenDownloadControllerTest {
    
    @isTest
    static void testGeneratePDF() {
        List<Proforma_Invoice__c> proformas = [SELECT Id FROM Proforma_Invoice__c LIMIT 1];
        
        if (!proformas.isEmpty()) {
            PageReference pageRef = Page.ProformaGenerateAndDownload;
            pageRef.getParameters().put('id', proformas[0].Id);
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
            ProformaGenerateAndDownloadController controller = new ProformaGenerateAndDownloadController();
            PageReference result = controller.generatePDF();
            Test.stopTest();
            
            System.assertNotEquals(null, result);
        }
    }
    
    @isTest
    static void testNoId() {
        PageReference pageRef = Page.ProformaGenerateAndDownload;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ProformaGenerateAndDownloadController controller = new ProformaGenerateAndDownloadController();
        PageReference result = controller.generatePDF();
        Test.stopTest();
        
        System.assertEquals(null, result);
    }
}