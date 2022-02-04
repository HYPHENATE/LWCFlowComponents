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
                    this.buttonList.push(button);
            }, this);
        }
        catch (error)
        {
            console.log(error);
        }
    }

    handleClick(event)
    {
        this.outputValue = event.target.value;
        //Skipping a check on if next is available, the LWC is designed for it's output
        //to be used by a following flow element
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

}