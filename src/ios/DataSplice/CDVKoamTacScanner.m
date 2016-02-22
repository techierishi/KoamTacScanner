//
//  CDVKoamTacScanner.m
//  KoamTacScannerApp
//
//  Created by Daniel Walker on 10/23/13.
//  Updated by Justin Leis on 02/15/16.  Added NFC, MSR, GPS
//
//

#import "CDVKoamTacScanner.h"

/**
 *
 * KoamTac scanner Cordova plugin.
 *
 */
@implementation CDVKoamTacScanner

// @synthesize "generates" the getter/setter methods on the @property
@synthesize kdcReader;
@synthesize callbackId;

//-------------------------------------------------------------------
// Plugin Lifecycle Methods
// See: https://github.com/apache/cordova-ios/blob/master/CordovaLib/Classes/CDVPlugin.h
//-------------------------------------------------------------------
-(void)pluginInitialize {
    [super pluginInitialize];

    // Attach local methods to application lifecycle events
    SEL onDidEnterBackgroundSelector = sel_registerName("onDidEnterBackground:");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:onDidEnterBackgroundSelector
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    SEL onDidBecomeActiveSelector = sel_registerName("onDidBecomeActive:");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:onDidBecomeActiveSelector
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // Initialize and connect device
    kdcReader = [[KDCReader alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcConnectionChanged:) name:kdcConnectionChangedNotification object:nil];
    // Generic
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcDataArrived:) name:kdcDataArrivedNotification object:nil];
    // Barcode
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcBarcodeDataArrived:) name:kdcBarcodeDataArrivedNotification object:nil];
    // MSR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcMSRDataArrived:) name:kdcMSRDataArrivedNotification object:nil];
    // NFC
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcNFCDataArrived:) name:kdcNFCDataArrivedNotification object:nil];
    // GPS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcGPSDataArrived:) name:kdcGPSDataArrivedNotification object:nil];


    [kdcReader Connect];
}


//-------------------------------------------------------------------
// iOS Lifecycle Methods
//-------------------------------------------------------------------
-(void)onDidEnterBackground :(UIApplication *)application {
    // [kdcReader Disconnect];
}
-(void)onDidBecomeActive :(UIApplication *)application {
    [kdcReader Connect];
}


//************************************************************************
//  Notification from KDCReader when connection has been changed
//************************************************************************
- (void)kdcConnectionChanged:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);

    KDCReader *kReader = (KDCReader *)[notification object];
    NSString *status = @"";

    if ( [kReader IsKDCConnected] ) {
        status = @"{\"status\": \"CONNECTED\"}";
    }
    else {
        status = @"{\"status\": \"DISCONNECTED\"}";
    }
    NSLog(@"Sending message %",status);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:status];

    // ensure we keep the callback (to push subsequent barcodes to the app)
    [pluginResult setKeepCallbackAsBool:YES];

    // send the result
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];

}

//************************************************************************
//  Notification from KDCReader when Generic/Unknown data has been arrived from KDC
//************************************************************************
- (void)kdcDataArrived:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);

    KDCReader *kReader = (KDCReader *)[notification object];
    NSString *dataString = [NSString stringWithFormat:@"{\"scan\":\"%@\"}", [kReader GetData]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:dataString];

    // ensure we keep the callback (to push subsequent barcodes to the app)
    [pluginResult setKeepCallbackAsBool:YES];

    // send the result
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}


//************************************************************************
//  Notification from KDCReader when barcode data has been arrived from KDC
//************************************************************************
- (void)kdcBarcodeDataArrived:(NSNotification *)notification
{
    KDCReader *kReader = (KDCReader *)[notification object];
    NSString *barcodeString = [NSString stringWithFormat:@"{\"scan\":\"%@\"}", [kReader GetBarcodeData]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:barcodeString];

    // ensure we keep the callback (to push subsequent barcodes to the app)
    [pluginResult setKeepCallbackAsBool:YES];

    // send the result
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

//************************************************************************
//  Notification from KDCReader when MSR data has been arrived from KDC
//************************************************************************
- (void)kdcMSRDataArrived:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);

    KDCReader *kReader = (KDCReader *)[notification object];
    NSString *msrString = [NSString stringWithFormat:@"{\"scan\":\"%@\"}", [kReader GetMSRData]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:msrString];

    // ensure we keep the callback (to push subsequent barcodes to the app)
    [pluginResult setKeepCallbackAsBool:YES];

    // send the result
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

//************************************************************************
//  Notification from KDCReader when NFC data has been arrived from KDC
//************************************************************************
- (void)kdcNFCDataArrived:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);

    KDCReader *kReader = (KDCReader *)[notification object];
    NSString *uid = [NSString stringWithFormat:@"{\"scan\":\"%@\"}", [kReader GetNFCUID]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:uid];

    // ensure we keep the callback (to push subsequent barcodes to the app)
    [pluginResult setKeepCallbackAsBool:YES];

    // send the result
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

//************************************************************************
//  Notification from KDCReader when GPS data has been arrived from KDC
//************************************************************************
- (void)kdcGPSDataArrived:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);

    KDCReader *kReader = (KDCReader *)[notification object];
    NSString *gpsString = [NSString stringWithFormat:@"{\"scan\":\"%@\"}", [kReader GetGPSData]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:gpsString];

    // ensure we keep the callback (to push subsequent barcodes to the app)
    [pluginResult setKeepCallbackAsBool:YES];

    // send the result
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}


//-------------------------------------------------------------------
// Cordova Plugin API
//-------------------------------------------------------------------

/**
 * Connects to a paired scanner and starts listening for scan events.
 */
- (void)enable:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:@"{\"status\":\"success\"}"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

/**
 * Sends a command to the scanner to perform an actual scan.
 */
- (void)trigger:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    // [kscan ScanBarcode]; // KScan will call BarcodeDataArrived
    [kdcReader SoftwareTrigger];
}

/**
 * Kills all bleutooth communication threads.
 */
- (void)disable:(CDVInvokedUrlCommand*)command {
    //[kdcReader Disconnect];
    self.callbackId = nil;
//    [self.callbackId release];

    // Send the result
    // No need to keep the callback on this one.
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
}


@end
