var ERRORS = {
  CONNECTION_ERROR: {code: 1, message: "KoamTac is Not Connected"},
  PARSE_ERROR: {code: 2, message: "Result parse error"},
};
var KoamTacScanner = {
  enable: function(successCallback, errorCallback, onScan) {
    // deprecated - older versions only passed the scan and error callbacks and
    // could not detect if the scanner didn't initialize properly
    var noOnScan = !onScan;
    if (noOnScan) { onScan = successCallback; }

    var handleCallback = function(results) {
      try {
        results = JSON.parse(results);
      } catch(e) {
        errorCallback(ERRORS.PARSE_ERROR);
      }

      if(results.status && noOnScan) {
        if (results.status === 'success' || results.status === 'CONNECTED') {
          successCallback();
        }
      } else if (results.status) {
        switch(results.status) {
          case "CONNECTING":
            break; // do nothing because either success or fail will follow

          case "CONNECTED":
          case "success":
            successCallback(results.status);
            break;

          default:
            errorCallback(ERRORS.CONNECTION_ERROR);
        }
      }
      else if (results.scan) {
        onScan(results.scan);
      }
    }

    cordova.exec(handleCallback,errorCallback,'KoamTacScanner','enable',[]);
  },

  disable: function(successCallback, errorCallback) {
    var handleCallback = function(results) {
      try {
        results = JSON.parse(results);
      } catch(e) {
        errorCallback(ERRORS.PARSE_ERROR);
      }
      successCallback(results.status);
    }

    cordova.exec(handleCallback,errorCallback,'KoamTacScanner','disable',[]);
  }
}

module.exports = KoamTacScanner;
