public with sharing class pwHelper {
  public static List<String> getObjectFieldNames(String objectName, Boolean onlyAccessible) {
    if (String.isBlank(objectName)) {
      return null;
    }

    if (onlyAccessible == null) {
      onlyAccessible = false;
    }

    if (Schema.getGlobalDescribe().get(objectName) == null) {
      //object does not exists
      return null;
    }

    Map <String, Schema.SObjectField> leadFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
    List<String> fieldsList = new List<String>();

    for(String key: leadFields.keySet()) {
      Schema.DescribeFieldResult describe = leadFields.get(key).getDescribe();
      if (onlyAccessible) {
        if (describe.isAccessible()) {
          fieldsList.add(describe.getName());
        }
      } else {
        fieldsList.add(describe.getName());
      }
    }

    return fieldsList;
  }

  public static Schema.FieldSetMember[] getFieldSet(String obj, String fieldSetName) {
    Schema.FieldSetMember[] result;
    
    if (fieldSetName == null || obj == null) {
      return result;
    }
    
    Schema.FieldSet fieldset = null;
    Schema.SObjectType targetObj = Schema.getGlobalDescribe().get(obj);

    
    if (targetObj != null) {
      Schema.DescribeSObjectResult objectDescribe = targetObj.getDescribe();
      
      if (objectDescribe != null) {
        fieldset = objectDescribe.FieldSets.getMap().get(fieldSetName);
      }
    }
    
    if (fieldset != null) {
      result = fieldset.getFields();
    }
    
    return result;
  }
  
  public static List<String> getFieldSetFields(String objectName, String fieldSetName){
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
    
    List<String> fields = new List<String>();
    // fields.add('Id');
    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
      fields.add(fieldSetMemberObj.getFieldPath());
    }

    return fields; 
  }
  

  public static Map<String, String> getFieldSetLabels(String objectName, String fieldSetName){
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
    
    Map<String, String> labels = new Map<String, String>();
    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
      labels.put(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel());
    }

    return labels; 
  }
}