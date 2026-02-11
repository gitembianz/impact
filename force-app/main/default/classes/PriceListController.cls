public with sharing class PriceListController {
    
    public class PriceRow {
        public PricebookEntry entry { get; private set; }
        public String tip { get; private set; }
        public String pretPeMp { get; private set; }
        public String pretUnit { get; private set; }
        public Decimal pretUnitRaw { get; private set; }
        public Decimal totalLinePrice { get; private set; } 
        public Decimal quantity { get; private set; }
        
        public Decimal scdMp { get; private set; }
        public Decimal suAp { get; private set; }
        public Decimal scdBalcon { get; private set; }
        public Decimal scdTotal { get; private set; }

        public PriceRow(PricebookEntry pbe, QuoteLineItem qli) {
            this.entry = pbe;
            this.scdMp = getSafeDecimal(pbe.Product2.SCD_mp__c);
            this.suAp = getSafeDecimal(pbe.Product2.SU_ap__c);
            this.scdBalcon = getSafeDecimal(pbe.Product2.SCDgradinaterasa__c);
            this.scdTotal = getSafeDecimal(pbe.Product2.SCDApartamentcuterasa__c);
            
            if (qli != null) {
                this.quantity = qli.Quantity;
                this.pretUnitRaw = qli.UnitPrice; 
                this.totalLinePrice = qli.TotalPrice; 
            } else {
                this.quantity = 0;
                this.pretUnitRaw = 0;
                this.totalLinePrice = 0;
            }

            // Logica Tip
            String family = pbe.Product2.Family != null ? pbe.Product2.Family : '';
            if (family == 'Apartment') {
                this.tip = 'Apartament';
            } else if (family.contains('Parking')) {
                this.tip = 'Parcare'; 
                if (family == 'Parking Spot Indoors') this.tip = 'Parcare interioara';
                if (family == 'Parking Spot Outdoors') this.tip = 'Parcare exterioara';
            } else {
                this.tip = family;
            }
            
            if (pbe.Product2.Description != null && pbe.Product2.Description != '') {
                this.tip += ' - ' + pbe.Product2.Description;
            }
            
            // --- MODIFICARE 1: Folosim TotalPrice (totalLinePrice) pentru afisare ---
            // Clientul vrea valoarea totala a liniei, nu prețul per unitate
            this.pretUnit = '€ ' + this.totalLinePrice.setScale(0, RoundingMode.HALF_UP).format();
            
            // --- MODIFICARE 2: Logica pentru Parcari la coloana Preț/mp ---
            if (this.tip != null && this.tip.contains('Parcare')) {
                // Daca e parcare, nu afisam nimic sau o liniuta
                this.pretPeMp = '-'; 
            } 
            else if (this.scdTotal > 0) {
                // Calculam pretul pe mp bazat pe pretul unitar (corect matematic)
                Decimal pretMp = this.pretUnitRaw / this.scdTotal;
                this.pretPeMp = '€ ' + pretMp.setScale(0, RoundingMode.HALF_UP).format();
            } else {
                this.pretPeMp = 'N/A';
            }
        }

        private Decimal getSafeDecimal(Object val) {
            if (val == null) return 0.0;
            if (val instanceof Decimal) return (Decimal)val;
            if (val instanceof String) {
                String s = (String)val;
                if (String.isBlank(s)) return 0.0;
                try { return Decimal.valueOf(s.trim()); } catch (Exception e) { return 0.0; }
            }
            return 0.0;
        }
    }
    
    // Variabile Totaluri Tabel 1
    public String aptTotalCount { get; private set; }
    public String aptTotalScd { get; private set; }
    public String aptTotalSu { get; private set; }
    public String aptTotalBalcon { get; private set; }
    public String aptTotalScdTotal { get; private set; }
    public String aptTotalPret { get; private set; }
    public String aptTotalPretPeMp { get; private set; }

    public String parkTotalCount { get; private set; }
    public String parkTotalPret { get; private set; }
    
    // Variabile Tabel 2
    public String pretDeLista { get; private set; }
    public String pretLansare { get; private set; }
    public String avantajClient { get; private set; }
    public String totalSuprafataConstruita { get; private set; }
    public String mediaPretPeMapLista { get; private set; }
    public String mediaPretPeMapLansare { get; private set; }
    public Integer totalApartamente { get; private set; }
    
    public Boolean hasDiscount { get; private set; } 

    public Id quoteId { get; set; }
    public Quote quoteDetails { get; private set; }
    public List<PriceRow> priceRows { get; private set; }

    public PriceListController() {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        if (quoteId != null) {
            quoteDetails = [SELECT Id, Name, Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1];
            
            List<QuoteLineItem> quoteLineItems = [
                SELECT Product2.Name, Product2.Family, Quantity, UnitPrice, TotalPrice, 
                       PricebookEntry.Product2Id, Product2.SCDApartamentcuterasa__c,
                       Product2.SCD_mp__c, Product2.SU_ap__c, Product2.SCDgradinaterasa__c,
                       Product2.Floor__c, Product2.Orientation__c, Product2.Description,
                       PricebookEntryId
                FROM QuoteLineItem WHERE QuoteId = :quoteId
            ];

            Set<Id> productIdsInQuote = new Set<Id>();
            Map<Id, QuoteLineItem> productToQliMap = new Map<Id, QuoteLineItem>();

            for (QuoteLineItem qli : quoteLineItems) {
                productIdsInQuote.add(qli.PricebookEntry.Product2Id);
                productToQliMap.put(qli.PricebookEntry.Product2Id, qli);
            }

            Map<Id, Decimal> standardPriceMap = new Map<Id, Decimal>();
            if (!productIdsInQuote.isEmpty()) {
                for (PricebookEntry pbe : [
                    SELECT Product2Id, UnitPrice 
                    FROM PricebookEntry 
                    WHERE Product2Id IN :productIdsInQuote 
                    AND Pricebook2.IsStandard = true
                    AND IsActive = true
                ]) {
                    standardPriceMap.put(pbe.Product2Id, pbe.UnitPrice);
                }
            }

            Decimal sumaTotalQuote = 0;
            Decimal sumaTotalStandardPrice = 0;
            Decimal totalSuprafataApartamente = 0;
            Integer countApartamente = 0;
            Decimal sumaTotalQuoteApartamente = 0; 
            Decimal sumaTotalStandardPriceApartamente = 0; 

            for (QuoteLineItem qli : quoteLineItems) {
                sumaTotalQuote += qli.TotalPrice;
                
                Id productId = qli.PricebookEntry.Product2Id;
                Decimal standardPrice = standardPriceMap.get(productId);
                if (standardPrice != null) {
                    sumaTotalStandardPrice += standardPrice * qli.Quantity;
                }
                
                if (qli.Product2.Family == 'Apartment') {
                    countApartamente += qli.Quantity.intValue();
                    Decimal suprafataProdus = (qli.Product2.SCDApartamentcuterasa__c != null) ? 
                                              Decimal.valueOf(String.valueOf(qli.Product2.SCDApartamentcuterasa__c)) : 0;
                    totalSuprafataApartamente += suprafataProdus * qli.Quantity;
                    sumaTotalQuoteApartamente += qli.TotalPrice;
                    if (standardPrice != null) {
                        sumaTotalStandardPriceApartamente += standardPrice * qli.Quantity;
                    }
                }
            }
            
            this.totalApartamente = countApartamente;
            this.totalSuprafataConstruita = totalSuprafataApartamente.format() + ' mp';
            this.pretLansare = '€ ' + sumaTotalQuote.setScale(0, RoundingMode.HALF_UP).format();
            this.pretDeLista = '€ ' + sumaTotalStandardPrice.setScale(0, RoundingMode.HALF_UP).format();
            
            Decimal avantaj = sumaTotalStandardPrice - sumaTotalQuote;
            this.avantajClient = '€ ' + avantaj.setScale(0, RoundingMode.HALF_UP).format();
            
            this.hasDiscount = (avantaj > 0.00);

            Decimal mediaPretLista = (totalSuprafataApartamente > 0.0) ? 
                                     (sumaTotalStandardPriceApartamente / totalSuprafataApartamente) : 0.0;
            this.mediaPretPeMapLista = '€ ' + mediaPretLista.setScale(0, RoundingMode.HALF_UP).format();

            Decimal mediaPretLansare = (totalSuprafataApartamente > 0.0) ? 
                                       (sumaTotalQuoteApartamente / totalSuprafataApartamente) : 0.0;
            this.mediaPretPeMapLansare = '€ ' + mediaPretLansare.setScale(0, RoundingMode.HALF_UP).format();

            priceRows = new List<PriceRow>();

            if (!productIdsInQuote.isEmpty()) {
                List<PricebookEntry> entries = [
                    SELECT UnitPrice, Product2.Name, Product2.Description, Product2.Family,
                           Product2.SCD_mp__c, Product2.SU_ap__c, Product2.SCDgradinaterasa__c, 
                           Product2.Floor__c, Product2.Orientation__c, Product2.SCDApartamentcuterasa__c
                    FROM PricebookEntry 
                    WHERE Product2Id IN :productIdsInQuote 
                    AND Pricebook2Id = :quoteDetails.Pricebook2Id 
                    AND IsActive = true
                    ORDER BY Product2.Name
                ];
                
                for (PricebookEntry pbe : entries) {
                    QuoteLineItem relatedQli = productToQliMap.get(pbe.Product2Id);
                    priceRows.add(new PriceRow(pbe, relatedQli));
                }
                
                calculateSplitTotals();
            }
        }
    }
    
    private void calculateSplitTotals() {
        Decimal sumAptQty = 0;
        Decimal sumAptScd = 0; Decimal sumAptSu = 0; Decimal sumAptBalcon = 0; Decimal sumAptTotalScd = 0;
        Decimal sumAptPrice = 0;
        Decimal sumParkQty = 0;
        Decimal sumParkPrice = 0;

        for (PriceRow row : priceRows) {
            String family = row.entry.Product2.Family;
            if (family == 'Apartment') {
                sumAptQty += row.quantity;
                sumAptScd += (row.scdMp * row.quantity);
                sumAptSu += (row.suAp * row.quantity);
                sumAptBalcon += (row.scdBalcon * row.quantity);
                sumAptTotalScd += (row.scdTotal * row.quantity);
                sumAptPrice += row.totalLinePrice; 
            } else if (family != null && family.contains('Parking')) {
                sumParkQty += row.quantity;
                sumParkPrice += row.totalLinePrice;
            }
        }
        
        this.aptTotalCount = sumAptQty.format();
        this.aptTotalScd = sumAptScd.setScale(2, RoundingMode.HALF_UP).format();
        this.aptTotalSu = sumAptSu.setScale(2, RoundingMode.HALF_UP).format();
        this.aptTotalBalcon = sumAptBalcon.setScale(2, RoundingMode.HALF_UP).format();
        this.aptTotalScdTotal = sumAptTotalScd.setScale(2, RoundingMode.HALF_UP).format();
        this.aptTotalPret = '€ ' + sumAptPrice.setScale(0, RoundingMode.HALF_UP).format();
        
        if (sumAptTotalScd > 0) {
            Decimal avgMp = sumAptPrice / sumAptTotalScd;
            this.aptTotalPretPeMp = '€ ' + avgMp.setScale(0, RoundingMode.HALF_UP).format();
        } else {
            this.aptTotalPretPeMp = '';
        }

        this.parkTotalCount = sumParkQty.format();
        this.parkTotalPret = '€ ' + sumParkPrice.setScale(0, RoundingMode.HALF_UP).format();
    }
}