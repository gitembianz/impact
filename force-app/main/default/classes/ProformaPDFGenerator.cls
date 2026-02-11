public class ProformaPDFGenerator {
    
    @AuraEnabled
    public static String generatePDF(Id proformaId) {
        try {
            // Generează PDF și atașează
            ContentVersion cv = createPDFAttachment(proformaId);
            
            // Returnează ContentVersion Id (nu URL)
            return cv.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Eroare: ' + e.getMessage());
        }
    }
    
    private static ContentVersion createPDFAttachment(Id proformaId) {
        // Generează PDF folosind Visualforce
        PageReference pdfPage = Page.ProformaInvoicePDFTemplate;
        pdfPage.getParameters().put('id', proformaId);
        pdfPage.getParameters().put('save', '0'); // Evită loop infinit
        
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('Test PDF');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }
        
        // Obține numele facturii pentru titlu
        Proforma_Invoice__c invoice = [
            SELECT Name 
            FROM Proforma_Invoice__c 
            WHERE Id = :proformaId
        ];
        
        // Creează ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Proforma_' + invoice.Name;
        cv.PathOnClient = 'Proforma_' + invoice.Name + '.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        insert cv;
        
        // Obține ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        // Verifică dacă există deja link
        List<ContentDocumentLink> existing = [
            SELECT Id FROM ContentDocumentLink 
            WHERE LinkedEntityId = :proformaId 
            AND ContentDocumentId = :cv.ContentDocumentId
        ];
        
        // Atașează la record doar dacă nu există
        if (existing.isEmpty()) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = proformaId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
        
        return cv;
    }
}