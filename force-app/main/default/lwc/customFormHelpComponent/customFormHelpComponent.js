import { LightningElement, api } from 'lwc';

import closeLabel from '@salesforce/label/c.H8CFHCloseModalLabel';

export default class CustomFormHelpComponent extends LightningElement {
    @api helpLinkText;
    @api helpMessage;
    @api useModal = false;
    @api fontSize;
    closeLabel = closeLabel;

    showModal = false;
    showHelp = false;

    onclick(event){
        if(this.useModal){
            this.showModal = !this.showModal ;
        } else {
            this.showHelp = !this.showHelp ;
        }
    }

    closeHelp(event){
        this.showModal = false;
        this.showHelp = false;
    }
}