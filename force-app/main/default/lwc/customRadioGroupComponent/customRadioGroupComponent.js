/**
 * @description       : 
 * @author            : daniel@hyphen8.com
 * @last modified on  : 20/07/2021
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   20/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api, wire} from 'lwc';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';

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
    @api recordTypeDeveloperName;

    fieldObject;
    objectMeta;

    options;

    @wire(getObjectInfo, { objectApiName: '$objectAPIName' })
    objectMetadata({ error, data }) {
        if(data){
            this.objectMeta = data;
            console.log(data);
        } else if(error){
            console.log(error);
        }
    };

    //TODO improve to pass in record type and detect if record type is blank - use default
    @wire(getPicklistValues, { recordTypeId: '$objectMeta.defaultRecordTypeId', fieldApiName: '$fieldObject' })
    pickListData({ error, data }) {
        if(data){
            this.options = data.values;
            console.log(data);
        } else if(error){
            console.log(error);
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
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }

    // method that performs the actual validation on the field on screen
    validateInput(){
        let valid = true;
        let customErrorMessage = '';
        
        //TODO logic for checking valid

        return {isValid: valid, errorMessage: customErrorMessage};
    }

    //TODO onchange for setting value to pass back to Flow
    
}