public class inputLookupController {
    @auraEnabled
    public static List<sObject> getRecords(string inputTxt, string objName) {
        inputTxt = '\'%'+inputTxt+'%\'';
        String Query = 'Select Id, Name FROM '+objName+' WHERE Name LIKE ' + inputTxt;
        return Database.Query(Query);
    }

}