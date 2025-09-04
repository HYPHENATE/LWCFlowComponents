/**
 * @description       : js for custom address component
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03-09-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class CustomAddressComponent extends LightningElement {
    
    @api addressLookupLabel;
    @api addressLookupPlaceholder;
    @api addressLabel;
    @api streetLabel;
    @api cityLabel;
    @api countryLabel;
    @api provinceLabel;
    @api postalCodeLabel;

    @api streetValue = '';
    @api cityValue = '';
    @api countryValue = '';
    @api provinceValue = '';
    @api postalCodeValue = '';

    @api fieldLevelHelp;
    @api readOnly = false;
    @api required = false;
    @api showAddressLookup = false;
    @api showCompactAddress = false;
    @api variant = 'standard';

    handleChange(event) {
        const { street, subpremise, city, country, province, postalCode } = event.detail || {};
        this.streetValue = street;
        this.cityValue = city;
        this.countryValue = country;
        this.provinceValue = province;
        this.postalCodeValue = postalCode;
    }

    @api
    validate() {
        if (this.readOnly || !this.required) {
            return { isValid: true };
        }

        const addr = this.template.querySelector('lightning-input-address');
        console.log('Validating address component', addr);

        ['street','city','postalCode'].forEach(f => addr.setCustomValidityForField('', f));

        const missing = [];
        if (!this.streetValue?.trim()) { 
            addr.setCustomValidityForField('This field is required.', 'street');
            missing.push('street');
        }
        if (!this.cityValue?.trim()) { 
            addr.setCustomValidityForField('This field is required.', 'city');
            missing.push('city');
        }
        if (!this.postalCodeValue?.trim()) { 
            addr.setCustomValidityForField('This field is required.', 'postalCode');
            missing.push('postal code');
        }

        addr.reportValidity();
        return {
            isValid: missing.length === 0,
            errorMessage: missing.length ? `Please complete: ${missing.join(', ')}.` : ''
        };
    }
}