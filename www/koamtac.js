cordova.define("cordova/plugin/koamtac/KDC200Scanner",

  function (require, exports, module) {

    var exec = require("cordova/exec");

    function KDC200Scanner() {
    };

    KDC200Scanner.prototype.scan = function(onSuccess, onError) {
      exec(onSuccess, onError, 'KDC200Scanner', 'scan', [] );
    };

    // exports
    var plugin = new KDC200Scanner();
    module.exports = plugin;
  });

// Define other KoamTac scanners here...

