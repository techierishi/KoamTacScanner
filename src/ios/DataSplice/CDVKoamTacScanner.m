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
@synthesize kscan;
@synthesize callbackId;

//-------------------------------------------------------------------
// Plugin Lifecycle Methods
// See: https://github.com/apache/cordova-ios/blob/master/CordovaLib/Classes/CDVPlugin.h
//-------------------------------------------------------------------
-(void)pluginInitialize {
    [super pluginInitialize];
    
    // Attach local methods to application lifecycle events
    SEL onWillTerminateSelector = sel_registerName("onWillTerminate:");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:onWillTerminateSelector
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    SEL onEnteredBackgroundSelector = sel_registerName("onEnteredBackground:");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:onEnteredBackgroundSelector
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
	// Initialize and connect device
	kscan = [[KScan alloc] init];
	[kscan SetApplicationDelegate:self];
	[kscan ConnectDevice];
}


//-------------------------------------------------------------------
// iOS Lifecycle Methods
//-------------------------------------------------------------------
-(void)onEnteredBackground :(UIApplication *)application {
    [kscan DisconnectDevice];
}
-(void)onWillTerminate :(UIApplication *)application {
    [kscan DisconnectDevice];
}


//-------------------------------------------------------------------
// KScan callback methods (implementation of KTSyncDelegate)
//-------------------------------------------------------------------
- (void)BarcodeDataArrived:(char *)BarcodeData;
{
    // get the barcode into a plugin result
    NSString* barcodeString = [NSString stringWithFormat:@"%s" , BarcodeData];
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
    [kscan ScanBarcode]; // KScan will call BarcodeDataArrived
}

/**
 * Kills all bleutooth communication threads.
 */
- (void)disable:(CDVInvokedUrlCommand*)command {
    [kscan DisconnectDevice];
    self.callbackId = nil;
//    [self.callbackId release];
    
    // Send the result
    // No need to keep the callback on this one.
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

- (void)dealloc {
//	[kscan release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
}


@end