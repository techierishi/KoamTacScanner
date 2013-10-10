package com.datasplice.cordova.plugin.koamtac;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;


/**
 * Cordova plugin for the <a href="koamtac.com/kdc200.html">KoamTac KDC200 Bluetooth Scanner</a>
 *
 * @see http://cordova.apache.org/docs/en/3.0.0/guide_platforms_android_plugin.md.html#Android%20Plugins
 */
public class KDC200Scanner extends CordovaPlugin {

    private static final String TAG = KDC200Scanner.class.getCanonicalName();
    private static final String SCAN = "scan";
    private static final String ERR_NO_SCAN_RESULT = "No scan result found";

    private CallbackContext callbackContext;

    /**
     *
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.i(TAG, "Running action: " + action);
        this.callbackContext = callbackContext;

        if (SCAN.equals(action)) {
            String scanResult = scan();
            if (scanResult != null && scanResult.trim().length() > 0) {
                callbackContext.success(scanResult);
            } else {
                callbackContext.error(ERR_NO_SCAN_RESULT);
            }
            return true;
        }
        return false;
    }

    /**
     * Actual method call invoked from the javascript app.
     */
    private String scan(final String message) {
        Log.i(TAG, "Calling KDC200Scanner.scan()");

        // TODO
        return "THIS SHOULD HAVE COME FROM THE SCANNER";
    }

}