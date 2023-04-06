/**
 * @description       : js for supporting a custom button in a flow
 * @author            : daniel@hyphen8.com
 * @last modified on  : 06-04-2023
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import { FlowNavigationNextEvent, FlowNavigationBackEvent, FlowNavigationFinishEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class CustomFlowNavigationButton extends LightningElement {

    @api buttonLabel;
    @api variant;
    @api flowAction;
    @api position;
    @api buttonPressed = false;
    @api stetchButton = false;


    // get function to render the correct CSS class on a button
    get buttonCSSClass() {
        if(this.position == 'LEFT'){
            return 'floatLeft';
        } else if (this.position == 'RIGHT'){
            return 'floatRight';
        }
    }


    // on click that will set the value to support with where you want to navigate to
    handleNavigation(event){
        this.buttonPressed = true;
        const attributeChangeEvent = new FlowAttributeChangeEvent('buttonPressed',this.buttonPressed);
        this.dispatchEvent(attributeChangeEvent);
        this.performNavigation(event);
    }

    // function that performs the actual navigation
    performNavigation(event){
        if(this.flowAction == 'NEXT'){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else if(this.flowAction == 'PREVIOUS'){
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        } else if(this.flowAction == 'FINISH'){
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }
}