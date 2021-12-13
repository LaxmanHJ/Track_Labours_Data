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
}