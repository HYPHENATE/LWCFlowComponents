import { LightningElement, api } from 'lwc';

import { FlowNavigationNextEvent } from 'lightning/flowSupport';


export default class FlowNavigationButtons extends LightningElement
{
    @api inputList;
    @api outputValue;
    @api numberOfColumns;
    columnClass = "slds-col slds-size_1-of-2";
    buttonList = [];
    
    connectedCallback()
    {
        this.columnClass = "slds-col slds-size_1-of-"+this.numberOfColumns.toString();
        // Leaving in the try/catch. Will allow admins to see logs for any errors that occur
        // when parsing the JSON and creating the buttons
        try
        {
            let inputButtonList = JSON.parse(this.inputList);
            inputButtonList.forEach(function(button)
            {
                // Passing a function to the button object, which is then referenced by the HTML button
                // This is done because standard HTML buttons don't seem to properly pass values in event.detail
                button.onclick = function(){this.handleClick(button.value)};
                this.buttonList.push(button);
            }, this)
        }
        catch (error)
        {
            console.log(error);
        }
    }

    handleClick(outputValue)
    {
        // Skipping a check on if next is available, the LWC is designed for it's output
        // to be used by a following flow element
        this.outputValue = outputValue;
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

}
