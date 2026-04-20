/**
 * @description       : LWC component for CPE of Data Fetcher Flow Action
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, track } from 'lwc';
import getSObjects from "@salesforce/apex/H8DataFetcherController.getSObjects";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";

export default class H8DataFetcher extends LightningElement {
    @api queryDeveloperName;
    @api bindsJson;
    @api firstRetrievedRecord;
    @api retrievedRecords = [];
    @api error;
    @api debounceTime;
    @track oldQuery;
    @track displayError;


    renderedCallback() {
        // Execute SOQL methods when parameters change
        const queryKey = `${this.queryDeveloperName ?? ''}::${this.bindsJson ?? ''}`;
        if (this.queryDeveloperName && queryKey !== this.oldQuery) {
        this._getRecords();
        }
    }

    handleOnChange() {
        this._debounceGetRecords();
        
    }

    _getRecords() {
        
        getSObjects({ queryDeveloperName: this.queryDeveloperName, bindsJson: this.bindsJson })
            .then(({ results, firstResult }) => {
            this.error = undefined;
            this.retrievedRecords = results;
            this.firstRetrievedRecord = firstResult;
            this._fireFlowEvent("firstRetrievedRecord", this.firstRetrievedRecord);
            this._fireFlowEvent("retrievedRecords", this.retrievedRecords);
            })
            .catch(error => 
            {this.error = error?.body?.message ?? JSON.stringify(error);
            console.error(error.body.message);
            this._fireFlowEvent("error", this.error);});

            this.oldQuery = `${this.queryDeveloperName ?? ''}::${this.bindsJson ?? ''}`;
        
    }

    _debounceGetRecords() {    
        this._debounceTimer && clearTimeout(this._debounceTimer);
        if (this.queryDeveloperName){
        this._debounceTimer = setTimeout(() => this._getRecords(), this.debounceTime);    
        }
        
    }  

    _fireFlowEvent(eventName, data) {
        this.dispatchEvent(new FlowAttributeChangeEvent(eventName, data));
    }

    get displayError() {
        return Boolean(this.error);
    }
}
