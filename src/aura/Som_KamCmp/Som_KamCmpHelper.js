({
    getParamByName : function(param) {
        var vars = {};
        window.location.href.replace( location.hash, '' ).replace( /[?&]+([^=&]+)=?([^&]*)?/gi, // regexp
            function( m, key, value ) { // callback
                vars[key] = value !== undefined ? value : '';
            }
        );

        if ( param ) {
            return vars[param] ? vars[param] : null;
        }
        return vars;
    },

    callToast : function(component, event, helper){
        var type = event.getParam("type"),
        msg = event.getParam("msg");
        component.find("toastr").callToast(type, msg);
    }

    /*** Does not work with Locker-Service ***
    initToastr : function(){
        toastr.options = {
            "closeButton": true,
            "debug": false,
            "newestOnTop": false,
            "progressBar": true,
            "positionClass": "toast-bottom-right",
            "preventDuplicates": false,
            "onclick": null,
            "showDuration": "300",
            "hideDuration": "1000",
            "timeOut": "4000",
            "extendedTimeOut": "1000",
            "showEasing": "swing",
            "hideEasing": "linear",
            "showMethod": "fadeIn",
            "hideMethod": "fadeOut"
        };
    }*/
})