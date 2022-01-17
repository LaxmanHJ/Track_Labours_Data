trigger LabourAmountPayable on Labour_Time__c (before insert) {
    Decimal totalAmount = 0;
    Decimal Amount_Till_Date=0;
    Decimal AmountToUpdate =0;
    List<Account> insertAmountPerAccounts = new List<Account>();
    Map<String,Decimal> accIdVsamount = new Map<String, Decimal>();
    for(Labour_Time__c lt: Trigger.New){
        System.debug('tyod'+lt.Type_of_Day__c);
        if(lt.Type_of_Day__c == 'Full Day'){
            totalAmount  = totalAmount + 200;
            //accIdVsamount.put(lt.Name__c,);
        }
        else if(lt.Type_of_Day__c == 'Half Day'){
            totalAmount  = totalAmount + 100;
        }
        else if(lt.Type_of_Day__c == 'Only Morning'){
            totalAmount  = totalAmount + 80;
        }
        else{
            totalAmount  = totalAmount + 50;
        }
        accIdVsamount.put(lt.Name__c,totalAmount);
        System.debug('accIdVsamountLax'+accIdVsamount);
            
    }
    
    List<Account> accList = [SELECT Id,Amount_Till_Date__c,Name FROM Account WHERE Id IN :accIdVsamount.keySet()];
    System.debug('accListLax'+accList);
    for(Account acc:accList){
         Amount_Till_Date =  accIdVsamount.get(acc.Id);
         System.debug('Amount_Till_DateLax'+Amount_Till_Date);
         AmountToUpdate  = acc.Amount_Till_Date__c + Amount_Till_Date;
         System.debug('AmountToUpdate'+AmountToUpdate);
         Account accs = new Account(Id = acc.Id, Amount_Till_Date__c = AmountToUpdate); 
         insertAmountPerAccounts.add(accs);
    }
    if(insertAmountPerAccounts.size() > 0){
        update insertAmountPerAccounts;
    }
}