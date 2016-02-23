var KoamTacScanner = {
  enable: function(successCallback, errorCallback, onScan) {
    // deprecated - older versions only passed the scan and error callbacks and
    // could not detect if the scanner didn't initialize properly
    var noOnScan = !onScan;
    if (noOnScan) { onScan = successCallback; }
    var handleCallback = function(results) {
      results = JSON.parse(results);
      if(results.status && noOnScan) {
        if (results.status === 'success') { successCallback(); }
      } else if (results.status) {
        successCallback(results.status);
      } else if (results.scan) {
        onScan(results.scan);
      }
    }
    cordova.exec(handleCallback,errorCallback,'KoamTacScanner','enable',[]);
  },

  disable: function(successCallback, errorCallback) {
    var handleCallback = function(results) {
      console.log(results);
      results = JSON.parse(results);
      successCallback(results.status);
    }
    cordova.exec(handleCallback,errorCallback,'KoamTacScanner','disable',[]);
  }
}

module.exports = KoamTacScanner;
