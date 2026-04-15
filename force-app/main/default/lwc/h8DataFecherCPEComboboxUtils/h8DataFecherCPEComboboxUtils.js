/**
 * @description       : Utility functions for handling combobox values in Salesforce Flow, including determining data types and formatting values for flow variables.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
const flowComboboxDefaults = {
    stringDataType: 'String',
    referenceDataType: 'reference',
    defaultKeyPrefix: 'flowCombobox-',
    defaultGlobalVariableKeyPrefix: 'flowCombobox-globalVariable-',
    recordLookupsType:'recordLookups',
    recordCreatesType:'recordCreates',
    recordUpdatesType:'recordUpdates',
    dataTypeSObject: 'SObject',
    isCollectionField: 'isCollection',
    actionType: 'actionCalls',
    screenComponentType: 'screenComponent',
    screenActionType: 'screenAction',

}

const isReference = (value) => {
    if (!value) {
        return false;
    }
    let isRef = value.indexOf('{!') === 0 && value.lastIndexOf('}') === (value.length - 1);
    return isRef;
};

const getDataType = (currentText) => {
    if (isReference(currentText)) {
        return flowComboboxDefaults.referenceDataType;
    } else {
        return flowComboboxDefaults.stringDataType;
    }
}

const formattedValue = (value, dataType) => {
    if (isReference(value)) {
        return value;
    } else {
        return dataType === flowComboboxDefaults.referenceDataType ? '{!' + value + '}' : value;
    }
}

const removeFormatting = (value) => {
    if (!value) {
        return value;
    }
    let isRef = isReference(value);
    let clearValue = isRef ? value.substring(0, value.lastIndexOf('}')).replace('{!', '') : value;
    return clearValue;
}

export {
    flowComboboxDefaults,
    isReference,
    formattedValue,
    getDataType,
    removeFormatting
};