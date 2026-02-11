trigger QuoteLineItemStandardPrice on QuoteLineItem (before insert, before update) {
    Set<Id> prodIds = new Set<Id>();
    for (QuoteLineItem li : Trigger.new) {
        if (li.Product2Id != null) prodIds.add(li.Product2Id);
    }
    if (prodIds.isEmpty()) return;
    
    // Get Standard Price Book by NAME
    List<Pricebook2> stdBooks = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
    if (stdBooks.isEmpty()) return;
    
    Id stdBookId = stdBooks[0].Id;
    System.debug('Standard Book ID: ' + stdBookId);
    
    // Query and build map
    List<PricebookEntry> stdEntries = [
        SELECT Product2Id, UnitPrice 
        FROM PricebookEntry 
        WHERE Product2Id IN :prodIds 
        AND Pricebook2Id = :stdBookId
    ];
    
    Map<Id, Decimal> stdPrices = new Map<Id, Decimal>();
    for (PricebookEntry pbe : stdEntries) {
        stdPrices.put(pbe.Product2Id, pbe.UnitPrice);
    }
    System.debug('Prices found: ' + stdPrices.size());
    
    // Update field
    for (QuoteLineItem li : Trigger.new) {
        if (stdPrices.containsKey(li.Product2Id)) {
            li.Standard_Price_Book_Price__c = stdPrices.get(li.Product2Id);
        }
    }
}
