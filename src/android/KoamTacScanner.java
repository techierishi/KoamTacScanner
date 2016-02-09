package com.datasplice.cordova.plugin.koamtac;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.util.Log;

import org.apache.cordova.*;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.Override;

import koamtac.kdc.sdk.*;
import koamtac.kdc.sdk.KDCConstants;

/**
 * This class echoes a string called from JavaScript.
 */
public class KoamTacScanner extends CordovaPlugin implements
        KDCDataReceivedListener,
        KDCBarcodeDataReceivedListener,
        KDCGPSDataReceivedListener,
        KDCMSRDataReceivedListener,
        KDCNFCDataReceivedListener,
        KDCConnectionListener {

    KDCReader _kdcReader;
    CallbackContext _callbackContext;
    BluetoothAdapter mBluetoothAdapter;

    private static final String TAG = KoamTacScanner.class.getCanonicalName();

    private static enum CMD {
        enable, disable
    }


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        // If the adapter is null, then Bluetooth is not supported
        if (mBluetoothAdapter == null) {
            return;
        }

    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        _callbackContext = callbackContext;
        switch (CMD.valueOf(action)) {
            case enable:
                enable();
                return true;
            case disable:
                disconnect();
                return true;
        }
        return false;
    }

    // Process and send Generic data events from KDC
    @Override
    public void DataReceived( KDCData pData ) {
        String data = pData.GetData();
        Log.d(TAG, "Sending Generic Data " + data);
        sendScanData(data);
    }

    // Process and send Barcode data events from KDC
    @Override
    public void BarcodeDataReceived(KDCData pData) {
        String data = pData.GetData();
        Log.d(TAG, "Sending Barcode Data " + data);
        sendScanData(data);
    }

    // Process and send GPS data events from KDC
    @Override
    public void GPSDataReceived(KDCData pData) {
        String data = pData.GetData();
        Log.d(TAG, "Sending GPS Data " + data);
        sendScanData(data);
    }

    // Process and send Magnetic-Stripe-Reader data events from KDC
    @Override
    public void MSRDataReceived(KDCData pData) {
        String data = pData.GetData();
        Log.d(TAG, "Sending MSR Data " + data);
        sendScanData(data);
    }

    // Process and send Near-Field-Communication data events from KDC
    // Only get UID.  NFC Data can have many records, and is difficult to parse.
    // see http://www.kdc100.com/documents/manuals/How_To_Use_Your_KDC_with_NFC_or_RFID.pdf
    // maybe one day use Android NFC classes?
    @Override
    public void NFCDataReceived(KDCData pData) {
        String uid = pData.GetNFCUID();
        Log.d(TAG, "Sending NFC Data " + uid);
        sendScanData(uid);
    }

    // Handle Connection States of KDC Devices
    @Override
    public void ConnectionChanged( BluetoothDevice device, int state ) {
        switch (state) {
            case KDCConstants.CONNECTION_STATE_CONNECTED :
                sendResult(PluginResult.Status.OK, buildStatusMessage("CONNECTED"));
                break;
            case KDCConstants.CONNECTION_STATE_CONNECTING:
                sendResult(PluginResult.Status.OK, buildStatusMessage("CONNECTING"));
                break;
            case KDCConstants.CONNECTION_STATE_LOST:
                sendResult(PluginResult.Status.OK, buildStatusMessage("LOST"));
                break;
            case KDCConstants.CONNECTION_STATE_FAILED:
                sendResult(PluginResult.Status.OK, buildStatusMessage("FAILED"));
                break;
            case KDCConstants.CONNECTION_STATE_LISTEN:
                sendResult(PluginResult.Status.OK, buildStatusMessage("LISTEN"));
                break;
        }
    }

    private String buildStatusMessage(String message) {
        return "{\"status\":\""+message+"\"}";
    }

    // Send result
    private void sendResult(PluginResult pluginResult) {
        pluginResult.setKeepCallback(true);
        _callbackContext.sendPluginResult(pluginResult);
    }

    // Build PluginResult and send result
    private void sendResult(PluginResult.Status status, String message) {
        PluginResult pluginResult = new PluginResult(status, message);
        sendResult(pluginResult);
    }

    // Builds scan message and pluginResult. Sends pluginResult
    private void sendScanData(String data) {
        String scanMessage = "{\"scan\":\""+data+"\"}";
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, scanMessage);
        sendResult(pluginResult);
    }

    // Enable KDC
    private void enable() {
        checkAndConnect();
        _kdcReader.SetNFCDataFormat(KDCConstants.NFCDataFormat.PACKET_FORMAT);
        _kdcReader.EnableNFCUIDOnly(true);
    }

    // Check Bluetooth and Connect to existing device or first available device
    private void checkAndConnect() {
        if(!mBluetoothAdapter.isEnabled()) {
            Log.d(TAG, "Bluetooth Adapter disabled.  Prompting to enable");
            // bluetooth not enabled.  prompt user to enable it
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            cordova.startActivityForResult(this, enableIntent, 1775); // 1775 = REQUEST_CODE_ENABLE_BT;
        } else if (_kdcReader == null) {
            Log.d(TAG, "Attempting to connect to first available KDC");
            // bluetooth OK, connect to first available device.
            _kdcReader = new KDCReader(null, this, this, this, this, this, this, false);
        } else if (!_kdcReader.IsConnected()) {
            Log.d(TAG, "Attempting to re-connect existing KDC");
            // reconnect to existing device
            _kdcReader = new KDCReader(this, this, this, this, this, this, false);
        } else {
            Log.d(TAG, "Using existing connected KDC");
        }
    }

    // Disconnect KDC device from application
    private void disconnect() {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "DISCONNECTED");
        if (_kdcReader != null) {
            _kdcReader.Disconnect();
            // clean up the kdcReader, we'll create new if necessary
            _kdcReader = null;
            _callbackContext.sendPluginResult(pluginResult);
        }
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        Log.d(TAG, "onResume");
        checkAndConnect();
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        Log.d(TAG, "onPause");
        // we really don't need to do anything here
    }

    /**
     * Called when the WebView does a top-level navigation or refreshes.
     * Plugins should stop any long-running processes and clean up internal state.
     */
    @Override
    public void onReset() {
        super.onReset();
        Log.d(TAG, "onReset");
        disconnect();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        disconnect();
    }
}