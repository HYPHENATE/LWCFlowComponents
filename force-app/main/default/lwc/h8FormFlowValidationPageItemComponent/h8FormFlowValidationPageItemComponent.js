/**
 * @description       : js to support displaying pages and error fields
 * @author            : daniel@hyphen8.com
 * @last modified on  : 02/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class H8FormFlowValidationPageItemComponent extends LightningElement {

    @api page;

    get displayPage(){
        return this.page.pageName != 'NOPAGESCONFIGURED';
    }
}