import { LightningElement, track } from 'lwc';
import lookupSearchController from '@salesforce/apex/inputLookupController.getRecords';
import getlabourTime from '@salesforce/apex/labourDetailUpdates.getNoOfLabourTime';
import updateAmount from '@salesforce/apex/AccountService.updateAmount';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const DELAY = 300;
const columns = [
    {
        label: 'Name',
        fieldName: 'lName',
        type: 'text'
    },
    {
        label: 'No_Of_Days',
        fieldName: 'countOfLabour',
        type: 'text'
    },
    {
        label: 'Amount to Pay',
        fieldName: 'amountToPay',
        type: 'text'
    }
];
export default class LabourDataSearch extends LightningElement {
    @track accountNames;
    @track isLoading=false;
    @track selectedRecord;
    @track selectedDate;
    @track laboursTimeData;
    @track showDatatable = false;
    @track amountPaid;
    @track returnMsg;
    @track amountPending;
    @track selAccName;

    columns = columns;
    delayTimeout;
    objectLabel='Account';
    ICON_URL = 'apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#account';
    

    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        //this.isLoading = true;
        this.delayTimeout = setTimeout(() => {
            if(searchKey.length >= 2){
                lookupSearchController({ 
                    objName : 'Account',
                    inputTxt : searchKey 
                })
                .then(result => {
                     this.accountNames =result;
                })
                .catch(error => {
                    console.error('Error:', error);
                })
                .finally( ()=>{
                    //this.isLoading = false;
                });
            }
        }, DELAY);
}

handleSelect(event){
        
    let recordId = event.currentTarget.dataset.recordId;
    
    let selectRecord = this.accountNames.find((item) => {
        return item.Id === recordId;
    });
    this.selectedRecord = selectRecord;
    this.selAccName = this.selectedRecord.Name;
    const selectedEvent = new CustomEvent('lookup', {
        bubbles    : true,
        composed   : true,
        cancelable : true,
        detail: {  
            data : {
                record          : selectRecord,
                recordId        : recordId,
                currentRecordId : this.currentRecordId
            }
        }
    });
    this.dispatchEvent(selectedEvent);
}

handleClose(){
    this.selectedRecord = undefined;
    this.showDatatable = false;
    this.accountNames  = undefined;
    const selectedEvent = new CustomEvent('lookup', {
        bubbles    : true,
        composed   : true,
        cancelable : true,
        detail: {  
            record ,
            recordId,
            currentRecordId : this.currentRecordId
        }
    });
    this.dispatchEvent(selectedEvent);
}

applyFilters(){
    getlabourTime({accId : this.selectedRecord.Id})
    .then(data=>{
        this.laboursTimeData = data;
        this.showDatatable = true;
        this.amountPending = this.laboursTimeData.length > 0 ? true : false;
        if(this.laboursTimeData){
            this.laboursTimeData.forEach(item => item['lName'] = this.selectedRecord.Name);
            this.laboursTimeData.forEach(item => item['countOfLabour'] = item['countOfLabour']);
            this.laboursTimeData.forEach(item => item['amountToPay'] = item['amountToPay']);

        }
    })
    .catch(error => {
        console.log('Error: ', error);
    }) 
}

handleReset(){
    this.showDatatable = false;
    this.selectedRecord = undefined;
    this.accountNames  = undefined;

}

applyDateInputChange(event){
    this.selectedDate = event.target.value;

}

handleAmountPaid(event){
    this.amountPaid = event.target.value;

    
}

applySaveAmount(){
    updateAmount({accId : this.selectedRecord.Id,amountPaid : this.amountPaid})
    .then(retMsg=>{
        this.returnMsg = retMsg;

        if(this.returnMsg === 'Success'){
            const evt = new ShowToastEvent({
                title: 'success',
                message: 'Paid Amount Updated sucessfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else {
            const evtFail = new ShowToastEvent({
                title: 'Fail',
                message: 'Paid Amount failed to Update' + retMsg,
                variant: 'Fail',
                mode: 'dismissable'
            });
            this.dispatchEvent(evtFail);
        
        }
    }).catch(error => {
        console.log('Error: ', error);
    }) 

   this.handleReset();
}
}