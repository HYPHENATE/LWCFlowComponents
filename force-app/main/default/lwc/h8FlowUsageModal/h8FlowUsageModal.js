import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import labels from './labels';

export default class H8FlowUsageModal extends LightningModal {
    @api flowApiName;

    labels = labels;

    handleClose() {
        this.close();
    }
}
