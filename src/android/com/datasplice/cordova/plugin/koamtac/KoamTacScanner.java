package com.datasplice.cordova.plugin.koamtac;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import com.koamtac.BluetoothChatService;
import com.koamtac.KScan;
import com.koamtac.KTSyncData;
import org.apache.cordova.*;

import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;
import org.json.JSONObject;

import java.util.Set;


/**
 * Cordova plugin for <a href="koamtac.com">KoamTac Bluetooth scanners</a>
 *
 * @see <a href="http://cordova.apache.org/docs/en/3.1.0/guide_platforms_android_plugin.md.html#Android%20Plugins">Android Plugins</a>
 */
public class KoamTacScanner extends CordovaPlugin {

    private static final String TAG = KoamTacScanner.class.getCanonicalName();

    // Commands sent from the web app
    private static final String CMD_ENABLE = "enable";
    private static final String CMD_DISABLE = "disable";
    private static final String CMD_TRIGGER = "trigger";

    private static final int REQUEST_CODE_ENABLE_BT = 1775;
    private static final String KOAMTAC_DEVICE_NAME_PREFIX = "KDC";

    private byte[] displayBuf = new byte[256];
    private String displayMessage;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothDevice connectedDevice;
    private CallbackContext callbackContext;

    /**
     * This logic comes directly from the KoamTac KTDemo class. It's merely reproduced here without changes.
     */
    private void initializeKTSyncData() {
        KTSyncData.mKScan = new KScan(cordova.getActivity(), messageHandler);
        KTSyncData.BufferRead = 0;
        KTSyncData.BufferWrite = 0;
        for (int i = 0; i < 10; i++) {
            KTSyncData.SerialNumber[i] = '0';
            KTSyncData.FWVersion[i] = '0';
        }
        GetPreferences();
        KTSyncData.bIsRunning = true;
        KTSyncData.bIsOver_233 = false;
        StringBuffer buf = new StringBuffer();
        buf.append(Build.VERSION.RELEASE);
        String version = buf.toString();
        String target = "2.3.3";
        if ( version.compareTo(target) > 0 ) {
            KTSyncData.bIsOver_233 = true;
        }
    }

    /**
     *
     * @param cordova
     * @param webView
     */
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        // Get local Bluetooth adapter
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        // If the adapter is null, then Bluetooth is not supported
        if (mBluetoothAdapter == null) {
            // This is an unlikely scenario
            return;
        }

