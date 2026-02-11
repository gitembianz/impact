@isTest
public class pwHelperTest {
  @TestSetup
  static void setup(){
  
  }

  static testMethod void testGetObjectFieldNames(){
    Test.startTest();

    List<String> objectNames =  pwHelper.getObjectFieldNames('Account', true);

    Test.stopTest();

    System.assert(objectNames.size() > 0);
  }

  static testMethod void testGetFieldSet(){
    Test.startTest();

    Schema.FieldSetMember[] fset = pwHelper.getFieldSet('Account', 'MyFieldSet');

    Test.stopTest();

    System.assert(fset.size() > 0);
  }
  
  static testmethod void getFieldSetFieldsTest() {
    Test.startTest();
        
	List<String> str = pwHelper.getFieldSetFields('Account', 'MyFieldSet');
        
    Test.stopTest();
        
	system.assertNotEquals(null, str);
  }
    
  static testmethod void getFieldSetLabelsTest() {
	Test.startTest();
        
	Map<String, String> str = pwHelper.getFieldSetLabels('Account', 'MyFieldSet');
        
	Test.stopTest();
        
	system.assertNotEquals(null, str);
  }
}