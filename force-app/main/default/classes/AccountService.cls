//Get all accounts and pass to lwc
public with sharing class AccountService {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        List<Account> accList = [SELECT Id,Name,Phone,Type_Of_Day__c  FROM Account WHERE Active__c = 'Yes'];
        return accList;
    }
    
    @AuraEnabled
    public static String updateAmount(String accId,Integer amountPaid){
        Integer upAmount = 0;
        
        String retMsg= '';
        Account acc = [SELECT Id,Amount_Till_Date__c,Amount_Pending__c FROM Account Where Id =: accId LIMIT 1];
        if(amountPaid != Null){
            upAmount = amountPaid;
        	acc.Amount_Pending__c = acc.Amount_Pending__c - upAmount;
            acc.Amount_Paid__c += upAmount;
            handleAmountPaid(accId,amountPaid);
            System.debug('accPending'+acc.Amount_Pending__c);
            try{
                update acc;
                retMsg =  'Success';
              }
            catch(DMLException e){
                System.debug(e);
                retMsg =  'Failed' + e.getMessage();
            }
            
        }
        return retMsg;
    }
    
    public static void handleAmountPaid(String accId,Integer amountPaid){
        //get the amountPAid from UI and fetch all the labour time data which sum is less than amount paid and mark them as paid
        List<Labour_Time__c> ltList = new List<Labour_Time__c>();
		 List<AggregateResult> aggList = [SELECT Id,Sum(Amount_Payable__c) , 
                                             Name__c FROM Labour_Time__c 
                                             WHERE Name__c =: accId 
                                             Group By Name__c,Id HAVING Sum(Amount_Payable__c) <=: amountPaid]; 
            System.debug('aggList'+aggList);
            for(AggregateResult agg:aggList){
                Labour_Time__c lt = new Labour_Time__c();
                lt.Id = (Id)agg.get('Id');
                lt.Is_Amount_Paid__c = true;
                ltList.add(lt);
            }
        
        if(!ltList.isEmpty()){
            update ltList;
        }
        /*
        Integer FulldayAmount = 200;
        Integer HalfdayAmount = 100;
        Integer onlyMAmount = 80;
        Integer onlyEAmount = 50;
        Integer rem = 0;  
        Integer div = 0;
        Map<String,Integer> TypeofDayVsrem = new Map<String,Integer>();
        if( paidAmount >= FulldayAmount){
           	div = (Integer) paidAmount/FulldayAmount;
            TypeofDayVsrem.put('fday',div);
            rem = Math.mod(paidAmount, FulldayAmount);
            if(rem >= HalfdayAmount && rem < onlyMAmount){
                  div = (Integer) rem/HalfdayAmount;
                  TypeofDayVsrem.put('hday',div);
             	  rem = Math.mod(paidAmount, HalfdayAmount);
				}
        }else if(paidAmount < FulldayAmount && paidAmount>=HalfdayAmount){
           	div = (Integer) paidAmount/HalfdayAmount;
            TypeofDayVsrem.put('hday',div);
		 }
    }*/
    }
}