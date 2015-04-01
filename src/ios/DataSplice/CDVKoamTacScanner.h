//
//  CDVKoamTacScanner.h
//  KoamTacScannerApp
//
//  Created by Daniel Walker on 10/23/13.
//
//

#import <Cordova/CDV.h>
#import "KDCReader.h"

@interface CDVKoamTacScanner : CDVPlugin

{
    KDCReader *kdcReader;
}

- (void)enable:(CDVInvokedUrlCommand*)command;
- (void)trigger:(CDVInvokedUrlCommand*)command;
- (void)disable:(CDVInvokedUrlCommand*)command;

@property (nonatomic, retain) KDCReader *kdcReader;
@property (nonatomic, retain) NSString *callbackId;

@end
