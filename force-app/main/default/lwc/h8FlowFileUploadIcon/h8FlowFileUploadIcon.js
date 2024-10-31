/**
 * @description       : js for file upload icon component
 * @author            : daniel@hyphen8.com
 * @last modified on  : 30/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class H8FlowFileUploadIcon extends LightningElement {
    @api fileExtension;

    get fileIcon(){
        switch(this.fileExtension){
            case 'csv':
                return 'doctype:csv';
            case 'pdf':
                return 'doctype:pdf';
            case 'ppt':
                return 'doctype:ppt';
            case 'pptx':
                return 'doctype:ppt';
            case 'xls':
                return 'doctype:excel';
            case 'xlsx':
                return 'doctype:excel';
            case 'doc':
                return 'doctype:word';
            case 'docx':
                return 'doctype:word';
            case 'txt':
                return 'doctype:txt';
            case 'png':
                return 'doctype:image';
            case 'jpeg':
                return 'doctype:image';
            case 'jpg':
                return 'doctype:image';
            case 'gif':
                return 'doctype:image';
            default:
                return 'doctype:unknown';
        }
    }
}