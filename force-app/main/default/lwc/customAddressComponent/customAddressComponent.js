/**
 * @description       : js for custom address component
 * @author            : daniel@hyphen8.com
 * @last modified on  : 19-08-2025
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

    emit(name, value) {
        this.dispatchEvent(new FlowAttributeChangeEvent(name, value));
    }

    handleChange(event) {
        const { street, city, country, province, postalCode } = event.detail || {};
        console.log('Address change event received', event.detail);
        if (street !== undefined)  { this.streetValue = street;       this.emit('streetValue', this.streetValue); }
        if (city !== undefined)    { this.cityValue = city;           this.emit('cityValue', this.cityValue); }
        if (country !== undefined) { this.countryValue = country;     this.emit('countryValue', this.countryValue); }
        if (province !== undefined){ this.provinceValue = province;   this.emit('provinceValue', this.provinceValue); }
        if (postalCode !== undefined){ this.postalCodeValue = postalCode; this.emit('postalCodeValue', this.postalCodeValue); }
        console.log('Updated values:', {
            street: this.streetValue,
            city: this.cityValue,
            country: this.countryValue,
            province: this.provinceValue,
            postalCode: this.postalCodeValue
        });
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
        if (!this.streetValue?.trim())     { addr.setCustomValidityForField('This field is required.', 'street');      missing.push('street'); }
        if (!this.cityValue?.trim())       { addr.setCustomValidityForField('This field is required.', 'city');        missing.push('city'); }
        if (!this.postalCodeValue?.trim()) { addr.setCustomValidityForField('This field is required.', 'postalCode');  missing.push('postal code'); }

        addr.reportValidity();
        return {
            isValid: missing.length === 0,
            errorMessage: missing.length ? `Please complete: ${missing.join(', ')}.` : ''
        };
    }
}