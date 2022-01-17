trigger LabourAmountPayable on Labour_Time__c (before insert) {
    Decimal totalAmount = 0;
    Decimal AmountOfToday=0;
    Decimal AmountToUpdate =0;
    Decimal AmountPending = 0;
    Decimal TotalDays = 0;
    List<Account> insertAmountPerAccounts = new List<Account>();
    Map<String,Decimal> accIdVsamount = new Map<String, Decimal>();
    for(Labour_Time__c lt: Trigger.New){
        System.debug('tyod'+lt.Type_of_Day__c);
        if(lt.Type_of_Day__c == 'Full Day'){
            totalAmount  = 200;
            //accIdVsamount.put(lt.Name__c,);
        }
        else if(lt.Type_of_Day__c == 'Half Day'){
            totalAmount  = 100;
        }
        else if(lt.Type_of_Day__c == 'Only Morning'){
            totalAmount  = 80;
        }
        else{
            totalAmount  = 50;
        }
        accIdVsamount.put(lt.Name__c,totalAmount);
        System.debug('accIdVsamountLax'+accIdVsamount);
            
    }
    
    List<Account> accList = [SELECT Id,Amount_Till_Date__c,Amount_Pending__c, Total_Work_Days__c ,Name FROM Account WHERE Id IN :accIdVsamount.keySet()];
    System.debug('accListLax'+accList);
    for(Account acc:accList){
         AmountOfToday =  accIdVsamount.get(acc.Id);
         System.debug('Amount_Till_DateLax'+AmountOfToday);
         AmountToUpdate  = acc.Amount_Till_Date__c + AmountOfToday;
         AmountPending = acc.Amount_Pending__c + AmountOfToday;
         TotalDays = acc.Total_Work_Days__c + 1;
         System.debug('AmountToUpdate'+AmountToUpdate);
         Account accs = new Account(Id = acc.Id, Amount_Till_Date__c = AmountToUpdate, Amount_Pending__c =AmountPending ,Total_Work_Days__c = TotalDays ); 
         insertAmountPerAccounts.add(accs);
    }
    if(insertAmountPerAccounts.size() > 0){
        update insertAmountPerAccounts;
    }
}