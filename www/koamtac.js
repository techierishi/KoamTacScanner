
var exec = require("cordova/exec");

var KoamTacScanner = function () {
};

/**
 * Enable sets up a bluetooth socket connection to the paired device.
 * Calls to trigger will fail unless the scanner has been 'enabled' first.
 * This will also tell the plugin to start listening for scan events from the scanner.
 *
 * @param onSuccess Callback function. Called with scanner is initialized
 * @param onError Called if there is a problem enabling the scanner plugin.
 * @param onScan Callback function. Called with the scan result when a scan event occurs.
 */
KoamTacScanner.prototype.enable = function (onSuccess, onError, onScan) {
  // deprecated - older versions only passed the scan and error callbacks and
  // could not detect if the scanner didn't initialize properly
  if(!onScan) {
    onScan = onSuccess;
  }
  var handleCallback = function(results) {
    results = JSON.parse(results);
    if(results.status === 'success') {
      onSuccess();
    }
    else if(results.scan) {
      onScan(results.scan);
    }
  }
  exec(handleCallback, onError, 'KoamTacScanner', 'enable', []);
};

/**
 * Disables the plugin. No scanning will be possible until a subsequent
 * call to disable is made.
 *
 * @param onSuccess Called if the plugin is successfully disabled.
 * @param onError Called if there is a problem disabling the scanner plugin.
 */
KoamTacScanner.prototype.disable = function (onSuccess, onError) {
  exec(onSuccess, onError, 'KoamTacScanner', 'disable', []);
};

/**
 * Triggers the scanner to scan.
 *
 * @param onScan Callback function. Called with the scan result when a scan event occurs.
 * @param onError Called if the scanner cannot scan (possible due to enable() not having been called).
 */
KoamTacScanner.prototype.trigger = function (onScan, onError) {
  exec(onScan, onError, 'KoamTacScanner', 'trigger', []);
};

// exports
var plugin = new KoamTacScanner();
module.exports = plugin;
