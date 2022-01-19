//Get all accounts and pass to lwc
public with sharing class AccountService {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        List<Account> accList = [SELECT Id,Name,Phone,Type_Of_Day__c  FROM Account WHERE Active__c = 'Yes'];
        return accList;
    }
    
    @AuraEnabled
    public static String updateAmount(String accId,Decimal amountPaid){
        Decimal upAmount = 0;
        String retMsg= '';
        Account acc = [SELECT Id,Amount_Till_Date__c,Amount_Pending__c FROM Account Where Id =: accId LIMIT 1];
        if(amountPaid != Null){
            upAmount = amountPaid.intValue();
        	acc.Amount_Pending__c = acc.Amount_Pending__c - upAmount;
            System.debug('accPending'+acc.Amount_Pending__c);
            try{
                update acc;
                retMsg =  'Amount updated Successfully';
              }
            catch(DMLException e){
                System.debug(e);
                retMsg =  'Amount Failed to update' + e.getMessage();
            }
        }
        return retMsg;
    }
}