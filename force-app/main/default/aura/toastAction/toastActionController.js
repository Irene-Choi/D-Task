({
    invoke : function(component, event, helper) {
        
        var title = component.get("v.title");
        var message = component.get("v.message");
        var variant = component.get("v.variant");

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": variant, 
            "mode": "dismissible"
        });
        toastEvent.fire();
    }
})