public with sharing class ProductWizardController {
  @AuraEnabled
  public static Quote getQuoteDetails(Id quoteId){
    String objectName = 'Quote';
    System.debug('Target object: ' + objectName);

    List<String> fieldList = pwHelper.getObjectFieldNames(objectName, true);
    System.debug('Field list: ' + fieldList);

    String query = 'SELECT ';

    query += String.join(fieldList, ', ') + ' FROM ' + objectName + ' ';
    query += 'WHERE Id = \'' + quoteId + '\'';
    System.debug(query);

    return Database.query(query);
  }

  @AuraEnabled
  public static List<Pricebook2> getPricebooks(Date quoteDate){
    return [ SELECT Id, 
                Name
              FROM Pricebook2
              WHERE StartDate__c <= :quoteDate 
              AND EndDate__c >= :quoteDate 
              AND IsActive = true ];
  }

  @AuraEnabled
  public static List<QuoteLineItem> getQuoteLineItems(Id quoteId){
    String objectName = 'QuoteLineItem';
    System.debug('Target object: ' + objectName);

    List<String> fieldList = pwHelper.getObjectFieldNames(objectName, true);
    System.debug('Field list: ' + fieldList);

    String query = 'SELECT ';

    query += String.join(fieldList, ', ') + ' FROM ' + objectName + ' ';
    query += 'WHERE QuoteId = :quoteId';
    System.debug(query);

    List<QuoteLineItem> result = Database.query(query);
    System.debug(result);
    return result;
  }

  @AuraEnabled
  public static List<Product2> searchPricebookEntries(Id priceBook2Id, String searchTerm){
    System.debug('Pricebook2 Id: ' + priceBook2Id + ', search terms: ' + searchTerm);
    String objectName = 'Product2';
    String fieldSetName = 'LineEditor';
    List<String> fieldList = pwHelper.getObjectFieldNames(objectName, true);

    String query = 'FIND \'' + searchTerm + '\' IN ALL FIELDS RETURNING Product2( ';
    query += String.join(fieldList, ', ') + ' WHERE Id IN ';
    query += '(SELECT Product2Id FROM PricebookEntry WHERE ';
    query += 'Pricebook2Id = \'' + priceBook2Id + '\') ';
    query += 'AND Component__c = false AND IsActive = true)';

    System.debug(query);

    List<List<SObject>> searchResults = Search.query(query);

    return searchResults[0];
  }

  @AuraEnabled
  public static List<Product2> getProductsByQuoteLine(Id quoteId){
    if(String.isBlank(quoteId)){
      return new List<Product2>();
    }

    String objectName = 'Product2';
    List<String> fieldList = pwHelper.getObjectFieldNames(objectName, true);

    String query = 'SELECT ';
    query += String.join(fieldList, ', ') + ' FROM ' + objectName + ' WHERE Component__c = false AND Id IN ';
    query += '(SELECT Product2Id FROM QuoteLineItem WHERE QuoteId = :quoteId AND ConfiguredProduct__c = NULL)';

    System.debug(query);

    return Database.query(query);
  }

  @AuraEnabled
  public static String getFieldsetPure(String obj, String fieldset) {
    return JSON.serialize(pwHelper.getFieldSet(obj, fieldset));
  }

  @AuraEnabled
  public static Map<String, List<SObject>> getRecordsForConfiguration(Id quoteId, Id priceList, List<String> productIds) {
    Map<String, List<SObject>> result = new Map<String, List<SObject>>();

    Set<String> fieldsForSelection = new Set<String>();
    Set<String> productFields = new Set<String>();

    List<Schema.FieldSetMember> fieldset = pwHelper.getFieldSet('QuoteLineItem', 'OptionConfiguration');
    
    for (Schema.FieldSetMember fm: fieldset) {
      String apiName = fm.getFieldPath();
      fieldsForSelection.add(apiName);

      if (apiName.startsWith('Product2.')) {
        productFields.add(apiName.split('\\.')[1]);
      }
    }

    //if (!fieldsForSelection.contains('Id')) {
      fieldsForSelection.add('Id');
      fieldsForSelection.add('ListPrice');
    //}

    //if (!fieldsForSelection.contains('Product2Id')) {
      fieldsForSelection.add('Product2Id');
      fieldsForSelection.add('PricebookEntryId');
      
     // fieldsForSelection.add('Product2.Product_Options__r');
      
    //}

    //if (!fieldsForSelection.contains('Product2.Name')) {
      fieldsForSelection.add('Product2.Name');
      fieldsForSelection.add('Product2.ProductType__c');
    //}

    productFields.add('Id');
    productFields.add('Name');
    productFields.add('ProductType__c');

    System.debug('Query fields for Quote Line Items: ' + fieldsForSelection);
    System.debug('Query fields for product object: ' + productFields);

    if (productIds == null) {
      return result;
    }

    if (productIds.size() == 0) {
      return result;
    }

    System.debug('productIds:' + productIds);
    System.debug('quoteId: ' + quoteId);

    Set<Id> allProductIds = new Set<Id>();

    List<String> productOptionFields = new List<String>();
    for(String field: productFields) {
      productOptionFields.add('Option__r.' + field);
    }

    String query = 'SELECT ' + String.join( new List<String>(productFields), ', ') + ', (SELECT Name, Option__c, Mandatory__c, '+ String.join(productOptionFields, ', ') +' FROM Product_Options__r) FROM Product2 WHERE Id IN :productIds';
    List<Product2> allProducts = System.Database.query(query);
    List<SObject> sAllproducts = new List<SObject>();

    for(Product2 product: allProducts) {
      allProductIds.add(product.Id);
      sAllproducts.add(product);

      for(ProductOption__c option: product.getSObjects('Product_Options__r')) {
        allProductIds.add(option.Option__c);
      }
    }

    result.put('products', sAllproducts);

    if (allProductIds.size() > 0) {
      query = 'SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id = :priceList AND Product2Id IN :allProductIds';
      List<PricebookEntry> prices = System.Database.query(query);

      result.put('prices', prices);
    } else {
      result.put('prices', new List<SObject>());
    }

    query = 'SELECT ' + String.join( new List<String>(fieldsForSelection), ', ') + ' FROM QuoteLineItem WHERE Product2Id IN :productIds AND QuoteId = :quoteId';
    List<QuoteLineItem> existingItems = System.Database.query(query);

    List<SObject> products = result.get('products');
    for(QuoteLineItem item: existingItems) {
      products.add(item);
    }

    result.put('products', products);

    /*

    String query = 'SELECT ' + String.join( new List<String>(fieldsForSelection), ', ') + ' FROM QuoteLineItem WHERE Product2Id IN :productIds AND QuoteId = :quoteId';

    List<QuoteLineItem> existingItems = System.Database.query(query);

    Set<Id> foundProducts = new Set<Id>();
    Set<Id> leftProductIds = new Set<Id>();

    List<SObject> mainResult = new List<SObject>();

    for(QuoteLineItem item: existingItems) {
      foundProducts.add(item.Product2Id);
      mainResult.add(item);
    }

    result.put('products', mainResult);

    for(Id productId :productIds) {
      if (!foundProducts.contains(productId)) {
        leftProductIds.add(productId);
      }
    }

    if (productIds.size() > 0) {
      List<String> productOptionFields = new List<String>();
      for(String field: productFields) {
        productOptionFields.add('Option__r.' + field);
      }

      Set<String> productForPricesQuery = new Set<String>(productIds);

      query = 'SELECT Id, ConfiguredProduct__c, Name, Option__c, Mandatory__c, '+ String.join(productOptionFields, ', ') +' FROM ProductOption__c WHERE ConfiguredProduct__c IN :productIds';
      List<ProductOption__c> options = System.Database.query(query);

      for (ProductOption__c po: options) {
        productForPricesQuery.add(po.Option__c);
      }

      result.put('options', options);

      query = 'SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id = :priceList AND Product2Id IN :productForPricesQuery';
      List<PricebookEntry> prices = System.Database.query(query);

      result.put('prices', prices);
    }

    if (leftProductIds.size() > 0) {
      query = 'SELECT ' + String.join( new List<String>(productFields), ', ') + ', (SELECT Name, Option__c, Mandatory__c FROM Product_Options__r) FROM Product2 WHERE Id IN :leftProductIds';
      
      List<Product2> bareProducts = System.Database.query(query);
      List<SObject> mainResult2 = result.get('products');

      for(Product2 product: bareProducts) {
        QuoteLineItem itm = new QuoteLineItem();

        itm.Product2 = product;

        //result.add(itm);
        mainResult2.add(itm);
      }

      result.put('products', mainResult2);
    }
*/

    System.debug(result);

    return result;
  }

  @AuraEnabled
  public static String getFieldSet(String objectName, String fieldSetName){
    if (String.isBlank(objectName)) {
      return null;
    }

    if (Schema.getGlobalDescribe().get(objectName) == null) {
      //object does not exists
      return null;
    }

    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
    List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields();

    List<String> columns = new List<String>();
    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
      String tmp = '{ ';
      tmp += '"label": "' + fieldSetMemberObj.getLabel() + '", ';
      tmp += '"fieldName": "' + fieldSetMemberObj.getFieldPath() + '", ';
      tmp += '"type": "' + fieldSetMemberObj.getType() + '" ';
      tmp += '}';

      columns.add(tmp);
    }

    return '[' + String.join(columns, ',') + ']'; 
  }

  @AuraEnabled
  public static Map<String, List<Object>> saveQuoteLines(Id quoteId, Id priceBookId, List<QuoteLineItem> records, Boolean skipDeletion) {
    List<QuoteLineItem> quoteLinesToDelete = [ SELECT Id from QuoteLineItem where QuoteId = :quoteId ];
    Map<String, List<Object>> results = new Map<String, List<Object>>();

    if (skipDeletion == null) {
      skipDeletion = false;
    }

    Savepoint sp = Database.setSavepoint();

    if (skipDeletion == false) {
      try {
        
        List<AggregateResult> ar = [SELECT COUNT(Id) c FROM QuoteLineItem WHERE QuoteId = :quoteId];
        
        if ((Integer)ar[0].get('c') == 0) {
          Quote q = [SELECT Id, Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1];
          System.debug('Old pricebook: ' + q.Pricebook2Id + ' , set new pricebook: ' + priceBookId);
          q.Pricebook2Id = priceBookId;
          update q;
        }
      } catch (Exception e) {
        Database.rollback(sp);
        throw new AuraHandledException(e.getMessage());
      }
    }

    Boolean hasErorrs = false;
    List<Object> errors = new List<Object>();
    List<String> ids = new List<String>();

    if (skipDeletion == false) {
      Database.DeleteResult[] deleteResults = System.Database.delete(quoteLinesToDelete);
      for( Database.DeleteResult dr : deleteResults ) {
        if ( !dr.isSuccess() ){
          for ( Database.Error err : dr.getErrors() ) {
            System.debug( 'Deletion of exisging quote line item for quote ' + quoteId + ' failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
            System.debug( 'Fiedls affected: ' + err.getFields() ); 
            
            errors.add('Deletion of exisging quote line item for quote ' + quoteId + ' failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() + '. Fiedls affected: ' + err.getFields());
            hasErorrs = true;
          }
        } else {
          System.debug( 'Successfully deleted quote line item with ID: ' + dr.getId() );
        }
      }
    }

    Database.SaveResult[] insertResults = System.Database.insert(records, false);

    for( Database.SaveResult sr : insertResults ) {
      if ( !sr.isSuccess() ){
        for ( Database.Error err : sr.getErrors() ) {
          System.debug( 'Insertion of quote line item for quote ' + quoteId + ' failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() );
          System.debug( 'Fiedls affected: ' + err.getFields() ); 

          errors.add('Insertion of quote line item for quote ' + quoteId + ' failed with error: ' + err.getStatusCode() + ' and message: ' + err.getMessage() + '. Fiedls affected: ' + err.getFields());
          hasErorrs = true;
        }
      } else {
        System.debug( 'Successfully inserted quote line item with ID: ' + sr.getId() );
      }
    }

    if (hasErorrs) {
      Database.rollback(sp);
    }

    results.put('errors', errors);
    results.put('records', (List<Object>)records);

    return results;
  }
}