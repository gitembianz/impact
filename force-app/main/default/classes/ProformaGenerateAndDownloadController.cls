public class ProformaGenerateAndDownloadController {
    
    public ProformaGenerateAndDownloadController() {
        // Constructor gol
    }
    
    public PageReference generatePDF() {
        try {
            // Obține ID-ul proformei
            String proformaId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.isBlank(proformaId)) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Proforma ID is missing'
                ));
                return null;
            }
            
            // Generează PDF și atașează la record
            String cvId = ProformaPDFGenerator.generatePDF(proformaId);
            
            // Redirect la PDF pentru download
            PageReference pdfPage = Page.ProformaInvoicePDFTemplate;
            pdfPage.getParameters().put('id', proformaId);
            pdfPage.setRedirect(true);
            return pdfPage;
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                'Error generating PDF: ' + e.getMessage()
            ));
            return null;
        }
    }
}