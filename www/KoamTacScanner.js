//exports.coolMethod = function(arg0, success, error) {
//    exec(success, error, "KoamTacScanner", "coolMethod", [arg0]);
//};

var KoamTacScanner = {
  enable: function(successCallback, errorCallback, onScan) {
    var handleCallback = function(results) {
      console.log(results);
      results = JSON.parse(results);
      if(results.status) {
        successCallback(results.status);
      }
      else if (results.scan) {
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
