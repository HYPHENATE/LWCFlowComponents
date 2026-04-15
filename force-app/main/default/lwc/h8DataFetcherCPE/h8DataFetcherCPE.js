/**
 * @description       : LWC component for CPE of Data Fetcher Flow Action
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, track, wire } from 'lwc';
import getAvailableQueries from '@salesforce/apex/H8DataFetcherController.getAvailableQueries';

const DATA_TYPE = {
    STRING: 'String',
    BOOLEAN: 'Boolean',
    NUMBER: 'Number',
    INTEGER: 'Integer'
};

const FLOW_EVENT_TYPE = {
    DELETE: 'configuration_editor_input_value_deleted',
    CHANGE: 'configuration_editor_input_value_changed'
}

export default class H8DataFetcherCPE extends LightningElement {
    @api automaticOutputVariables;
    typeValue;
    _builderContext = {};
    _values = [];
    _flowVariables = [];
    _typeMappings = [];
    rendered;
    _lastDispatchedTypeValue;
    queryOptions = [];
    _queryObjectApiNameByDeveloperName = new Map();
    _propertySheetErrors = [];

    @track inputValues = {
        queryDeveloperName: { value: null, valueDataType: null, isCollection: false, label: 'Query Developer Name' },
        bindsJson: { value: null, valueDataType: null, isCollection: false, label: 'Bind Variables (JSON)' },
        debounceTime: {value: '300', valueDataType: null, isCollection: false, label: 'Debounce Time'},
    };

    @api
    get errors() {
        return this._propertySheetErrors;
    }
    set errors(value) {
        this._propertySheetErrors = value || [];
        this._applyErrorsToInputs();
    }

    @wire(getAvailableQueries)
    wiredQueries({ error, data }) {
        if (data) {
            this.queryOptions = data.map((q) => ({
                label: q.label,
                value: q.developerName,
                objectApiName: q.objectApiName
            }));
            this._queryObjectApiNameByDeveloperName = new Map(
                data.map((q) => [q.developerName, q.objectApiName])
            );
            this._ensureGenericTypeMapping();
        } else if (error) {
            // Keep UI usable even if metadata query list fails; user can still type the dev name manually.
            this.queryOptions = [];
        }
    }

    @api get builderContext() {
        return this._builderContext;
    }

    set builderContext(value) {
        this._builderContext = value;
    }

    @api get inputVariables() {
        return this._values;
    }

    set inputVariables(value) {
        this._values = value;
        this.initializeValues();
        this._ensureGenericTypeMapping();
    }

    @api get genericTypeMappings() {
        return this._genericTypeMappings;
    }
    set genericTypeMappings(value) {
        this._typeMappings = value;
        this.initializeTypeMappings();
        this._ensureGenericTypeMapping();
    }

    /* LIFECYCLE HOOKS */
   
        

    renderedCallback() {
        if (!this.rendered) {
            this.rendered = true;
            for (let flowCombobox of this.template.querySelectorAll('c-h8-data-fetcher-c-p-e-combobox')) {
                flowCombobox.builderContext = this.builderContext;
                flowCombobox.automaticOutputVariables = this.automaticOutputVariables;
            }
            this._ensureGenericTypeMapping();
            this._applyErrorsToInputs();
        }
                
    }

    /* ACTION FUNCTIONS */
    initializeValues(value) {
        if (this._values && this._values.length) {
            this._values.forEach(curInputParam => {
                if (curInputParam.name && this.inputValues[curInputParam.name]) {                    
                    if (this.inputValues[curInputParam.name].serialized) {
                        this.inputValues[curInputParam.name].value = JSON.parse(curInputParam.value);
                    } else {
                        this.inputValues[curInputParam.name].value = curInputParam.value;
                    }
                    this.inputValues[curInputParam.name].valueDataType = curInputParam.valueDataType;
                }
            });
        }
    }

    initializeTypeMappings() {
        this._typeMappings.forEach((typeMapping) => {
            
            if (typeMapping.name && typeMapping.value) {
                this.typeValue = typeMapping.value;
            }
        });
    }

    /* EVENT HANDLERS */

    handleQueryChange(event) {
        const devName = event.detail.value;
        this.inputValues.queryDeveloperName.value = devName;
        this.dispatchFlowValueChangeEvent('queryDeveloperName', devName, 'String');
        const objApiName = this._queryObjectApiNameByDeveloperName.get(devName);
        if (objApiName) {
            this._dispatchGenericTypeMapping(objApiName);
        }
    }

    handleQueryDeveloperNameTextChange(event) {
        const devName = event.detail.value;
        this.inputValues.queryDeveloperName.value = devName;
        this.dispatchFlowValueChangeEvent('queryDeveloperName', devName, 'String');
        const objApiName = this._queryObjectApiNameByDeveloperName.get(devName);
        if (objApiName) {
            this._dispatchGenericTypeMapping(objApiName);
        }
    }

    handleFlowComboboxValueChange(event) {
        if (event.target && event.detail) {
            this.dispatchFlowValueChangeEvent(event.target.name, event.detail.newValue, event.detail.newValueDataType);
        };
    }


    dispatchFlowValueChangeEvent(id, newValue, dataType = DATA_TYPE.STRING) {
        if (this.inputValues[id] && this.inputValues[id].serialized) {
            newValue = JSON.stringify(newValue);
        }
        const valueChangedEvent = new CustomEvent(FLOW_EVENT_TYPE.CHANGE, {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: {
                name: id,
                newValue: newValue ? newValue : null,
                newValueDataType: dataType
            }
        });
        this.dispatchEvent(valueChangedEvent);
    }

    _ensureGenericTypeMapping() {
        // Ensure the generic type mapping for `T` is set so outputs are typed (e.g. {T[]} -> Account[]).
        // Prefer existing Flow mapping; otherwise infer from the selected query metadata (ObjectApiName__c).
        let mappedTypeValue;

        if (Array.isArray(this._typeMappings) && this._typeMappings.length) {
            const mappingT = this._typeMappings.find((m) => m && m.name === 'T' && m.value);
            mappedTypeValue = mappingT ? mappingT.value : undefined;
        }

        if (!mappedTypeValue) {
            const devName = this.inputValues?.queryDeveloperName?.value;
            mappedTypeValue = devName ? this._queryObjectApiNameByDeveloperName.get(devName) : undefined;
        }

        this._dispatchGenericTypeMapping(mappedTypeValue);
    }

    _dispatchGenericTypeMapping(typeValue) {
        if (!typeValue || this._lastDispatchedTypeValue === typeValue) {
            return;
        }

        this._lastDispatchedTypeValue = typeValue;
        const typeName = 'T';
        const dynamicTypeMapping = new CustomEvent('configuration_editor_generic_type_mapping_changed', {
            composed: true,
            cancelable: false,
            bubbles: true,
            detail: {
                typeName,
                typeValue,
            }
        });
        this.dispatchEvent(dynamicTypeMapping);
    }

    @api
    validate() {
        const errors = [];

        const queryDevName = this.inputValues?.queryDeveloperName?.value;
        if (!queryDevName) {
            errors.push({ key: 'queryDeveloperName', errorString: 'Select a Query Developer Name.' });
        } else if (this.queryOptions.length && !this._queryObjectApiNameByDeveloperName.get(queryDevName)) {
            errors.push({ key: 'queryDeveloperName', errorString: `Unknown query: ${queryDevName}` });
        }

        const bindsJson = this.inputValues?.bindsJson?.value;
        if (bindsJson) {
            try {
                const parsed = JSON.parse(bindsJson);
                if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
                    errors.push({ key: 'bindsJson', errorString: 'Bind Variables (JSON) must be a JSON object (e.g. {"type":"Customer"}).' });
                }
            } catch (e) {
                errors.push({ key: 'bindsJson', errorString: 'Bind Variables (JSON) must be valid JSON.' });
            }
        }

        const debounceTime = this.inputValues?.debounceTime?.value;
        if (debounceTime && isNaN(Number(debounceTime))) {
            errors.push({ key: 'debounceTime', errorString: 'Debounce Time must be a number (milliseconds).' });
        }

        this._renderEditorValidation(errors);
        return errors;
    }

    _applyErrorsToInputs() {
        // Flow Builder injects property sheet errors via `errors`. Render them on the relevant inputs.
        if (!this.rendered) {
            return;
        }

        const messagesByKey = new Map();
        (this._propertySheetErrors || []).forEach((e) => {
            if (e && e.key && e.errorString) {
                messagesByKey.set(e.key, e.errorString);
            }
        });

        this._setInputValidity('queryDeveloperName', messagesByKey.get('queryDeveloperName'));
        this._setInputValidity('bindsJson', messagesByKey.get('bindsJson'));
        this._setInputValidity('debounceTime', messagesByKey.get('debounceTime'));
    }

    _renderEditorValidation(errors) {
        const messagesByKey = new Map();
        (errors || []).forEach((e) => {
            if (e && e.key && e.errorString) {
                messagesByKey.set(e.key, e.errorString);
            }
        });
        this._setInputValidity('queryDeveloperName', messagesByKey.get('queryDeveloperName'));
        this._setInputValidity('bindsJson', messagesByKey.get('bindsJson'));
        this._setInputValidity('debounceTime', messagesByKey.get('debounceTime'));
    }

    _setInputValidity(key, message) {
        if (!this.rendered) {
            return;
        }

        let element;
        if (key === 'queryDeveloperName') {
            element = this.template.querySelector('[data-id="queryDeveloperName"]');
        } else {
            element = this.template.querySelector(`[data-id="${key}"]`);
        }

        if (!element || typeof element.setCustomValidity !== 'function' || typeof element.reportValidity !== 'function') {
            return;
        }

        element.setCustomValidity(message || '');
        element.reportValidity();
    }
}
