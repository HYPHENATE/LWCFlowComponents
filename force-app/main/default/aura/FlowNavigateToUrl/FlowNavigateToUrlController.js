({
    invoke : function(component, event, helper) {
        var url = component.get("v.url");
        var openInNewWindow = component.get("v.openInNewWindow");

        if (url) {
            if (openInNewWindow) {
                window.open(url, "_blank");
            } else {
                var redirect = $A.get("e.force:navigateToURL");
                redirect.setParams({
                    "url": url
                });
                redirect.fire();
            }
        } else {
            console.error("No URL provided to navigate to.");
        }
    }
})