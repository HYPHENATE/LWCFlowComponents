/**
 * @description       : javascript for the progress bar
 * @author            : daniel@hyphen8.com
 * @last modified on  : 12/07/2021
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   12/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api } from 'lwc';

export default class CustomProgressBar extends LightningElement {

    @api size;
    @api value;
    @api variant;

}