        // Do the KTSyncData-specific initialization
        initializeKTSyncData();
    }


    /**
     * Called from Cordova
     *
     *
     */
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        Log.i(TAG, "Running action: " + action);
        this.callbackContext = callbackContext;

        if (CMD_TRIGGER.equals(action)) {
            trigger();
            return true;
        }
        if (CMD_ENABLE.equals(action)) {
            final JSONObject options = args.getJSONObject(0);
            enable(options);
            return true;
        }
        if (CMD_DISABLE.equals(action)) {
            disable();
            return true;
        }

        return false;
    }

    /**
     * Sends a command to the scanner to perform an actual scan.
     */
    private void trigger() {
        if (KTSyncData.mChatService != null && KTSyncData.mChatService.isConnected()) {
            KTSyncData.mKScan.ScanBarcode();
        } else {
            sendPluginResult(PluginResult.Status.ERROR, "Not connected to scanner. Attempting to connect now...", true);

            // Now we know the users intention, go ahead and connect to the device
            checkBluetoothAndConnectToRemoteDevice();
        }
    }

    /**
     * Kills all BluetoothChatService threads.
     */
    private void disable() {
        Log.d(TAG, "disable()");
        try {
            if (KTSyncData.mChatService != null) {
                KTSyncData.mChatService.stop();
            }
            KTSyncData.mChatService = null;
            KTSyncData.bIsRunning = false;
            sendPluginResult(PluginResult.Status.OK, "Plugin is now disabled.");
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            sendPluginResult(PluginResult.Status.ERROR, "Unable to disable: " + e.getMessage());
        }
    }

    /**
     * Connects to a paired scanner and starts listening for scan events.
     */
    private void enable(JSONObject options) {
        Log.d(TAG, "enable()");
        try {

            if (KTSyncData.mChatService != null) {
                // Only if the state is STATE_NONE, do we know that we haven't started already
                if (KTSyncData.mChatService.getState() == BluetoothChatService.STATE_NONE) {
                    // Start the Bluetooth chat services
                    KTSyncData.mChatService.start(); // Here we start the two-way communication to the connected scanner
                    KTSyncData.bIsBackground = false;
                    KTSyncData.mKScan.mHandler = messageHandler;
                }
            } else {
                checkBluetoothAndConnectToRemoteDevice();
            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            sendPluginResult(PluginResult.Status.ERROR, "Unable to enable: " + e.getMessage());
        }
    }

    /**
     * TODO: extract interface or otherwise make this logic pluggable.
     *
     * This class simply finds the first bonded BT device with a
     * name starting with KOAMTAC_DEVICE_NAME_PREFIX.
     */
    private class DefaultKoamTacDeviceSelector {
        public String deviceAddress() {
            Set<BluetoothDevice> bondedDevices = mBluetoothAdapter.getBondedDevices();
            for (BluetoothDevice device : bondedDevices) {
                if (device.getName().startsWith(KOAMTAC_DEVICE_NAME_PREFIX)) {
                    return device.getAddress();
                }
            }
            return null;
        }
    }

    /**
     * Convenience method, sends plugin result without keeping hold of the callback.
     * @param status
     * @param scannerMessage
     */
    private void sendPluginResult(final PluginResult.Status status, final String scannerMessage) {
        sendPluginResult(status, scannerMessage, false);
    }

    /**
     * This method performs the "push" of scanner data back to the app.
     * Note the use of pluginResult.setKeepCallback(true); This is what enables the callback to be persistent.
     * @param scannerMessage
     */
    private void sendPluginResult(final PluginResult.Status status, final String scannerMessage, final boolean keepCallback) {
        Log.d(TAG, "sendPluginResult(\"" + scannerMessage + "\")");
        PluginResult pluginResult = new PluginResult(status, scannerMessage);
        pluginResult.setKeepCallback(keepCallback);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void handleEnableBluetooth(final int resultCode, final Intent intent) {
        switch(resultCode) {
            case Activity.RESULT_OK:
                connectToRemoteDevice();
                break;
            default:
                final String msg = "Attempt to enable Bluetooth failed or was cancelled.";
                Log.i(TAG, msg);
                sendPluginResult(PluginResult.Status.ERROR, msg);
                break;
        }
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        switch(requestCode) {
            case REQUEST_CODE_ENABLE_BT:
                handleEnableBluetooth(resultCode, intent);
                break;
            default:
                // This should not happen
                Log.e(TAG, "Unknown request code '" + requestCode + "' for onActivityResult.");
                break;
        }
    }


    /**
     * NOTE: The Koamtac 'demo' app obtains preferences from android preferences screen.
     * Since we're trying to be unobtrusive, we'll just use the defaults instead of
     * pulling these values from the android shared preferences.
     */
    public void GetPreferences()
    {
        byte[] temp;

        /* NOTE: Original Koamtac code
            SharedPreferences app_preferences = PreferenceManager.getDefaultSharedPreferences(this);
            KTSyncData.AutoConnect = app_preferences.getBoolean("Auto Connect", false);
            KTSyncData.AttachTimestamp = app_preferences.getBoolean("AttachTimeStamp", false);
            KTSyncData.AttachType = app_preferences.getBoolean("AttachBarcodeType", false);
            KTSyncData.AttachSerialNumber = app_preferences.getBoolean("AttachSerialNumber", false);
            temp = app_preferences.getString("Data Delimiter", "4").getBytes();
            KTSyncData.DataDelimiter = temp[0] - '0';
            temp = app_preferences.getString("Record Delimiter", "1").getBytes();
            KTSyncData.RecordDelimiter = temp[0] - '0';
            KTSyncData.AttachLocation = app_preferences.getBoolean("AttachLocationData", false);
            KTSyncData.SyncNonCompliant = app_preferences.getBoolean("SyncNonCompliant", false);
            KTSyncData.AttachQuantity = app_preferences.getBoolean("AttachQuantity", false);
        */

        KTSyncData.AutoConnect = false;
        KTSyncData.AttachTimestamp = false;
        KTSyncData.AttachType = false;
        KTSyncData.AttachSerialNumber = false;
        temp = "4".getBytes();
        KTSyncData.DataDelimiter = temp[0] - '0';
        temp = "1".getBytes();
        KTSyncData.RecordDelimiter = temp[0] - '0';
        KTSyncData.AttachLocation = false;
        KTSyncData.SyncNonCompliant = false;
        KTSyncData.AttachQuantity = false;
    }


    private Runnable mUpdateTimeTask = new Runnable() {
        public void run() {
            if ( KTSyncData.AutoConnect && KTSyncData.bIsRunning )
                KTSyncData.mChatService.connect(connectedDevice);
        }
    };

    /**
     * Logic for this handler came from the KTDemo.java file provided by KoamTac.
     */
    private final Handler messageHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (KTSyncData.mChatService == null) {
                return;
            }
            switch (msg.what) {
                case BluetoothChatService.MESSAGE_STATE_CHANGE:
                    Log.d(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
                    switch (msg.arg1) {
                        case BluetoothChatService.STATE_CONNECTED:
                            // NOTE: opportunity to send a pluginresult to the UI to update the name of the connected device
//                            mTitle.setText(R.string.title_connected_to);
//                            mTitle.append(connectedDevice.getName());
                            removeCallbacks(mUpdateTimeTask);
                            KTSyncData.mKScan.DeviceConnected(true);
                            break;
                        case BluetoothChatService.STATE_CONNECTING:
                            // NOTE: opportunity to send a pluginresult to the UI
//                            mTitle.setText(R.string.title_connecting);
                            break;
                        case BluetoothChatService.STATE_LISTEN:
                        case BluetoothChatService.STATE_NONE:
                            // NOTE: opportunity to send a pluginresult to the UI
//                            mTitle.setText(R.string.title_not_connected);
                            break;
                        case BluetoothChatService.STATE_LOST:
                            KTSyncData.bIsConnected = false;
                            // NOTE: opportunity to send a pluginresult to the UI
//                            mTitle.setText(R.string.title_not_connected);
                            teardownChat();
                            postDelayed(mUpdateTimeTask, 2000);
                            break;
                        case BluetoothChatService.STATE_FAILED:
                            // NOTE: opportunity to send a pluginresult to the UI
//                            mTitle.setText(R.string.title_not_connected);
                            postDelayed(mUpdateTimeTask, 5000);
                            break;
                    }
                    break;
                case BluetoothChatService.MESSAGE_READ:
                    byte[] readBuf = (byte[]) msg.obj;
                    for (int i = 0; i < msg.arg1; i++) {
                        KTSyncData.mKScan.HandleInputData(readBuf[i]);
                    }
                    break;
                case BluetoothChatService.MESSAGE_DISPLAY:
                    // construct a string from the valid bytes in the buffer
                    displayBuf = (byte[]) msg.obj;
                    displayMessage = new String(displayBuf, 0, msg.arg1);

                    /*
                        NOTE: here's where we finally send the scanner data back to the device.
                        Prior to MESSAGE_DISPLAY the case BluetoothService.MESSAGE_READ is called
                        multiple times to build the string from the data from the scanner.

                        We pass 'true' to sendPluginResult to allow re-use of the callbackContext
                        and the continual pushing of barcode data to the app.
                    */
                    sendPluginResult(PluginResult.Status.OK, displayMessage, true);
                    KTSyncData.bIsSyncFinished = true;
                    break;
                case BluetoothChatService.MESSAGE_SEND:
                    byte[] sendBuf = (byte[]) msg.obj;
                    KTSyncData.mChatService.write(sendBuf);
                    break;
            }
        }
    };

    private void connectToRemoteDevice() {
        Log.d(TAG, "connectToRemoteDevice()");
        // Initialize the BluetoothChatService to perform bluetooth connections
        final String deviceAddress = new DefaultKoamTacDeviceSelector().deviceAddress();
        if (deviceAddress == null) {
            sendPluginResult(PluginResult.Status.ERROR, "KoamTac scanner not found. Please enable bluetooth and pair the scanner.");
        } else {
            try {
                this.connectedDevice = mBluetoothAdapter.getRemoteDevice(deviceAddress);
                KTSyncData.mChatService = new BluetoothChatService(cordova.getActivity(), messageHandler);
                KTSyncData.mChatService.connect(connectedDevice);
            } catch(Exception e) {
                e.printStackTrace();
                Log.e(TAG, e.getMessage());
                sendPluginResult(PluginResult.Status.ERROR, "Unable to connect to KoamTac scanner with Mac address: " + deviceAddress);
            }
        }
    }

    private void checkBluetoothAndConnectToRemoteDevice() {
        Log.d(TAG, "checkBluetoothAndConnectToRemoteDevice()");
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            cordova.startActivityForResult(this, enableIntent, REQUEST_CODE_ENABLE_BT);
        } else {
            // Otherwise, setup the chat session
            if (KTSyncData.mChatService == null) connectToRemoteDevice();
        }
    }

    private void teardownChat() {
        Log.d(TAG, "teardownChat()");
        // Stop the Bluetooth chat services
        if (KTSyncData.mChatService != null) KTSyncData.mChatService.stop();
        KTSyncData.mChatService = null;
        KTSyncData.bIsRunning = false;
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        Log.d(TAG, "onResume");
        checkBluetoothAndConnectToRemoteDevice();
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        Log.d(TAG, "onPause");
        teardownChat();
    }

    /**
     * Called when the WebView does a top-level navigation or refreshes.
     * Plugins should stop any long-running processes and clean up internal state.
     */
    @Override
    public void onReset() {
        super.onReset();
        Log.d(TAG, "onReset");
        teardownChat();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        teardownChat();
    }
}