# customAddressComponent

## Description

js for custom address component

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Address Component

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| addressLookupLabel |  |
| addressLookupPlaceholder |  |
| addressLabel |  |
| streetLabel |  |
| cityLabel |  |
| countryLabel |  |
| provinceLabel |  |
| postalCodeLabel |  |
| streetValue | '' |
| cityValue | '' |
| countryValue | '' |
| provinceValue | '' |
| postalCodeValue | '' |
| fieldLevelHelp |  |
| readOnly | false |
| required | false |
| showAddressLookup | false |
| showCompactAddress | false |
| variant | 'standard' |

## Public API Methods

| Method | Parameters |
| --- | --- |
| validate |  |

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | addressLookupLabel | Address Lookup Label | String | inputOnly |  | The label for the address lookup field option. Only visible when show-address-lookup is set to true and label string is passed |
| lightning__FlowScreen | addressLookupPlaceholder | Address Lookup Placeholder | String | inputOnly |  | The placeholder for the address lookup field option. Visible only when using show-address-lookup. |
| lightning__FlowScreen | addressLabel | Address Label | String | inputOnly |  | The label for the address compound field. |
| lightning__FlowScreen | streetLabel | Street Label | String | inputOnly |  | The label for the street field. |
| lightning__FlowScreen | cityLabel | City Label | String | inputOnly |  | The label for the city field. |
| lightning__FlowScreen | countryLabel | Country Label | String | inputOnly |  | The label for the country field. |
| lightning__FlowScreen | provinceLabel | Province/State/County Label | String | inputOnly |  | The label for the province/state/county field. |
| lightning__FlowScreen | postalCodeLabel | Postcode Label | String | inputOnly |  | The label for the postal code field. |
| lightning__FlowScreen | streetValue | Street Value | String |  |  | The value for the street field. Maximum length is 255 characters when rendered as a textarea. |
| lightning__FlowScreen | cityValue | City Value | String |  |  | The value for the city field. Maximum length is 40 characters. |
| lightning__FlowScreen | countryValue | Country Value | String |  |  | The country field for the address. Maximum length is 80 characters. |
| lightning__FlowScreen | provinceValue | Province/State/County Value | String |  |  | The province/state/county field for the address. Maximum length is 80 characters. |
| lightning__FlowScreen | postalCodeValue | Postcode Value | String |  |  | The value for postal code field. Maximum length is 20 characters. |
| lightning__FlowScreen | fieldLevelHelp | Field Level Help | String | inputOnly |  | Help text detailing the purpose and function of the input. |
| lightning__FlowScreen | readOnly | Read Only | Boolean | inputOnly | false | If present, the address fields are read-only and cannot be edited. |
| lightning__FlowScreen | required | Required | Boolean | inputOnly | false | If present, the address fields must be filled before the form is submitted. |
| lightning__FlowScreen | showAddressLookup | Show Address Lookup | Boolean | inputOnly | false | If present, an address lookup field using Google Maps is displayed. |
| lightning__FlowScreen | variant | Variant | String | inputOnly |  | The variant changes the appearance of an input address field. Accepted variants include standard, label-hidden, label-inline, and label-stacked. |

## Bundle Files

- `customAddressComponent.html`
- `customAddressComponent.js`
- `customAddressComponent.js-meta.xml`
- `customAddressComponent.svg`
