
var exec = require("cordova/exec");

var KoamTacScanner = function () {
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

/**
 * Enable sets up a bluetooth socket connection to the paired device.
 * Calls to trigger will fail unless the scanner has been 'enabled' first.
 * This will also tell the plugin to start listening for scan events from the scanner.
 *
 * @param onScan Callback function. Called with the scan result when a scan event occurs.
 * @param onError Called if there is a problem enabling the scanner plugin.
 * @param options Options to configure the plugin (optional - currently unused).
 */
KoamTacScanner.prototype.enable = function (onScan, onError, options) {
  options = options || {};
  exec(onScan, onError, 'KoamTacScanner', 'enable', [options]);
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

// exports
var plugin = new KoamTacScanner();
module.exports = plugin;

