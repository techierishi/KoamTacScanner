//
//  CDVKoamTacScanner.h
//  KoamTacScannerApp
//
//  Created by Daniel Walker on 10/23/13.
//
//

#import <Cordova/CDV.h>
#import "KScan.h"

@interface CDVKoamTacScanner : CDVPlugin

{
    KScan *kscan;
}

- (void)enable:(CDVInvokedUrlCommand*)command;
- (void)trigger:(CDVInvokedUrlCommand*)command;
- (void)disable:(CDVInvokedUrlCommand*)command;

@property (nonatomic, retain) KScan *kscan;
@property (nonatomic, retain) NSString *callbackId;

@end
