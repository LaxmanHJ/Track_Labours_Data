import { LightningElement,track,wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountService.getAccounts';
import insertToLD from '@salesforce/apex/labourDetailUpdates.insertToLabourDetail';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// const columns = [
//     { label: 'Name', fieldName: 'Name' },
//     { label: 'Phone No', fieldName: 'Phone', type: 'Text' },
//     { label: 'Rating', fieldName: 'Type_Of_Day__c', type: 'picklist', editable: true,typeAttributes: {
//         placeholder: 'Choose rating', options: [
//             { label: 'Hot', value: 'Hot' },
//             { label: 'Warm', value: 'Warm' },
//             { label: 'Cold', value: 'Cold' },
//         ] } }
// type: 'standard__objectPage',
//     attributes: {
//         objectApiName: 'Account',
//         actionName: 'list'
//     },
//     state: {       
//         filterName: 'Recent' 
//     }
// ];
export default class Labour_details extends NavigationMixin(LightningElement) {
    //@track searchKey;
    @track disableButton = true;
    @track isDateSelected = false;
    @track isCheckboxSelected = false;
	@track accounts;
    @track isEdited = false;
	@track error;
    @track enteredDate;
    @track enteredDes;
    @track pickValue;
    @track tempList=[];
    @track msg;
   // @track selectedCons=[];
    //columns = columns;
    options = [
        { label: 'Full-Day', value: 'Full Day' },
        { label: 'Half-Day', value: 'Half Day' },
        { label: 'Only-Morning', value: "Only Morning" },
        { label: 'Only-Evening', value: "Only Evening" }
];   

	@wire (getAccounts)
	wiredAccounts({data, error}){
		if(data) {
			this.accounts =data;
			this.error = undefined;
		}else {
			this.accounts = undefined;
			this.error = error;
		}
	}


    handleDate(event){
        this.isDateSelected = true;
        this.enteredDate = event.detail.value;

        this.disableButton = !(this.isDateSelected && this.isCheckboxSelected);

    }

    handleDes(event){
        this.enteredDes = event.detail.value;

    }
    handlePicklistChange(event) {
            let newList = this.tempList;
            newList.push({Id:event.target.dataset.id,tod:event.detail.value});
            this.tempList = newList;
    }

    onDoubleClickEdit() {
        this.isEdited = true;
    }
    handleCheckBoxSelect(event){
        this.isCheckboxSelected = true;
        this.isEdited = true;
        this.disableButton = !(this.isDateSelected && this.isCheckboxSelected);

    }

    upsertDetail(){
        this.selectedCons = [];

        let selectedRows = this.template.querySelectorAll('lightning-input');
        let typeOfDay = "" ;
        let dec = this.enteredDes ? this.enteredDes : "Field Work";
        // based on selected row getting values of the contact
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
                //check if typeOfDay is selected
                let element = this.tempList.find(ele  => ele.Id === selectedRows[i].dataset.id);
                if(element){
                    typeOfDay = element.tod;
                }else{
                    typeOfDay =  "Full Day";
                }
                

                this.selectedCons.push({
                    Id: selectedRows[i].dataset.id,
                    accName: selectedRows[i].value,
                    tod: typeOfDay,
                    Inpdate: this.enteredDate,
                    des: dec
                })

            }
        }

        //call labour update method only if records are selected
        if(this.selectedCons.length > 0){
            this.applylabourUpdate();
    }
        

        // let element = this.tempList.find(ele  => ele.Id === '0012w00000M9MjbAAF');
        // typeOfDay = element.tod ? element.tod : "Full Day";
        // console.log('tod'+typeOfDay);
        
    }
    applylabourUpdate(){
        insertToLD({labourDetails: JSON.stringify(this.selectedCons)})
        .then(data=>{
            this.msg = data;
            if(this.msg === 'Success'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Labour Details Updated sucessfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Labour_Time__c',
                        actionName: 'list'
                    },
                    state: {       
                        filterName: '00B2w00000GZdNGEA1' 
                    }
                });
        }
        })
    
        .catch(error => {
            console.log('Error: ', error);
        }) 
    }
}