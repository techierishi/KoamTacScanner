//
//  KScan.h
//  KTDemo
//
//  Created by Ben Yoo on 10. 3. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iKEA.h"

@class KScan;

@interface KScan : NSObject { 
	iKEA *ikea;
}

@property (nonatomic, retain) iKEA *ikea;

-(void)CalcurateLocation;
-(void)SetGPSPower:(bool)PowerOn;
-(void)SetGPSMode:(bool)Bypass;
-(void)SetGPSPowerMode:(bool)poweron:(bool)bypass:(bool)alert;

-(void)GetMemoryStatus;
-(void)GetSystemSettings;
-(void)GetMSRSettings;
-(void)GetHIDOptions;
-(void)GetBluetoothOptions;
-(void)GetDataProcess;
-(void)GetPrefixSuffix;
-(void)GetScanOptions;
-(void)GetOptions;
-(void)GetOptionsHHP;
-(void)GetSymbology;
-(void)GetSymbologyHHP;
-(void)SendCommandWithValue:(char *)cmd:(int)value;
-(void)SendCommandWithValueEx:(char *)cmd:(int)value1:(int)value2;
-(void)SendCommandFixData:(char *)cmd:(NSString *)fixdata;
-(void)FinishCommand;
-(void)SetBTProfile;
-(void)GetPrinterPortStatus;
-(void)DiscoverPrinters;
-(void)ConnectPrinter:(NSString *)MacAddress;
-(void)SendDataToPrinter:(char *)Buffer:(int)length;
-(void)SaveSettings;
-(void)GetAESKey;
//
//	Called from application
//
- (void)Synchronize:(unsigned int)StartIndex;

- (void)ConnectDevice;
- (void)DisconnectDevice;
- (void)SetMapAppDelegate:(id)mapDel;
- (void)SetGPSAppDelegate:(id)gpsDel;
- (void)SetApplicationDelegate:(id)appDel;
- (void)SetFileManagerDelegate:(id)fileDel;
- (void)SendMessage;
- (void)SendBeepCommand:(bool)success;
- (void)SendNullData;
- (void)EraseKDCMemory;
- (void)ScanBarcode;

- (void)SyncKDCClock;
- (void)SetFactoryDefault;
- (void)SetViewDelegate:(id)viewDel:(int)index;
- (void)SendCommandGetResult:(int)type:(int)subtype:(char *)command:(int)length;
//
//	Called from iKEA
//
- (void)DeviceConnected;
- (void)DeviceDisconnected;
- (void)DataFromDevice:(uint8_t *)ReadBuffer:(int)length;
//
- (void)StopTimer;
- (void)ResetTimer;

@end

@interface NSObject (KTSyncDelegate)
- (void)BarcodeDataArrived:(char *)BarcodeData;
//- (void)DisplayConnectionStatus;
- (void)SynchronizeFinished;
- (void)StartSynchronize;
- (void)SaveWebApps;
//- (void)SaveEmailSettings;
- (void)DisplayAlert:(bool)on:(NSString *)message:(NSString *)button:(bool)startTimer;
- (void)SavePrinterList;
- (void)InitPrinters;
- (void)showScanButton;

@end

@interface NSObject (FileDelegate)
-(void)ReadRegistry:(NSString *)RegFile:(char *)RegData;
-(void)SaveRegistry:(NSString *)RegFile:(char *)RegData:(NSString *)RegString;
@end

@interface NSObject (MapDelegate)
-(void)setLocation:(float_t)latitude:(float_t)longitude;
@end

@interface NSObject (GPSDelegate)
-(void)DisplayGPSLog:(char *)Message;
@end

@interface NSObject (ViewDelegate)
-(void)loadView:(int)view;
@end