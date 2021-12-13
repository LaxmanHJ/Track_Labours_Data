import { LightningElement, track } from 'lwc';
import lookupSearchController from '@salesforce/apex/inputLookupController.getRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const DELAY = 300;
export default class LabourDataSearch extends LightningElement {
    @track accountNames;
    @track isLoading=false;
    @track selectedRecord;
    delayTimeout;
    objectLabel='Account';
    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

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
                     console.log('Accounts'+JSON.stringify(this.accountNames));
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
}