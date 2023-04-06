/**
 * @description       : js for row level data table items
 * @author            : daniel@hyphen8.com
 * @last modified on  : 06-04-2023
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, track } from 'lwc';

export default class CustomLightningDataTableRow extends LightningElement {

    currentData = {};
    @api 
    get rowData(){
        return this._rowData;
    };

    set rowData(value){
        this._rowData = value;
        this.currentData = value;
    }
    @api recordId;
    @api rowDeleteEnabled;


    // function that tracks changes and commits at field level to ensure that master editData is kept up to
    // date with changes in the UI
    fieldChange(event){
        
        let eventFieldAPIName = event.target.dataset.targetField;
        let eventFieldType = event.target.dataset.targetFieldType;

        let eventValue;
        if(eventFieldType === 'checkbox')
        {
            eventValue = event.target.checked;
        } else {
            eventValue = event.target.value;
        }

        let thisfield = this.rowData.fields.find(field => field.fieldAPIName === eventFieldAPIName);
        let newValue = {value:eventValue};
        thisfield = {...thisfield, ...newValue};
        const datafields = [...this.currentData.fields];
        const index = datafields.findIndex((field) => field.fieldAPIName === eventFieldAPIName);
        datafields.splice(index, 1, thisfield);
        this.currentData = {'id':this.rowData.id, 'fields': datafields};
        this.dispatchEventFunction('rowupdated', {recordId: this.recordId, rowData: this.currentData.fields});
    }

    // function to support with removing and deleting records from rows
    deleteRow(event){
        this.dispatchEventFunction('rowdeleted', { detail : this.recordId});
    }

    // generic dispatch event function
    dispatchEventFunction(eventName, eventDetail) {
       this.dispatchEvent(new CustomEvent(eventName, { detail: eventDetail }));
    }

    
}