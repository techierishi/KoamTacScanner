cordova.define("cordova/plugin/koamtac/KDC200Scanner",

  function (require, exports, module) {

    var exec = require("cordova/exec");

    var KDC200Scanner = function () {
    };

    /**
     * Triggers the scanner to scan.
     *
     * @param onScan Callback function. Called with the scan result when a scan event occurs.
     * @param onError Called if the scanner cannot scan (possible due to enable() not having been called).
     */
    KDC200Scanner.prototype.trigger = function (onScan, onError) {
      exec(onScan, onError, 'koamtac/KDC200Scanner', 'trigger', []);
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
    KDC200Scanner.prototype.enable = function (onScan, onError, options) {
      options = options || {};
      exec(onScan, onError, 'koamtac/KDC200Scanner', 'enable', [options]);
    };

    /**
     * Disables the plugin. No scanning will be possible until a subsequent
     * call to disable is made.
     *
     * @param onSuccess Called if the plugin is successfully disabled.
     * @param onError Called if there is a problem disabling the scanner plugin.
     */
    KDC200Scanner.prototype.disable = function (onSuccess, onError) {
      exec(onSuccess, onError, 'koamtac/KDC200Scanner', 'disable', []);
    };

    // Define other KoamTac scanners here...

    // exports
    var plugin = new KDC200Scanner();
    module.exports = plugin;
  });
