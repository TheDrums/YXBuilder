var pluginMD5 = new Object();

pluginMD5.encrypt = function(argc, successCallback){
    WebViewJavascriptBridge.callHandler('pluginMD5.encrypt', [argc], function(response) {
        successCallback(response);
    });
};
