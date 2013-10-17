# Cordova Plugin for [KoamTac](http://www.koamtac.com) Scanners

	var scanner = cordova.require('cordova/plugin/koamtac/KoamTacScanner');

#### enable

	scanner.enable = function (onScan, onError, [options]);

Starts the [BluetoothSocket](http://developer.android.com/reference/android/bluetooth/BluetoothSocket.html)
that allows two-way communication between the plugin and the scanner. Options are currently unused.

#### trigger

	scanner.trigger = function (onScan, onError);

Triggers the scanner to perform a scan. `onScan` is called with the scan result.
`onScan` may also called multiple times if the scan is triggered by the hardware 
button on the scanner.

#### disable

	scanner.disable = function (onSuccess, onError);

Stops the [BluetoothSocket](http://developer.android.com/reference/android/bluetooth/BluetoothSocket.html)
that allows two-way communication between the plugin and the scanner.

## Error Handling

#### No KoamTac scanner paired

For all of the above functions, a simple check is made to see if any Bluetooth devices are paired that have a name starting with 'KDC'.
If none are found, `onError` is called with a message that prompts the user to pair a KoamTac scanner.

#### Bluetooth is not switched on

If bluetooth is not switched on, the plugin will:

- provide a native dialog allowing the user to enable bluetooth without leaving the app
- call `onError` with a message stating that the function could not occur because bluetooth was not switched on

If the user switched bluetooth on through the dialog then the plugin, knowing the users intent to perform a scan, 
will try to enable the scanner and subsequent calls to trigger or manual scans from the scanner button should succeed. 
If the user elects to not switch bluetooth on through the dialog then a message will be sent to `onError`.

#### Scanner is not 'enabled'

If bluetooth is switched on, and the KoamTac scanner is paired, but the scanner has not been enabled then
a call to `trigger` or `enable` will attempt to enable to scanner and open a 
[BluetoothSocket](http://developer.android.com/reference/android/bluetooth/BluetoothSocket.html).

If this attempt succeeds, then all subsequent scans will result in a call to `onScan` with the value from the scanner 
regardless of whether the scan was triggered by the app or by the scan button on the KoamTac scanner.

If this attempt fails then a failure message will be passed to `onError` prompting the user to enable the scanner.
