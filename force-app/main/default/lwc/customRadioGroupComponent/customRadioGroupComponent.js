/**
 * @description       : 
 * @author            : daniel@hyphen8.com
 * @last modified on  : 08-10-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   20/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api, wire} from 'lwc';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class CustomRadioGroupComponent extends LightningElement {
    
    //TODO:  Pass in own List of values (Custom) to display as radio / button options - DONE
    //TODO:  Include a ',' in one of the pick list values (Thanks DC!!) - DONE
    //TODO:  Work out if we need to process Wire service or passed in values
    //TODO:  Pass in TWO lists - One for Labels and one for Values for pick lists
    //TODO:  Display one set of values to the user, but store DIFFERENT values in the back end
    //TODO:  Update flow  to query Record Type Id based on the Record Type dev Name

    @api label;
    @api required;
    @api disabled;
    @api radioType;
    @api variant;
    @api requiredFieldMissingValue;
    @api pickListValues;
    @api seperatorValue;

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
    pickListValuesArray;

    @wire(getObjectInfo, { objectApiName: '$objectAPIName' })
    objectMetadata({ error, data }) {
        if(data){
            this.objectMeta = data;
            console.log(data);
        } else if(error){
            console.error(error);
        }
    };

    processPickListValuesToArray() {
        if(this.pickListValues) {
            let finalFieldArray = [];
            let fieldArray = this.pickListValues.split(this.seperatorValue);
            console.log('Seperator Value = '+ this.seperatorValue);
            fieldArray.forEach(element => {
                let trimmedElement = element.trim();
                if(trimmedElement.length>0) {
                    finalFieldArray.push(trimmedElement);
                }
            });
            this.pickListValuesArray = finalFieldArray;
        }
    }

    /*@wire(getPicklistValues, { recordTypeId: '$chosenRecordType', fieldApiName: '$fieldObject' })
    pickListData({ error, data }) {
        if(data){
            this.options = data.values;
            console.log(data);
        } else if(error){
            console.error(error);
        }
    }; */

    
    

    connectedCallback(){
        console.log('my options are > ' + this.options);
        let objfiedAPIName = {};
        objfiedAPIName.fieldApiName = this.fieldAPIName;
        objfiedAPIName.objectApiName = this.objectAPIName;
        this.fieldObject = objfiedAPIName;
        console.log('object > ' + JSON.stringify(this.fieldObject));
        console.log('items');
        console.log(this.pickListValues);
        //pickListValues = Industry,Test,Account
        this.processPickListValuesToArray();
        //pickListValuesArray = [Industry, Test, Account];
        this.options = this.pickListValuesArray.map(item => {
            return {label: item, value: item};
        });

        //options = [{label: Industry, value: Industry}, {label: Test, value: Test}, {label: Account, value: Account}];
        
    }


    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        console.log('run validation');
        let validInput = this.validateInput();
        //this.setCustomValidityMessage(this.requiredFieldMissingValue);
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }

    // method that performs the actual validation on the field on screen
    validateInput(){
        let customErrorMessage = '';
        
        //Logic for checking valid
        if(!this.value && this.required) {
            this.isValid = false;
            customErrorMessage = this.requiredFieldMissingValue;
            this.setCustomValidityMessage(customErrorMessage);
        } else {
            this.isValid = true;
            this.setCustomValidityMessage('');
        }

        return {isValid: this.isValid, errorMessage: customErrorMessage};
    }

    // simple method for setting custom validation message on the field
    setCustomValidityMessage(message){
        //TODO fix this - it's not reporting the error back to the component
        var radioGroup = this.template.querySelector(".customRadioGroup");
        console.log(message);
        radioGroup.setCustomValidity(message);
        radioGroup.reportValidity();
    }

    //Onchange for setting value to pass back to Flow
    handleRadioChange(event){
        this.value = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('value', event.detail.value));
        this.validateInput();
    }
    
}