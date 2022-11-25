public class labourDetailUpdates {
    
    private labourDetailUpdates(){}
    /*
	insertToLabourDetail is used to insert records to Labour Detail
	*/
    @AuraEnabled
    public static String insertToLabourDetail(String labourDetails){
        String returnMsg = '';
        String strDate = '';
       //list to insert records
        List<Labour_Time__c> ltList = new List<Labour_Time__c>();
        //wrapper class to hold record
        List<labourDetailWrapper> parsedData = (List<labourDetailWrapper>) JSON.deserialize(labourDetails,List<labourDetailWrapper>.class);
        //loop throug each selected accounts and create date time
        for(labourDetailWrapper data2Update:parsedData){
            strDate = DateTime.newInstance(data2Update.Inpdate.year(), data2Update.Inpdate.month(), data2Update.Inpdate.day()).format('yyyy-MM-dd');
            Labour_Time__c lt = new Labour_Time__c();
            lt.Name__c = data2Update.Id;
            lt.Type_of_Day__c = data2Update.tod;
            lt.Work_Day__c = data2Update.Inpdate;
            lt.Description__c = data2Update.des;
            lt.Name = data2Update.accName+'-'+data2Update.des+'-'+strDate;
            ltList.add(lt);
        }
        
        if(!ltList.isEmpty()){
            //List<Labour_Time__c> ltExList = [SELECT ID,Work_Day__c,Name__c FROM Labour_Time__c WHERE Work_Day__c]; 
            try{
                insert ltList;
                returnMsg = 'Success';
            }catch(Exception e){
                returnMsg = e.getMessage();
            }
        }
        
        System.debug('ldw'+returnMsg);
        return returnMsg;
        
    }
    
    @Auraenabled
    public static List<labouDetailandAmountWrapper> getNoOfLabourTime(String accId){
        		labouDetailandAmountWrapper ldm = new labouDetailandAmountWrapper();
        		List<labouDetailandAmountWrapper> ldmList = new List<labouDetailandAmountWrapper>();
        		Map<String,Decimal> accIDvsAmountPay = new Map<String,Decimal>();
        		Account acc = [SELECT Id,Amount_Pending__c FROM Account WHERE Id =: accId LIMIT 1];
        		accIDvsAmountPay.put(acc.Id,acc.Amount_Pending__c);
                List<AggregateResult> aggList = [SELECT COUNT(Id) lTime, Name__c FROM Labour_Time__c WHERE Name__c =: accId and Is_Amount_Paid__c = false Group By Name__c]; 
        		for(AggregateResult agg:aggList){
            		ldm.countOfLabour = (Decimal)agg.get('lTime');
                    ldm.amountToPay = accIDvsAmountPay.get((Id)(agg.get('Name__c')));
                    ldmList.add(ldm);
        		}
        		System.debug('ldmLax'+ldmList);
        if(ldmList.size() <= 0 && acc.Amount_Pending__c > 0){
            //if user is partially paid show pending amount with 1 countofLabour
            ldm.countOfLabour = 1;
            ldm.amountToPay = acc.Amount_Pending__c;
           	ldmList.add(ldm);

        }
        		return ldmList;

    }
    
    //Wrapper to read data from LwC
    public class labourDetailWrapper{
       // @AuraEnabled
        public Id Id;
       // @AuraEnabled
        public String accName;
        public String tod;
       // @AuraEnabled
        public Date Inpdate; 
        //@AuraEnabled
        public String des;
    }
    
    public class labouDetailandAmountWrapper{
        @AuraEnabled
        public Decimal countOfLabour{get;set;}
        @AuraEnabled
        public Decimal amountToPay{get;set;}
    }
}