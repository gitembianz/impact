@isTest
public class CountryIsoUpdateHandlerTest {
    @TestSetup
    static void setup(){
  
    }
    static testMethod void test(){

        Test.startTest();
    
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        testAccount.BillingCountry='Romania';
        testAccount.BillingState='Dolj';
        insert testAccount;
        Test.stopTest();
    
      }
}