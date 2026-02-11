public with sharing class ProformaPDFController {
    
    public Id proformaId { get; set; }
    public Proforma_Invoice__c proforma { get; set; }
    public Boolean isLegalEntity { get; set; }
    public List<Proforma_Line_Item__c> lineItems { get; set; }
    
    public ProformaPDFController() {
        proformaId = ApexPages.currentPage().getParameters().get('id');
        loadData();
        
        // ȘTERGE ASTA - NU FUNCȚIONEAZĂ CU renderAs="pdf"
        // String saveParam = ApexPages.currentPage().getParameters().get('save');
        // if (saveParam == '1') {
        //     ProformaPDFGenerator.generatePDF(proformaId);
        // }
    }
    
    private void loadData() {
        // Query proforma
        proforma = [
            SELECT 
                Id, Name,
                Proforma_Invoice_Date__c,
                Due_Date__c,
                IBAN__c,
                Bank__c,
                Total_Amount_RON__c,
                Total_VAT_Amount_RON__c,
                Total_Amount_with_VAT_RON__c,
                Account__r.Name,
                Account__r.IsPersonAccount,
                Account__r.BillingStreet,
                Account__r.BillingCity,
                Account__r.BillingState,
                Account__r.BillingCountry,
                Account__r.TradeRegistrationNumber__c,
                Account__r.FiscalCode__c,
                Phase__r.Provider_Name__r.Name,
                Phase__r.Provider_Name__r.Registration_Number__c,
                Phase__r.Provider_Name__r.Fiscal_Code__c,
                Phase__r.Provider_Name__r.Headquarters__Street__s,
                Phase__r.Provider_Name__r.Headquarters__StateCode__s,
                Phase__r.Provider_Name__r.Headquarters__City__s,
                Phase__r.Provider_Name__r.Headquarters__CountryCode__s,
                Phase__r.Provider_Name__r.Capital_Social__c
            FROM Proforma_Invoice__c
            WHERE Id = :proformaId
        ];
        
        // Determină dacă este persoană juridică
        isLegalEntity = !proforma.Account__r.IsPersonAccount;
        
        // Query line items
        lineItems = [
            SELECT Item_Text__c, Amount_RON__c, VAT_Amount_RON__c
            FROM Proforma_Line_Item__c
            WHERE Proforma_Invoice__c = :proformaId
            ORDER BY CreatedDate ASC
        ];
    }
}