/**
 * @description       : js for individual item
 * @author            : daniel@hyphen8.com
 * @last modified on  : 20-05-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class H8FlowFormRenderItem extends LightningElement {
    @api section;
    @api activeSection;

    // getter to set the active section css for li
    get sectionCSS(){
        if(this.activeSection == this.section.id){
            return 'slds-vertical-tabs__nav-item slds-is-active';
        } else {
            return 'slds-vertical-tabs__nav-item';
        }
    }

    get ariaSelected(){
        if(this.activeSection == this.section.id){
            return true;
        } else {
            return false;
        }
    }

    handleOnSectionKeyDown(event){
        const key = event.key || event.keyCode;
        if (key === 'Enter' || key === 13 || key === ' ') {
            this.handleOnSectionSelection(event);
        }
    }

    // onclick function to tell the parent component that the user wants to view that section
    handleOnSectionSelection(event){
        event.preventDefault();
        this.dispatchEventFunction('sectionselected', {detail: {sectionId: this.section.id, flowName: this.section.flow}});
    }

    // generic dispatch event function
    dispatchEventFunction(eventName, eventDetail) {
       this.dispatchEvent(new CustomEvent(eventName, eventDetail ));
    }
}