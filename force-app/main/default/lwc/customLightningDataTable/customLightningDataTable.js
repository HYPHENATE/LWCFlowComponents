/**
 * @description       : js for custom lightning data table
 * @author            : daniel@hyphen8.com
 * @last modified on  : 15-05-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

import getData from '@salesforce/apex/customLightningDataTableController.getFieldsAndRecords';
import generateSaveDataRecords from '@salesforce/apex/customLightningDataTableController.generateSaveDataRecords';

export default class CustomLightningDataTable extends LightningElement {

    @api sObjectAPIName;
    @api fieldSetAPIName;
    @api parentFieldAPIName;
    @api parentRecordId;
    @api allowAddRow = false;
    @api allowEdit = false;
    @api allowRowDeletion = false;
    @api maxRows;
    @api startingRowCount;
    @api whereClause;
    @api defaultFieldValues;
    @api newRecords;
    @api existingRecords;
    @api minRows;

    @api
    validate() {
        if(this.validForSaveCheck || !this.allowEdit) { 
            return { isValid: true }; 
        } else { 
            return { 
                isValid: false, 
                errorMessage: 'You need to complete this table before you proceed' 
            }; 
        }
    }

    @track columns;
    @track data;
    editData;
    @track defaultFields;

    @track rowCount = 0;
    offSet = 0;

    // standard connected callback for getting data and configuring dataTable
    connectedCallback(){

        this.handleGetData();
    }

    // apex funcation that pulls in key json to support with building the UI
    handleGetData() {
        getData({
            sObjectName: this.sObjectAPIName,
            fieldSetAPIName: this.fieldSetAPIName,
            parentIDField: this.parentFieldAPIName,
            parentId: this.parentRecordId,
            whereClause: this.whereClause
        })
        .then((results) => {

            // TODO MOVE ALL THIS INTO OWN FUNCTION FOR HANDLING SESSION STORAGE CHECKING
            let validationStateCheck = JSON.parse(sessionStorage.getItem('validationState'));
            let parentCheckId = sessionStorage.getItem('parentRecordCheckId');
            let sessionData = JSON.parse(sessionStorage.getItem('editData'));
            let rowCountSession = JSON.parse(sessionStorage.getItem('rowCount'));

            let useSessionStorage = true;

            if(validationStateCheck == undefined && parentCheckId == undefined){
                sessionStorage.clear();
                useSessionStorage = false;
            } else if(validationStateCheck == true){
                sessionStorage.clear();
                useSessionStorage = false;
            } else if(this.parentRecordId != parentCheckId){
                sessionStorage.clear();
                useSessionStorage = false;
            }

            let recordData = results.records;
            let fieldData = results.fieldDetail.fields;
            
            if(useSessionStorage){
                this.rowCount = rowCountSession;
            }

            let templateFields = [];
            fieldData.map(element=> {

                let pickListValues = this.getPickListValues(element.picklistOptions);
                let fieldType = this.getType(element.fieldType);
                let defaultValue;
                if(fieldType == 'checkbox'){
                    defaultValue = false;
                } else {
                    defaultValue = '';
                }
                templateFields = [...templateFields, {
                        value:defaultValue,
                        fieldAPIName:element.fieldAPIName,
                        fieldType:fieldType,
                        label:element.label,
                        scale:element.scale,
                        length:element.length,
                        required:element.required,
                        isPicklist:element.isPicklist,
                        isCheckbox:element.isCheckbox,
                        isText:element.isText,
                        isNumber:element.isNumber,
                        isDate:element.isDate,
                        isEmail:element.isEmail,
                        isPhone:element.isPhone,
                        isURL:element.isURL,
                        isPercent:element.isPercent,
                        isCurrency:element.isCurrency,
                        picklistOptions:pickListValues,
                        stepScale:element.stepScale
                }];
            });
            
            let editItems = [];
            recordData.map(element=> {
                if(!useSessionStorage){
                    this.rowCount = this.rowCount + 1;
                }
                var recordId = element.Id;
                const arrayOfObj = Object.entries(element).map((e) => ( { key: e[0], value: e[1] } ));

                let individualrecord = [];

                fieldData.forEach(element=> {
                    let pickListValues = this.getPickListValues(element.picklistOptions);
                    var fieldValue = arrayOfObj.find(field => field.key === element.fieldAPIName);
                    let value;
                    if(fieldValue == undefined){
                        value = '';
                    } else {
                        value = fieldValue.value;
                    }
                    individualrecord = [...individualrecord, {
                        value:value, 
                        fieldAPIName:element.fieldAPIName, 
                        fieldType:this.getType(element.fieldType), 
                        required:element.required, 
                        isPicklist:element.isPicklist,
                        isCheckbox:element.isCheckbox,
                        isText:element.isText,
                        isNumber:element.isNumber,
                        isDate:element.isDate,
                        isEmail:element.isEmail,
                        isPhone:element.isPhone,
                        isURL:element.isURL,
                        isPercent:element.isPercent,
                        isCurrency:element.isCurrency,
                        picklistOptions:pickListValues,
                        stepScale:element.stepScale,
                        scale:element.scale,
                        length:element.length}];
                });
                editItems = [...editItems, {id: recordId, fields: individualrecord}];
            });

            let items = [];
            fieldData.map(element=> {
                items = [...items ,{label: element.label, fieldName: element.fieldAPIName, type: this.getType(element.fieldType)}];
            });

            this.columns = items; 
            this.data = recordData;
            this.defaultFields = templateFields;
    
            if(useSessionStorage){
                this.editData = sessionData;
            } else {
                this.editData = editItems;
            }

            if(this.allowAddRow && this.allowEdit) {
                let startingCount = this.rowCount + 1;
                for(var i = startingCount; i <= this.startingRowCount; i++) {
                    this.generateRecord();
                }
            }

            if(this.allowAddRow && this.allowEdit){
                this.generateSaveData();
                this.configureSessionStorage();
            } else {
                 sessionStorage.clear();
            }
        })
        .catch((error) => {
            console.error('error handleGetData > ' + JSON.stringify(error.message));
            this.showToast('Error encountered', 'Contact the site administrator an error or configuration error has been encountered', 'error');
        });
    }

    // function when action addRow is clicked in UI it will create a new rowRecord based off the template
    addRow(event){
        this.generateRecord();
    }

    // converts a list of picklist values into the correct format
    getPickListValues(pickValues){
        let pickListValues = [];
        pickValues.map(element=>{
            pickListValues = [...pickListValues, { label: element, value: element}];
        });
        return pickListValues;
    }

    // helper function that is used to support with confirming what type of field we need to output
    getType(typeValue){
        switch (typeValue){
            case 'string':
                return 'text';
            case 'email':
                return 'email';
            case 'phone':
                return 'phone';
            case 'boolean':
                return 'checkbox';
            case 'date':
                return 'date';
            case 'datetime':
                return 'date';
            case 'url':
                return 'url';
            case 'textarea':
                return 'text';
            case 'picklist':
                return 'combobox';
            case 'currency':
                return 'number';
            case 'double':
                return 'number';
            case 'percent':
                return 'number';
        }
    }

    // get to confirm if we are allowed to show the row add button
    get displayRowAddButton(){
        let currentRowCount = this.rowCount + 1;
        if(currentRowCount <= this.maxRows && this.allowAddRow){
            return true;
        } else {
            return false;
        }
    }
    
    // generate blank record and add to edit data array
    generateRecord(){
        this.rowCount = this.rowCount + 1;
        var randomValue = Math.floor(Math.random() * 1000) + 1;
        let fields = this.defaultFields;
        this.editData = [...this.editData, {id: 'A' + randomValue.toString(), fields}];
        this.configureSessionStorage();
    }

    // dispatch event that updates row count and removes rows / records
    handleRowDelete(event){
        this.rowCount = this.rowCount - 1;
        const deleteRowEvent = event.detail.detail;
        this.handleRemoveRecord(deleteRowEvent);
        if(deleteRowEvent.charAt(0) != 'A'){
            this.handleDeleteRecord(deleteRowEvent);
        }
    }

    // function to remove a record from editData
    handleRemoveRecord(value){
        let cleanData = this.editData.filter(function(record) {
            return record.id !== value;
        });
        this.editData = [];
        this.editData = cleanData;
        this.generateSaveData();
    }
    
    // generic delete recordExample
    handleDeleteRecord(rowId){
        deleteRecord(rowId)
        .catch(error => {
            console.error(JSON.stringify(error.message));
        })
    }

    // apex method that generating the data in a save / update format
    generateSaveData() {
        generateSaveDataRecords({
            sObjectAPIName: this.sObjectAPIName,
            parentIDField: this.parentFieldAPIName,
            parentId: this.parentRecordId,
            dataArray: JSON.stringify(this.editData),
            defaultFieldValues: this.defaultFieldValues
        })
        .then((results) => {

            let newRecordList = [];
            let oldRecordList = [];

            results.forEach(element => {
                if(element.Id == undefined){
                    newRecordList.push(element);
                } else {
                    oldRecordList.push(element);
                }
            })

            this.newRecords = newRecordList;
            this.existingRecords = oldRecordList;

            this.notifyFlowComponentOfData('newRecords', newRecordList);
            this.notifyFlowComponentOfData('existingRecords', oldRecordList);

            this.configureSessionStorage();
        })
        .catch((error) => {
            console.error('error generateSaveData > ' + JSON.stringify(error.message));
       });
    }


    // bubble up function from child component to handle changes
    handleRowUpdate(event){

        let rowId = event.detail.recordId;
        let rowData = event.detail.rowData;

        const rowIndex = this.editData.findIndex(
            (row) => row.id === rowId
        );

        this.editData[rowIndex].fields = rowData;
        this.generateSaveData();
    }

    // save validation function
    get validForSaveCheck(){
        let validForSave = true;

        this.editData.forEach(element => {
            let fields = element.fields;

            fields.forEach(field => {
                if(field.required && field.value == ''){
                    validForSave = false;
                }
            });
        });
        if(this.minRows > 0 && this.rowCount < this.minRows){
            validForSave = false;
        }
        return validForSave;
    }

    // setup session storage
    configureSessionStorage(){
        sessionStorage.setItem('editData', JSON.stringify(this.editData));
        sessionStorage.setItem('rowCount', this.rowCount);
        sessionStorage.setItem('validationState', this.validForSaveCheck);
        sessionStorage.setItem('parentRecordCheckId', this.parentRecordId);
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
        this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }

    // send records function to the flow for processing
    notifyFlowComponentOfData(variable, value){
        const attributeChangeEvent = new FlowAttributeChangeEvent(
            variable,
            value
        );
        this.dispatchEvent(attributeChangeEvent);
    }

}