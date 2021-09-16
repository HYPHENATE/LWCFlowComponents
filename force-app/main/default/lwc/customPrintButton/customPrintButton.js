/**
 * @description       : js for custom print button
 * @author            : daniel@hyphen8.com
 * @last modified on  : 16/09/2021
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   19/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api } from 'lwc';

export default class CustomPrintButton extends LightningElement {

    @api buttonLabel;
    @api buttonAssistiveText;
    @api buttonFloat;

    handlePrintRequest(event){
        window.print();
    }
}