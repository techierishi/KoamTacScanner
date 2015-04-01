//
//  CDVKoamTacScanner.m
//  KoamTacScannerApp
//
//  Created by Daniel Walker on 10/23/13.
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kdcBarcodeDataArrived:) name:kdcBarcodeDataArrivedNotification object:nil];

    [kdcReader Connect];
}


//-------------------------------------------------------------------
// iOS Lifecycle Methods
//-------------------------------------------------------------------
-(void)onDidEnterBackground :(UIApplication *)application {
    //[kdcReader Disconnect];
}
-(void)onDidBecomeActive :(UIApplication *)application {
    [kdcReader Connect];
}


//************************************************************************
//  Notification from KDCReader when connection has been changed
//************************************************************************
- (void)kdcConnectionChanged:(NSNotification *)notification
{
    // todo - can we do anything useful here?
    /*
    KDCReader *kReader = (KDCReader *)[notification object];

    if ( [kReader IsKDCConnected] ) {
        // self.navigationItem.prompt = @"KDC is connected";
    }
    else {
        // self.navigationItem.prompt = @"KDC is not connected";
    }
    */
}

//************************************************************************
//  Notification from KDCReader when barcode data has been arrived from KDC
//************************************************************************
- (void)kdcBarcodeDataArrived:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);

    KDCReader *kReader = (KDCReader *)[notification object];
    NSString* barcodeString = [kReader GetBarcodeData];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:barcodeString];

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
