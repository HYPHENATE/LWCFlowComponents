/**
 * @description       : 
 * @author            : daniel@hyphen8.com
 * @last modified on  : 27/07/2021
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   20/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api, wire} from 'lwc';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class CustomRadioGroupComponent extends LightningElement {
    
    @api label;
    @api required;
    @api disabled;
    @api radioType;
    @api variant;
    @api requiredFieldMissingValue;

    @api value = '';
    @api objectAPIName;
    @api fieldAPIName;
    @api recordTypeId;
    isValid = true;
    get chosenRecordType(){
        if (this.recordTypeId){
            return this.recordTypeId;
        }else {
            return this.objectMeta.defaultRecordTypeId;
        }
    }

    fieldObject;
    objectMeta;
    options;

    @wire(getObjectInfo, { objectApiName: '$objectAPIName' })
    objectMetadata({ error, data }) {
        if(data){
            this.objectMeta = data;
            console.log(data);
        } else if(error){
            console.error(error);
        }
    };

    @wire(getPicklistValues, { recordTypeId: '$chosenRecordType', fieldApiName: '$fieldObject' })
    pickListData({ error, data }) {
        if(data){
            this.options = data.values;
            console.log(data);
        } else if(error){
            console.error(error);
        }
    };

    
    

    connectedCallback(){
        console.log('my options are > ' + this.options);
        let objfiedAPIName = {};
        objfiedAPIName.fieldApiName = this.fieldAPIName;
        objfiedAPIName.objectApiName = this.objectAPIName;
        this.fieldObject = objfiedAPIName;
        console.log('object > ' + JSON.stringify(this.fieldObject));
    }


    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        let validInput = this.validateInput();
        //this.setCustomValidityMessage(this.requiredFieldMissingValue);
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }

    // method that performs the actual validation on the field on screen
    validateInput(){
        let customErrorMessage = '';
        
        //Logic for checking valid
        if(!this.value && this.required)
        {
            this.isValid = false;
            customErrorMessage = requiredFieldMissingValue;
        }

        return {isValid: this.isValid, errorMessage: customErrorMessage};
    }

    // simple method for setting custom validation message on the field
    setCustomValidityMessage(message){
        //TODO fix this - it's not reporting the error back to the component
        var radioGroup = this.template.querySelector(".customRadioGroup");
        radioGroup.setCustomValidity(message);
        radioGroup.reportValidity();
    }

    //Onchange for setting value to pass back to Flow
    handleRadioChange(event){
        console.log('WE HAVE GOT ' + event.detail.value);
        this.value = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('value', event.detail.value));
    }

    // handleGetRecordTypeIdFromName(){

    //     const recordTypeInfo =  this.objectMeta.recordTypeInfos;

    //     console.log('recordtypeInfo ' + JSON.stringify(recordTypeInfo));

    //     this.recordTypeId = Object.keys(recordTypeInfo).find(rt => {
    //                                                             console.log(recordTypeInfo[rt].name);
    //                                                             return recordTypeInfo[rt].name === this.recordTypeDeveloperName;
    //                                                         });
    // }

    //TODO - Exclude values from the list or set your own values to display
    
}