# Cordova Plugin for [KoamTac](http://www.koamtac.com) Scanners

	var scanner = cordova.require('cordova/plugin/KoamTacScanner');

#### enable

	scanner.enable = function (onScan, onError, [options]);

Starts the [BluetoothSocket](http://developer.android.com/reference/android/bluetooth/BluetoothSocket.html)
that allows two-way communication between the plugin and the scanner. Options are currently unused.

#### disable

	scanner.disable = function (onSuccess, onError);

Stops the [BluetoothSocket](http://developer.android.com/reference/android/bluetooth/BluetoothSocket.html)
that allows two-way communication between the plugin and the scanner.

## Notes

#### NFC

Currently the plugin only reads the UID from NFC tags.  In the future, maybe we will pop up a modal to let the user select a single record to be treated as scan data.

## Error Handling

#### No KoamTac scanner paired

For all of the above functions, a simple check is made to see if any Bluetooth devices are paired that have a name starting with 'KDC'.
If none are found, `onError` is called with a message that prompts the user to pair a KoamTac scanner.

#### Bluetooth is not switched on

If bluetooth is not switched on, the plugin will:

- provide a native dialog allowing the user to enable bluetooth without leaving the app
- call `onError` with a message stating that the function could not occur because bluetooth was not switched on

If the user switched bluetooth on through the dialog then the plugin, knowing the users intent to perform a scan,
will try to enable the scanner and subsequent calls from the scanner should succeed.
If the user elects to not switch bluetooth on through the dialog then a message will be sent to `onError`.

#### Scanner is not 'enabled'

If bluetooth is switched on, and the KoamTac scanner is paired, but the scanner has not been enabled then
a call to `enable` will attempt to enable to scanner and open or re-connect a connection to the KDC.

If this attempt succeeds, then all subsequent scans will result in a call to `onScan` with the value from the scanner.

If this attempt fails then a failure message will be passed to `onError` prompting the user to enable the scanner.
