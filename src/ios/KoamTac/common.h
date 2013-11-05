/*
 *  common.h
 *  KTDemo
 *
 *  Created by Ben Yoo on 10. 3. 10..
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define	CACHE		0
#define	DOCUMENT	1
#define	MAX_WEB_APPS	10
#define MAX_PRINTERS    12

#define	KTSYNC_VERSION	[NSString stringWithFormat:@"KTDemo V2.04"]

extern  bool	IsMultiOS;

extern  bool    IsKDC300;
extern  bool    IsMSREnabled;

extern  bool	IsWebApp;

extern  bool	IsWaiting;
extern	bool	IsConnected;

extern	bool	IsGPSSupported;
extern  bool	IsGPSEnabled;
extern  bool	IsGPSUsing;

extern  bool    IsDisplayScanButton;

extern  bool    IsAlertEnabled;
extern  int     alertRetry;
//For synchronize
extern  bool	IsIdle;
extern	bool	IsIdleBackup;
extern  bool    IsExit;
extern	bool	IsDisconnect;
extern	bool	IsAttachTimestamp;
extern	bool	IsAttachType;
extern	bool	IsAttachSerial;
//extern	bool	 ;
extern  bool	IsAllSync;
extern  bool	IsPartialSync;
extern  bool	IsSupportPartialSync;

extern  bool    IsAttachLocationData;

extern  bool    IsSyncNonCompliant;
extern  bool    IsConsolidateData;
extern  bool    IsAttachQuantity;

extern  bool    IsEraseKDCMemory;

extern  char    RecordDelimiter;
extern  char    DataDelimiter;

extern  char	SyncDestination;

extern	bool	IsSynchronizeOn;

extern uint8_t SerialNo[];
extern uint8_t FWVersion[];
extern uint8_t FWBuild[];

extern	uint8_t BarcodeBuffer[2048+256];

extern  uint8_t KDCMessages[];
//-------------------------------------------
extern	NSMutableArray *listOfWebs, *listOfHomes, *listOfSearch;
extern	int		lastWebIndex;
extern	int		appIndex;
//extern	NSString *homeURL;
//extern	NSString *searchURL;
//----------------------------------
extern	NSString *subjectmail;
extern	NSString *tomail;
extern	NSString *ccmail;
//
extern  id mapDelegate;
extern  id gpsDelegate;
//-----------------------------------
extern  char        WedgeStore;
extern  char        DataFormat;
extern  char        Terminator;

extern  short       StartPosition;
extern  short       NoOfChars;
extern  char        Action;
extern  short       StartPositionMax;
extern  short       NoOfCharsMax;

extern  char        Prefix[30];
extern  char        Suffix[30];
extern  char        AimID;

extern  uint8_t     MacAddress[15];
extern  uint8_t     BTVersion[10];
extern  char        ConnectDevice;
extern  char        ConnectDeviceBackup;
extern  char        PowerOnTime;
extern  char        PowerOffTime;
extern  char        HIDAutoLock;
extern  char        HIDKeyboard;
extern  char        HIDInitDelay;
extern  char        HIDCharDelay;
extern  char        HIDCtrlChar;

extern  char        MSRDataFormat;
extern  char        TrackTerminator;
extern  short       MSRStartPosition;
extern  short       MSRNoOfChars;
extern  char        MSRAction;
extern  char        AESKeyLength;
extern  char        Key[33];

extern  short        SleepTimeout;

extern  int         ReadingTimeout;
extern  char        SecurityLevel;
extern  char        MinimumLength;
extern  char        RereadDelay;
extern  uint32_t    BarcodeSetting;
extern  uint32_t    BarcodeSettingBackup;
extern  uint32_t    OptionSetting;
extern  uint32_t    OptionSettingBackup;
extern  uint32_t    KDCSetting;
extern  uint32_t    KDCSettingBackup;

extern  uint32_t    BarcodeSettingHHP_1;
extern  uint32_t    BarcodeSettingHHP_2;
extern  uint32_t    BarcodeOptionHHP_1;
extern  uint32_t    BarcodeOptionHHP_2;
extern  uint32_t    BarcodeSettingHHP_1Backup;
extern  uint32_t    BarcodeSettingHHP_2Backup;
extern  uint32_t    BarcodeOptionHHP_1Backup;
extern  uint32_t    BarcodeOptionHHP_2Backup;

extern  char        Ocr;
extern  char        OcrBackup;

extern  char    CodabarCon;
extern  char    CodabarVeri;
extern  char    Code39Veri;
extern  char    I2of5veri;
extern  char    Telepen;
extern  char    Posicode;
extern  char    Gs1;

extern  int     BarcodeStored;
extern  int     MemoryLeft;

extern  uint8_t DateTime[8];
//-----------------------------------------------------------------------------------------
extern  NSMutableArray *listOfPrinters, *listOfMAC;
extern  int	printerIndex;
extern  int lastPrinterIndex;
extern  bool    bIsPrinterConnected;
extern  int dataLength;
extern  int     Counter;