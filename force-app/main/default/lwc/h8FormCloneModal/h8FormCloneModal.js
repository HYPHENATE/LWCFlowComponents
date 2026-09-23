import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import modalTitle from '@salesforce/label/c.H8FormCloneModalTitle';
import closeButtonLabel from '@salesforce/label/c.H8FormCloneModalCloseButtonLabel';

export default class H8FormCloneModal extends LightningModal {
    @api initialSourceDeveloperName;

    labels = {
        modalTitle,
        closeButtonLabel
    };

    handleClose() {
        this.close();
    }
}
