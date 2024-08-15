/**
 * @description       : controller to help in a flow navigate to a new record when created
 * @author            : daniel@hyphen8.com
 * @last modified on  : 01/02/2024
 * @last modified by  : daniel@hyphen8.com
**/
({
    invoke : function(component, event, helper) {
        // Get the record ID attribute
        var record = component.get("v.recordId");
        
        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get("e.force:navigateToSObject");
        
        // Pass the record ID to the event
        redirect.setParams({
            "recordId": record
        });
            
        // Open the record
        redirect.fire();
    }
})