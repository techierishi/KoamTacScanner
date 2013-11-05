//ƒ
//  KScan.m
//  KTDemo
//
//  Created by Ben Yoo on 10. 3. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "KScan.h"
#import "AES.h"


#define PRINTER_PACKET  1024
#define	REGISTRY_FILE	[NSString stringWithFormat:@"KTSyncRegistry.txt"]

@implementation KScan

@synthesize ikea;
//-----------------------------------
char        WedgeStore = 1;
char        DataFormat = 1;
char        Terminator = 3;

short       StartPosition = 1;
short       NoOfChars = 0;
char        Action = 1;
short       StartPositionMax;
short       NoOfCharsMax;

char        Prefix[30] = "";
char        Suffix[30] = "";
char        AimID = 0;

uint8_t     MacAddress[15] = "000000000000";
uint8_t     BTVersion[10] = "0.0.0";
char        ConnectDevice = 2;
char        ConnectDeviceBackup;
char        PowerOnTime = 0;
char        PowerOffTime = 5;
char        HIDAutoLock = 1;
char        HIDKeyboard = 0;
char        HIDInitDelay = 0;
char        HIDCharDelay = 0;
char        HIDCtrlChar = 0;

char        MSRDataFormat = 1;
char        TrackTerminator = 6;
short       MSRStartPosition = 1;
short       MSRNoOfChars = 0;
char        MSRAction = 1;
char        AESKeyLength = 0;
char        Key[33] = "KDCKoamKDCTacKDCKDCKoamKDCTacKDC";

short        SleepTimeout = 5;

int         ReadingTimeout = 2000;
char        SecurityLevel = 2;
char        MinimumLength = 4;
char        RereadDelay = 2;
uint32_t    BarcodeSetting;
uint32_t    BarcodeSettingBackup;

uint32_t    OptionSetting;
uint32_t    OptionSettingBackup;

uint32_t    KDCSettingBackup;
uint32_t    KDCSetting;
//          0x00000001  Bluetooth Toggle
//          0x00000002  Check Duplicated Barcode
//          0x00000004  Send Power Off Message
//          0x00000008  Auto Connect
//          0x00000010  Auto Power On
//          0x00000020  Auto Power Off
//          0x00000040  Beep Warning
//          0x00000080  Send Wakeup Nulls
//          0x00000100  Auto Trigger Mode
//          0x00000200  MSR Encrypt
//          0x00000400  MSR Track1
//          0x00000800  MSR Track2
//          0x00001000  MSR Track3
//          0x00002000  Beep sound
//          0x00004000  Auto Erase
//          0x00008000  Menu Barcode(KDC300)
//          0x00010000  High Beep Volume
//          0x00020000  MSR Beep On Error
uint32_t    BarcodeSettingHHP_1;
uint32_t    BarcodeSettingHHP_2;
uint32_t    BarcodeOptionHHP_1;
uint32_t    BarcodeOptionHHP_2;
uint32_t    BarcodeSettingHHP_1Backup;
uint32_t    BarcodeSettingHHP_2Backup;
uint32_t    BarcodeOptionHHP_1Backup;
uint32_t    BarcodeOptionHHP_2Backup;
char    Ocr = 0;
char    OcrBackup;

char    CodabarCon = 0;
char    CodabarVeri = 0;
char    Code39Veri = 0;
char    I2of5veri = 0;
char    Telepen = 0;
char    Posicode = 2;
char    Gs1 = 2;

int     BarcodeStored = 0;
int     MemoryLeft = 0;

uint8_t DateTime[8];
//-------------------------------------
bool	IsMultiOS = false;

bool	IsWebApp = false;

bool	IsWaiting = false;
bool	IsFirstConnect = true;
bool	IsConnected = false;
bool	IsCommandOn = false;
bool	IsCommandDone = true;
bool	IsKDC300 = false;

bool    IsMSREnabled = false;

bool	IsGPSSupported = false;
bool	IsGPSUsing = false;
bool	IsGPSEnabled = false;
bool    IsDisplayScanButton = false;

bool    IsAlertEnabled = false;

bool	IsIdle = false;
bool	IsIdleBackup = false;
bool	IsExit = false;
bool	IsDisconnect = false;
bool	IsAttachTimestamp = false;
bool	IsAttachType = false;
bool	IsAttachSerial = false;
//bool	IsSyncToFile = false;
bool	IsAllSync = false;
bool	IsPartialSync = false;
bool	IsSynchronizeOn = false;
bool	IsPartialSyncStarted = false;
bool	IsSupportPartialSync = false;

bool    IsSyncNonCompliant = false;
bool    IsConsolidateData = false;
bool    IsAttachQuantity = false;

bool    IsEraseKDCMemory = false;

bool    IsAttachLocationData = false;
char    RecordDelimiter = 4;
char    DataDelimiter = 0;

char	SyncDestination = 0;

int     alertRetry = 0;
int		commandLength = 0;
int		commandType = 0;
unsigned int SyncEndIndex = 0;
unsigned int SyncStartIndex = 0;

int LastBarcodeIndex = -1;
unsigned int LastDateValue = 0;
unsigned int LastTimeValue = 0;

int		BufferOffset = 0;
int		BarcodeBufferOffset = 0;
int		BarcodeLength = 0;
int		TotalDataLength = 0;
int		CurrentDataLength = 0;

uint8_t commandBuf[1024];
uint8_t BarcodeBuffer[4096];
uint8_t TempDataBuffer[4096];

uint8_t	cmdWrite = 0;
uint8_t cmdRead = 0;
uint8_t cmdArray[256+2];

uint8_t	SerialNo[11*5] = "0000000000";
uint8_t FWVersion[11] = "0.00.00000";
uint8_t FWBuild[13] = "000000000000";

uint8_t KDCMessages[100];

uint8_t StringResponse[100];
int     StringOffset = 0;

char *typeString[] = {
	"EAN 13",		"EAN 8",		"UPCA",		"UPCE",		"Code 39",
	"ITF-14",       "Code 128",		"I2of5",	"CodaBar",	"UCC/EAN-128",
	"Code 93",		"Code 35",		"Unknown",	"Unknown",	"Bookland EAN",
	"Unknown"
};

char *hhptypeString[] = {
	"Code 32",		"Trioptic",		"Korea Post",		"Aus. Post",		"British Post",   //4 0x00000010                                
	"Canada Post",	"EAN-8",		"UPC-E",			"UCC/EAN-128",		"Japan Post",     //9 0x00000200
	"KIX Post",     "Planet Code",  "OCR",				"Postnet",			"China Post",     //14 0x00004000
	"Micro PDF417", "TLC 39",       "PosiCode",			"Codabar",          "Code 39",        //19 0x00080000
	"UPC-A",        "EAN-13",       "I2of5",            "IATA",             "MSI",            //24 0x01000000
	"Code 11",      "Code 93",      "Code 128",         "Code 49",          "Matrix2of5",     //29 0x20000000
	"Plessey",      "Code 16K",     "Codablock F",      "PDF417",           "QR/Micro QR",    //34 0x00000004
	"Telepen",      "VeriCode",     "Data Matrix",      "MaxiCode",         "EAN/UCC",        //39 0x00000080
	"RSS",          "Aztec Code",   "No Read",          "HanXin Code",      "Unknown"         //44 
};

id	fileDelegate = nil;
id	appDelegate = nil;
id	mapDelegate = nil;
id  gpsDelegate = nil;
id  viewDelegate = nil;
int viewIndex = 0;
NSThread *commandThread = nil;
NSTimer *kdcTimer = nil;
//-----------------------------------------------------------------------------------------
NSMutableArray *listOfWebs, *listOfHomes, *listOfSearch;
int	lastWebIndex;
int	appIndex;
//NSString *homeURL;
//NSString *searchURL;
//-----------------------------------------------
NSString *subjectmail;
NSString *tomail;
NSString *ccmail;
//-------------------------------------------------
char latitudestring[20];
char longitudestring[20];
char altitudestring[20];
float_t latitudedecimal = 0, longitudedecimal = 0, altitudedecimal = 0;
float_t latitudedecimal_backup = 0, longitudedecimal_backup = 0;
bool bIsSouth, bIsWest;
//
bool bLoadView = false;
int  subcmdType = 0;
//
bool    IsMenuAlertStarted = false;
//-----------------------------------------------------------------------------------------
NSMutableArray *listOfPrinters, *listOfMAC;
int     printerIndex;
int     lastPrinterIndex;
bool    bIsPrinterConnected = false;
char    *dataBuffer;
int     dataLength;
int     dataOffset;
int     packet;
bool    bPrintResult;
int     Counter;
int     printer_packet_length;
//-----------------------------------------------------------------------------------------
//
//			Handling KDC commands
//
//-----------------------------------------------------------------------------------------
-(void)SendCommandReturn
{    
    cmdArray[cmdWrite++] = 1;
    cmdArray[cmdWrite++] = 0;    
}

-(void)FinishCommand
{
    cmdArray[cmdWrite++] = 1;
    cmdArray[cmdWrite++] = 'W';
}

-(void)SendCommandGetResult:(int)type:(int)subtype:(char *)command:(int)length;
{
    NSLog(@"%s",__FUNCTION__);
    
    cmdArray[cmdWrite++] = length;
    cmdArray[cmdWrite++] = type;
    cmdArray[cmdWrite++] = subtype;
    
    for(int i = 0; i < length; i++) cmdArray[cmdWrite++] = command[i];
} 

-(void)SendCommandWithValue:(char *)cmd:(int)value
{
    NSLog(@"%s",__FUNCTION__);
    
    if ( ! IsMenuAlertStarted ) {
        IsMenuAlertStarted = true;
        [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    }
    NSString *command = [NSString stringWithFormat:@"%s%X#", cmd, value];
    const char *temp = [command UTF8String];
    
    NSLog(@"%@[%s:%d]", command, temp, [command length]); 
    
    cmdArray[cmdWrite++] = [command length];
    cmdArray[cmdWrite++] = 255;
    cmdArray[cmdWrite++] = 0;
    
    for(int i = 0; i < [command length]; i++) cmdArray[cmdWrite++] = temp[i];
}

-(void)SendCommandWithValueEx:(char *)cmd:(int)value1:(int)value2
{
    NSLog(@"%s",__FUNCTION__);

    if ( ! IsMenuAlertStarted ) {
        IsMenuAlertStarted = true;
        [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    }
    
    NSString *command = [NSString stringWithFormat:@"%s%X#%X#", cmd, value1, value2];
    const char *temp = [command UTF8String];
    
    NSLog(@"%@[%s:%d]", command, temp, [command length]); 
    
    cmdArray[cmdWrite++] = [command length];
    cmdArray[cmdWrite++] = 255;
    cmdArray[cmdWrite++] = 0;
    
    for(int i = 0; i < [command length]; i++) cmdArray[cmdWrite++] = temp[i];
    
}
-(void)SendCommandFixData:(char *)cmd:(NSString *)fixdata
{
    NSLog(@"%s",__FUNCTION__);
    
    if ( ! IsMenuAlertStarted ) {
        IsMenuAlertStarted = true;
        [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    }
    
    NSString *command = [NSString stringWithFormat:@"%s%X#%@", cmd, [fixdata length], fixdata];
    const char *temp = [command UTF8String];
    
    NSLog(@"%@[%s:%d]", command, temp, [command length]); 
    
    cmdArray[cmdWrite++] = [command length];
    cmdArray[cmdWrite++] = 255;
    cmdArray[cmdWrite++] = 0;
    
    for(int i = 0; i < [command length]; i++) cmdArray[cmdWrite++] = temp[i];        
}

-(void)WakeupKDC:(bool)NeedToSendNull
{
	if ( NeedToSendNull )	cmdArray[cmdWrite++] = 1;
	else					cmdArray[cmdWrite++] = 0;
	cmdArray[cmdWrite++] = 'W';
}	

-(void)GetSerialNumber
{
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'M';
}

-(void)GetFWVersion
{
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'V';
}
-(void)GetFWBuild
{
	cmdArray[cmdWrite++] = 2;
	cmdArray[cmdWrite++] = 'I';    
	cmdArray[cmdWrite++] = 'v';
}
-(void)GetBTMACAddress
{
	cmdArray[cmdWrite++] = 3;
	cmdArray[cmdWrite++] = '4';
	cmdArray[cmdWrite++] = 'T';
	cmdArray[cmdWrite++] = '9';
    
}
-(void)GetBTVersion
{
	cmdArray[cmdWrite++] = 3;
	cmdArray[cmdWrite++] = '5';
	cmdArray[cmdWrite++] = 'T';
	cmdArray[cmdWrite++] = 'V';    
}

-(void)Synchronize:(unsigned int)StartIndex;
{

	NSLog(@"%s", __FUNCTION__);

	[self WakeupKDC:true];	
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'N';
	//[NSThread sleepForTimeInterval:1];
	cmdArray[cmdWrite++] = 3;
	cmdArray[cmdWrite++] = '0';
	cmdArray[cmdWrite++] = 'S';
	cmdArray[cmdWrite++] = '1';
	//[NSThread sleepForTimeInterval:1];
	SyncStartIndex = StartIndex;
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'p';
}

-(void)BluetoothPower:(bool)PowerOn;
{
	cmdArray[cmdWrite++] = 4;
	cmdArray[cmdWrite++] = 'b';
	cmdArray[cmdWrite++] = 'T';
	cmdArray[cmdWrite++] = '1';
	if ( PowerOn )	cmdArray[cmdWrite++] = '1';
	else			cmdArray[cmdWrite++] = '0';
}
-(void)SetWedgeMode:(bool)Packet;
{
	cmdArray[cmdWrite++] = 3;
	cmdArray[cmdWrite++] = 'w';
	if ( Packet )	cmdArray[cmdWrite++] = '1';
	else			cmdArray[cmdWrite++] = '0';
	cmdArray[cmdWrite++] = '#';
}
//
-(uint8_t *)GetSerialNumberString
{
	return SerialNo;
}
-(uint8_t *)GetFWVersionString
{
	return FWVersion;
}


-(void)SetGPSMode:(bool)Bypass;
{
	
	NSLog(@"%s",__FUNCTION__);
	
	//[self SendNullData];
	//[NSThread sleepForTimeInterval:0.5];
	
	cmdArray[cmdWrite++] = 4;
	cmdArray[cmdWrite++] = '3';
	cmdArray[cmdWrite++] = 'G';
	cmdArray[cmdWrite++] = '2';
	if ( Bypass )	cmdArray[cmdWrite++] = '1';
	else			cmdArray[cmdWrite++] = '0';
}

-(void)SetGPSPower:(bool)PowerOn;
{
	
	NSLog(@"%s",__FUNCTION__);
	
	cmdArray[cmdWrite++] = 4;
	cmdArray[cmdWrite++] = '3';
	cmdArray[cmdWrite++] = 'G';
	cmdArray[cmdWrite++] = '1';
	if ( PowerOn )	cmdArray[cmdWrite++] = '1';
	else			cmdArray[cmdWrite++] = '0';
}

-(void)SetGPSPowerMode:(bool)poweron:(bool)bypass:(bool)alert
{
	NSLog(@"%s",__FUNCTION__);	
    
    
    if ( bypass ) {	 
        [self SetGPSMode:bypass];         
        [self SetGPSPower:poweron];
    } else {
        [self SetGPSPower:poweron];
        [self SetGPSMode:bypass];        
    }

    
    if ( alert )    {
        alertRetry = 2;
        [appDelegate DisplayAlert:true:@"Please Wait...":nil:true];
    }
}

-(void)SendCTS
{

	NSLog(@"%s",__FUNCTION__);

	cmdArray[cmdWrite++] = 2;
	cmdArray[cmdWrite++] = 'A';
	cmdArray[cmdWrite++] = 'C';
}

-(void)SendMessage
{
	NSLog(@"%s",__FUNCTION__);
	
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = '2';
	
}

-(void)SendBeepCommand:(bool)success
{
	
	NSLog(@"%s",__FUNCTION__);

	
	cmdArray[cmdWrite++] = 4;
	cmdArray[cmdWrite++] = '3';
	cmdArray[cmdWrite++] = 'M';
	cmdArray[cmdWrite++] = 'B';
	if ( success )	cmdArray[cmdWrite++] = '1';
	else			cmdArray[cmdWrite++] = '0';
}

-(void)EraseKDCMemory
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    cmdArray[cmdWrite++] = 1;
    cmdArray[cmdWrite++] = 'E';
}

-(void)ScanBarcode
{
    NSLog(@"%s",__FUNCTION__);
    
    cmdArray[cmdWrite++] = 1;
    cmdArray[cmdWrite++] = 'D';
}

-(void)SetMSRDataFormat:(int)format
{
    NSLog(@"%s",__FUNCTION__);
    
    cmdArray[cmdWrite++] = 7;
    cmdArray[cmdWrite++] = '0';
    cmdArray[cmdWrite++] = 'n';
    cmdArray[cmdWrite++] = 'M';
    cmdArray[cmdWrite++] = 'D';
    cmdArray[cmdWrite++] = 'S';
    cmdArray[cmdWrite++] = '0'+(char)format;
    cmdArray[cmdWrite++] = '#';
}

//-----------------------------------------------------------------------------------------
//
//			Called from KDC configuration
//
//-----------------------------------------------------------------------------------------
-(void)SetFactoryDefault
{
	NSLog(@"%s",__FUNCTION__);
	
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'F';
	
}

-(void)SetBTProfile
{
    NSLog(@"%s",__FUNCTION__);
    
    if ( ! IsMenuAlertStarted ) {
        IsMenuAlertStarted = true;
        [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    }
    NSString *command = [NSString stringWithFormat:@"bTc%X#", ConnectDevice];
    const char *temp = [command UTF8String];
    
    NSLog(@"%@[%s:%d]", command, temp, [command length]); 
    
    cmdArray[cmdWrite++] = [command length];
    cmdArray[cmdWrite++] = 254;
    cmdArray[cmdWrite++] = 0;
    
    for(int i = 0; i < [command length]; i++) cmdArray[cmdWrite++] = temp[i];
    
}

-(void)SyncKDCClock
{
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit| NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    
    NSLog(@"%d/%d/%d:%d:%d:%d", year, month, day, hour, minute, second);
    
    cmdArray[cmdWrite++] = 7;
    cmdArray[cmdWrite++] = 'C';
    cmdArray[cmdWrite++] = (uint8_t)(year - 2000);
    cmdArray[cmdWrite++] = (uint8_t)month;
    cmdArray[cmdWrite++] = (uint8_t)day;
    cmdArray[cmdWrite++] = (uint8_t)hour;
    cmdArray[cmdWrite++] = (uint8_t)minute;
    cmdArray[cmdWrite++] = (uint8_t)second;
  
}

-(void)GetMemoryStatus
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
//Barcode stored 
    [self SendCommandGetResult:11:1:"GnS0":4];
    [self SendCommandReturn];
//Memory left    
    [self SendCommandGetResult:11:2:"GnS1":4];    
}

-(void)GetSystemSettings
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
//Sleep timeout    
    [self SendCommandGetResult:11:3:"GnTG":4];
//Beep sound    
    [self SendCommandGetResult:11:4:"Gb2":3];
//High beep volume    
    [self SendCommandGetResult:11:5:"Gb3":3];
//Menu barcode
    if ( IsKDC300 )    [self SendCommandGetResult:11:7:"GnBG":4];  
//Auto erase   
    [self SendCommandGetResult:11:6:"GnEG":4];    
//Date&Time    
    [self SendCommandReturn];    
    [self SendCommandGetResult:11:8:"c":1];     
}
-(void)GetMSRSettings
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
//Data Format    
    [self SendCommandGetResult:11:9:"GnMDG":5];
//Track terminator   
    [self SendCommandGetResult:11:10:"GnMSG":5];
//Encrypt Data    
    [self SendCommandGetResult:11:11:"GnMEG":5];  
//Beep On Error    
    [self SendCommandGetResult:11:41:"GnMBG":5]; 
//Track select    
    [self SendCommandGetResult:11:12:"GnMTG":5];
//AES Key Length    
    [self SendCommandGetResult:11:48:"GnMkG":5];    
//Start position    
    [self SendCommandGetResult:11:45:"GnMPOG":6];   
//No of chars    
    [self SendCommandGetResult:11:46:"GnMPLG":6];     
//Action  
    [self SendCommandReturn];     
    [self SendCommandGetResult:11:47:"GnMPTG":6];    
}
-(void)GetAESKey
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;    
    
    //AES Key    
    [self SendCommandReturn];     
    [self SendCommandGetResult:11:49:"GnMKG":5];     
}
-(void)GetHIDOptions
{
    NSLog(@"%s",__FUNCTION__);

    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
//HID Autolock    
    [self SendCommandGetResult:11:13:"GHTG":4];
//HID Keyboard   
    [self SendCommandGetResult:11:14:"GHKG":4];
//HID Init Delay    
    [self SendCommandGetResult:11:15:"GndBG":5];  
//HID Char Delay
    [self SendCommandGetResult:11:16:"GndCG":5];        
//HID Control Char    
    [self SendCommandReturn];    
    [self SendCommandGetResult:11:17:"GnCG":4];      
}
-(void)GetBluetoothOptions
{
    NSLog(@"%s",__FUNCTION__);

    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
//Connect device    
    [self SendCommandGetResult:11:18:"bTcG":4]; 
//BT Options    
    [self SendCommandGetResult:11:19:"bT0":4]; 
//Power On time    
    [self SendCommandGetResult:11:20:"bTO0":4]; 
//Power Off time  
    [self SendCommandReturn];      
    [self SendCommandGetResult:11:21:"bT70":4]; 
    
}
-(void)GetDataProcess
{
    NSLog(@"%s",__FUNCTION__);

    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
//Wedge/store    
    [self SendCommandGetResult:11:22:"u":1];   
//Data format    
    [self SendCommandGetResult:11:23:"GnF":3];     
//Terminator    
    [self SendCommandGetResult:11:24:"GTG":3]; 
//Check duplicated data    
    [self SendCommandGetResult:11:25:"GnDG":5];   
//AIM ID    
    [self SendCommandGetResult:11:26:"GEGA":4]; 
//Start position    
    [self SendCommandGetResult:11:27:"GEGO":4];   
//No of chars    
    [self SendCommandGetResult:11:28:"GEGL":4];     
//Action  
    [self SendCommandReturn];     
    [self SendCommandGetResult:11:29:"GEGT":4];    
}
-(void)GetPrefixSuffix
{
    NSLog(@"%s",__FUNCTION__);

    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;    
    //Prefix    
    [self SendCommandGetResult:11:30:"GEGP":4];     
    //Suffix    
    [self SendCommandReturn];     
    [self SendCommandGetResult:11:31:"GEGS":4];     
}
-(void)GetScanOptions
{
    NSLog(@"%s",__FUNCTION__);

    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false; 
    if ( ! IsKDC300 ) {
        //Scan Angle & Filter   
        [self SendCommandGetResult:11:32:"o":1];    
        //Security Level
        [self SendCommandGetResult:11:33:"z":1];         
    }
    //Reading Timeout    
    [self SendCommandGetResult:11:34:"t":1]; 
    //Minimum length    
    [self SendCommandGetResult:11:35:"l":1]; 
    //Auto trigger    
    [self SendCommandGetResult:11:36:"GtGM":4]; 
    //Reread delay  
    [self SendCommandReturn];     
    [self SendCommandGetResult:11:37:"GtGD":4];     
}
-(void)GetOptions
{
    NSLog(@"%s",__FUNCTION__);
 
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = true; 

    //Barcode Options  
    [self SendCommandGetResult:11:32:"o":1];     
}

-(void)GetOptionsHHP
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = true; 
    
    //Barcode Options HHP  
    [self SendCommandGetResult:11:40:"o":1];     
}
-(void)GetSymbology
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = true; 
    
    //Barcode Symbology  
    [self SendCommandGetResult:11:38:"s":1];    
}
-(void)GetSymbologyHHP
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = true; 
    
    //Barcode Symbology HHP  
    [self SendCommandGetResult:11:39:"s":1];    
}

//-----------------------------------------------------------------------------------------
//
//			Printer bluetooth support
//
//-----------------------------------------------------------------------------------------
-(void)GetPrinterPortStatus
{
    NSLog(@"%s",__FUNCTION__);
    
    if ( ! IsConnected ) return;
    
    bIsPrinterConnected  = false;
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
    
    //Discover & upload list    
    [self SendCommandReturn];    
    [self SendCommandGetResult:11:42:"bSS":3];
    [self SendCommandGetResult:11:50:"bSP":3];
}

-(void)DiscoverPrinters
{
    NSLog(@"%s",__FUNCTION__);
    
    if ( bIsPrinterConnected )  return;
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
   
    //Discover & upload list    
    [self SendCommandReturn];    
    [self SendCommandGetResult:11:43:"bSN":3];         
}

-(void)ConnectPrinter:(NSString *)Address
{
    NSLog(@"%s",__FUNCTION__);
    
    [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    
    bLoadView = false;
    
    char mac[100];
    int i = sprintf(mac, "bSC%s#", [Address UTF8String]); 

    [self SendCommandReturn];
    [self SendCommandGetResult:11:44:mac:i];    
            
}

-(void)SendDataToPrinter:(char *)Buffer :(int)length
{
    NSLog(@"%s",__FUNCTION__);
    
    if ( ! IsMenuAlertStarted ) {
        IsMenuAlertStarted = true;
        [appDelegate DisplayAlert:true:@"Please Wait...":nil:false];
    }

    dataLength = length;
    dataBuffer = malloc(length);
    
    for (int i = 0; i < length; i++) dataBuffer[i] = Buffer[i];

    [self SendCommandGetResult:12:0:"":0];
    [self FinishCommand];
}
//-----------------------------------------------------------------------------------------
//
//			Command Thread
//
//-----------------------------------------------------------------------------------------
- (void)SendCommand
{

	NSLog(@"SendCommand %s:%d", commandBuf, commandLength);
	
	NSInteger numberWritten = [ikea SendDataToDevice:commandBuf:commandLength];


	// Check for errors
	if (numberWritten == -1) {
		NSLog(@"Error to send command");
	} else {
		NSLog(@"numberWritten: %d", numberWritten);
	}
	
	IsCommandOn = false;
	IsCommandDone = false;	
}

-(void)ThreadSendCommand
{
    NSLog(@"%s",__FUNCTION__);
    
	commandLength = cmdArray[cmdRead++];
	for (int i = 0; i < commandLength; i++) commandBuf[i] = cmdArray[cmdRead++];
	commandBuf[commandLength] = 0x00;
	IsCommandOn = true;
	IsCommandDone = false;
	
	[self SendCommand];
	
    if ( commandBuf[0] == 'D' ) {
        IsCommandDone = true;
        return;
    }
        
	int count = 300;
	while ( count-- ) {
		if ( IsCommandDone )	break;
		[NSThread sleepForTimeInterval:0.1];
	}
}

-(void)ThreadSendCommandEx:(int)loopcnt
{
    NSLog(@"%s",__FUNCTION__);
    
	commandLength = cmdArray[cmdRead++];
    cmdRead++;
    subcmdType = cmdArray[cmdRead++];
	for (int i = 0; i < commandLength; i++) commandBuf[i] = cmdArray[cmdRead++];
	commandBuf[commandLength] = 0x00;
	IsCommandOn = true;
	IsCommandDone = false;
	
	[self SendCommand];
	
    if ( commandBuf[0] == 'D' ) {
        IsCommandDone = true;
        return;
    }
    
	while ( loopcnt-- ) {
		if ( IsCommandDone )	break;
		[NSThread sleepForTimeInterval:0.1];
	}
}

//-----------------------------------------------------------------------------------------
//
//			Printer command thread
//
//-----------------------------------------------------------------------------------------
-(bool)ThreadSendData:(uint8_t *)buffer:(int)length
{
    IsCommandOn = true;
    IsCommandDone = false;
    
    NSInteger numberWritten = [ikea SendDataToDevice:buffer:length];
    
    // Check for errors
    if (numberWritten == -1) {
        NSLog(@"Error to send command");
        return false;
    } else {
		NSLog(@"numberWritten: %d", numberWritten);
	}
    
    int count = 300;
    while ( count-- ) {
        if ( IsCommandDone )	return true;
        [NSThread sleepForTimeInterval:0.1];
    }
    
    return false;
    
}

-(void)ThreadSendDataToPrinter
{
    NSLog(@"%s",__FUNCTION__);
        
    int  i, j;
    int  retry = 0;
    
    dataOffset = 0;

    NSLog(@"%s started[%d]",__FUNCTION__, dataLength);
    
    while ( ! [self ThreadSendData:(uint8_t *)"W":1] ) [NSThread sleepForTimeInterval:0.1];
    
    char *buf = malloc(printer_packet_length+50);
    
    while ( dataOffset < dataLength ) {
        
        int length = dataLength - dataOffset;
        packet = length >= printer_packet_length ? printer_packet_length : length;
                
        NSString *command = [NSString stringWithFormat:@"bSD%X#", packet];
        const char *temp = [command UTF8String];
        
        for (i = 0; i < [command length]; i++) buf[i] = temp[i];
        for (j = 0; j < packet; j++) buf[i++] = dataBuffer[dataOffset+j];
        
        if ( [self ThreadSendData:(uint8_t *)buf:packet+[command length]])   {
            if ( bPrintResult ) {
                dataOffset += packet;
                retry = 0;
            }
        }
        if ( retry++ == 3 )     break;
    }
    
    NSLog(@"%s finished[%d]",__FUNCTION__, dataOffset);
    
    cmdRead += 3;
    IsCommandOn = false;
    IsCommandDone = true;
    
    free(buf);
    free(dataBuffer);
}
//-----------------------------------------------------------------------------------------
//
//			Synchronization thread
//
//-----------------------------------------------------------------------------------------
-(void)SynchronizeRecord
{	
	for (int i = SyncStartIndex; i < SyncEndIndex; i++) {

		NSString* temp =[NSString stringWithFormat:@"p%x#", i];
		
		for (int j = 0; j < [temp length]; j++) {
			unichar charAscii = [temp characterAtIndex:j];
			commandBuf[j] = charAscii;
		}		
		commandLength = [temp length];
		commandBuf[commandLength] = 0x00;
		IsCommandOn = true;
		IsCommandDone = false;

		[self SendCommand];
			
		int count = 100;
		while ( count-- ) {
			if ( IsCommandDone ) break;
			[NSThread sleepForTimeInterval:0.2];
		}		
	}
		
	cmdRead += 2;	
	cmdArray[cmdWrite++] = 3;
	cmdArray[cmdWrite++] = '1';
	cmdArray[cmdWrite++] = 'S';
	cmdArray[cmdWrite++] = '0';	
}

-(void)SynchronizeOneRecord
{	
		
	NSString* temp =[NSString stringWithFormat:@"p%x#", SyncStartIndex];
		
	for (int j = 0; j < [temp length]; j++) {
		unichar charAscii = [temp characterAtIndex:j];
		commandBuf[j] = charAscii;
	}		
	commandLength = [temp length];
	commandBuf[commandLength] = 0x00;
	IsCommandOn = true;
	IsCommandDone = false;
		
	[self SendCommand];
		
	int count = 100;
	while ( count-- ) {
		if ( IsCommandDone ) break;
		[NSThread sleepForTimeInterval:0.2];
	}		
	
	cmdRead += 2;	
}

-(void)HandleKDCMessage
{
	NSLog(@"%s",__FUNCTION__);
	
	cmdRead += 2;	
	
	int i = 0;
	commandBuf[i++] = 'G';
	commandBuf[i++] = 'M';
	commandBuf[i++] = 'T';

	while (1) {
		if (KDCMessages[i-3] == 0) break;
		commandBuf[i] = KDCMessages[i-3];
		i++;
	}
	commandBuf[i++] = 0x0d;
	commandLength = i;
	commandBuf[commandLength] = 0x00;	

	[self SendCommand];
}

-(void)SendNullData
{
	commandBuf[0] = 0x00;
    commandLength = 1;

    for (int i = 0; i < 3; i++) {
        [self SendCommand];
        [NSThread sleepForTimeInterval:0.01];
    }
        
}

-(void)WakeupCommand
{
	
	cmdRead += 2;
	
	if ( commandBuf[0] == 1 )	[self SendNullData];	
	
	while ( true ) {
		NSLog(@"%s",__FUNCTION__);

		commandLength = 1;
		commandBuf[0] = 'W';
		commandBuf[1] = 0x00;

		IsCommandOn = true;
		IsCommandDone = false;
		
		[self SendCommand];

		int count = 100;
		while ( count-- ) {
			if ( IsCommandDone ) return;
			[NSThread sleepForTimeInterval:0.1];
		}
	}	
}
//-----------------------------------------------------------------------------------------
//
//			Command Sending Thread
//
//-----------------------------------------------------------------------------------------
-(void)CommandThread
{
	NSLog(@"%s",__FUNCTION__);
    
	while ( ! IsConnected ) [NSThread sleepForTimeInterval:0.01];

	
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	while ( true ) {

        //NSLog(@"%s",__FUNCTION__);
		if ( cmdWrite != cmdRead ) {
			commandType = cmdArray[cmdRead+1];
			//NSLog(@"CommandThread++%c[%d:%d]", commandType,cmdWrite, cmdRead);			
			switch( commandType ) {	//Get Command
				case '0':	cmdArray[cmdRead+1] = 'G';	[self ThreadSendCommand];	break;	//Synchronize start
				case '1':	cmdArray[cmdRead+1] = 'G';	[self ThreadSendCommand];	break;	//Synchronize End
				case '2':	[self HandleKDCMessage];	break;
				case '3':	cmdArray[cmdRead+1] = 'G';	[self ThreadSendCommand];	break;	// GPS power/bypass 
                case '4':
                case '5':   cmdArray[cmdRead+1] = 'b';  [self ThreadSendCommand];	break;
				case 'A':
                case 'C':
                case 'D':   
                case 'E':
                case 'F':
				case 'M':   
				case 'V':	
                case 'I':   
				case 'N':	[self ThreadSendCommand];	break;
				case 'p':	[self SynchronizeRecord];	break;
				case 'q':	[self SynchronizeOneRecord];	break;
				case 'b':	[self ThreadSendCommand];	break;
				case 'W':	[self WakeupCommand];		break;
				case 'w':	[self ThreadSendCommand];	break;
                case 10:	
                case 11:	[self ThreadSendCommandEx:300];	break;
                case 12:    [self ThreadSendDataToPrinter];  break;
                case 00:    cmdRead += 2;
                            bLoadView = true;           break;
                case 254:   [self ThreadSendCommandEx:50];
                            IsMenuAlertStarted = false;
                            [appDelegate DisplayAlert:false:nil:nil:false];
                            exit(0);
                case 255:   [self ThreadSendCommandEx:300];   break;
				default:	break;
			}
		}
        [NSThread sleepForTimeInterval:0.1];        
	}
	
//	[pool release];
}
//-----------------------------------------------------------------------------------------
//
//			Recevied barcode data handling 
//
//-----------------------------------------------------------------------------------------
-(float_t)ConvertStringToFloat:(NSString *)string;
{
	//NSLog(@"%s",__FUNCTION__);
	
	float_t floatnumber = [string floatValue];
	int decimal = floatnumber / 100;
	
	return decimal + (floatnumber - decimal*100)/60;
}

-(void)CalcurateLocation
{
	//NSLog(@"%s",__FUNCTION__);
	
	//latitudedecimal = [self ConvertStringToFloat:@"4354.45301"];
	//longitudedecimal = [self ConvertStringToFloat:@"7928.81456"];
	
	latitudedecimal = [self ConvertStringToFloat:[[NSString alloc] initWithFormat:@"%s", latitudestring]];
	longitudedecimal = [self ConvertStringToFloat:[[NSString alloc] initWithFormat:@"%s", longitudestring]];	
	
	if ( bIsSouth )	latitudedecimal = -(latitudedecimal);
	if ( bIsWest )	longitudedecimal = -(longitudedecimal);
	
	
	//if ( bIsSouth ) NSLog(@"South");
	//if ( bIsWest ) NSLog(@"West");
	
	//NSLog(@"%f:%f", latitudedecimal, longitudedecimal);
}

-(void)CopyStringData:(uint8_t *)Source:(uint8_t *)Dest:(int)length;
{
	int i;
	
	for (i = 0; i < length-1; i++) Dest[i] = Source[i];
	Dest[i] = 0x00;
}

-(void)CopyStringDataEx:(uint8_t *)Source:(int)length;
{
	int i;
	
	for (i = 0; i < length-1; i++) StringResponse[StringOffset++] = Source[i];
	StringResponse[StringOffset] = 0x00;
}

-(unsigned int)MakeOneNumber:(uint8_t *)Source;
{
	return (unsigned int)((Source[0] << 24) + (Source[1] << 16) + (Source[2] << 8) + (Source[3]));
}

-(void)GetRecordDelimiter:(uint8_t *)Buffer;
{
	if ( IsWebApp )	return;
	
    switch ( RecordDelimiter ) {
        case 0: return;
        case 1: BarcodeBuffer[BarcodeBufferOffset++] = '\r';    return;
        case 2: BarcodeBuffer[BarcodeBufferOffset++] = '\n';    return;
        case 3: BarcodeBuffer[BarcodeBufferOffset++] = '\t';    return;
        case 4: BarcodeBuffer[BarcodeBufferOffset++] = '\r';
            BarcodeBuffer[BarcodeBufferOffset++] = '\n';    return;
        default: break;
    }
}

-(void)GetDataDelimiter:(uint8_t *)Buffer;
{
	if ( IsWebApp )	return;
	
    switch ( DataDelimiter ) {
        case 0: return;
        case 1: BarcodeBuffer[BarcodeBufferOffset++] = '\t';    return;
        case 2: BarcodeBuffer[BarcodeBufferOffset++] = ' ';     return;
        case 3: BarcodeBuffer[BarcodeBufferOffset++] = ',';     return;
        case 4: BarcodeBuffer[BarcodeBufferOffset++] = ';';     return;
        case 5: BarcodeBuffer[BarcodeBufferOffset++] = '|';     return;
        default: break;
    }
}

-(void)GetBarcodeType:(uint8_t *)Buffer;
{
	BufferOffset++;
	if ( ! IsAttachType )	return;
	
	int type = Buffer[BufferOffset-1] & 0x3f;
	if ( ! IsKDC300 ) {
		if ( type == 20 )	type = 10;
		if ( type == 21 )	type = 11;
		BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "[%s]", typeString[type]);
	} else
		BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "[%s]", hhptypeString[type]);
    
    [self GetDataDelimiter:Buffer];
    
}
-(void)GetBarcodeData:(uint8_t *)Buffer;
{
	for (int i = 0; i < BarcodeLength; i++) BarcodeBuffer[BarcodeBufferOffset++] = Buffer[BufferOffset++];
    if ( ! IsGPSSupported )     return;
    
    BarcodeBuffer[BarcodeBufferOffset] = 0;
    
    char *temp = strstr((const char*)BarcodeBuffer, "<G|P/S]");
    if ( temp == nil ) return;
    
    BarcodeBufferOffset -= strlen(temp);
    
    //NSLog(@"%s:%s[%d:%d]",__FUNCTION__, temp, BarcodeBufferOffset, strlen(temp));
    
    if ( ! IsAttachLocationData ) return;

    int i = 7;
    int cnt = 0;
    
    while (1) {
        if ( temp[i] == ',' )   break;
        latitudestring[cnt++] = temp[i++];
    }
    latitudestring[cnt] = 0;
    i++;
    
    if ( temp[i++] == 'N' ) bIsSouth = false;
    else                    bIsSouth = true;
    
    i++;   
    cnt = 0;
    
    while (1) {
        if ( temp[i] == ',' )   break;
        longitudestring[cnt++] = temp[i++];
    }
    longitudestring[cnt] = 0;
    i++;
    
    if ( temp[i++] == 'W' ) bIsWest = true;
    else                    bIsWest = false;
    
    [self CalcurateLocation];
    
    BarcodeBuffer[BarcodeBufferOffset++] = ';';
    
    if ( temp[i++] == ';' ) {   //Process Altitude data
        
        cnt = 0;
        
        while (1) {
            if ( temp[i] == ',' )   break;
            altitudestring[cnt++] = temp[i++];
        }
        altitudestring[cnt] = 0;
        
        NSString *temp = [[NSString alloc] initWithFormat:@"%s", altitudestring];
        
        BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "%f,%f,%.1f", latitudedecimal, longitudedecimal, [temp floatValue]);
    } else 
        BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "%f,%f", latitudedecimal, longitudedecimal);
}


-(void) AttachSerialNumber:(uint8_t *)Buffer;
{
	BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "%s", SerialNo);
}

-(void) GetTimeStamp:(uint8_t *)Buffer:(int)offset:(unsigned int *)datedata:(unsigned int *)timedata;
{
	*datedata = (Buffer[offset]*256) + (Buffer[offset+1]);
	*timedata = (Buffer[offset+2]*256) + (Buffer[offset+3]);	
}

-(void) AttachTimestamp:(uint8_t *)Buffer;
{
	//datedata = (Buffer[BufferOffset]*256) + (Buffer[BufferOffset+1]);
	//timedata = (Buffer[BufferOffset+2]*256) + (Buffer[BufferOffset+3]);
	
	unsigned int datedata = LastDateValue;
	unsigned int timedata = LastTimeValue;
	
	BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "[%d:%d:%d/%d:%d:%d]",
									((datedata & 0xfc00) >> 10)+2000,	//year
									((datedata & 0x3c0) >> 6),	//Month
									((datedata & 0x3e) >> 1),			//Day
									(datedata & 0x1 ) ? (((timedata & 0xf000) >> 12)+12) : ((timedata & 0xf000) >> 12),	//hour
									((timedata & 0xfc0) >> 6),	//min
								   ((timedata & 0x3f)));	//sec
	BufferOffset += 4;
}

-(void) AttachQuantity:(uint8_t *)Buffer:(int)offset;
{
    int quantity = 0;
    
    if ( Buffer[offset] != 0xff ) return;
    
    [self GetDataDelimiter:Buffer];
        
    quantity = (Buffer[offset+1] & 0x7f);
    
    BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "%d", quantity);
}

-(void)GetBarcodeLength:(uint8_t *)Buffer;
{
	if ( ! IsKDC300 )	BarcodeLength = Buffer[BufferOffset++] - 5;
	else {
		BarcodeLength = (Buffer[BufferOffset]*256 + Buffer[BufferOffset+1]) - 7;
		BufferOffset += 2;
	}			
	
}
//-----------------------------------------------------------------------------------------
//
//			Recevied MSR data handling 
//
//-----------------------------------------------------------------------------------------
-(void)DecryptData
{
    NSLog(@"Decryption is started..\n");
    
    BarcodeBufferOffset = DecryptMSRData(BarcodeBuffer, BarcodeBuffer, BarcodeBufferOffset);
    BarcodeBuffer[BarcodeBufferOffset] = 0;
    
    NSString* temp =[NSString stringWithFormat:@"%s", BarcodeBuffer];
    
    NSRange MSR = [temp rangeOfString:@"<M/S|R]"];
    
    BarcodeBufferOffset = MSR.location;
}

-(bool)HandleMSRData:(uint8_t *)Buffer;
{
    unsigned char type = Buffer[BufferOffset];
    
    if ( (type & 0x7f) != 0x7e )    return false;
    
    BufferOffset++;
    NSLog(@"MSR Data is detected\n");
    
    [self GetBarcodeData:Buffer];
    
    if ( type == 0xfe ) [self DecryptData];
    
	[self GetTimeStamp:Buffer:BufferOffset:&LastDateValue:&LastTimeValue];
    
	if ( IsAttachTimestamp )	{
        [self GetDataDelimiter:Buffer];
        [self AttachTimestamp:Buffer];
	}
    
	[self GetRecordDelimiter:Buffer];
	
	BarcodeBuffer[BarcodeBufferOffset] = 0x00;    
    
    return true;
}

//-----------------------------------------------------------------------------------------
//
//			Recevied GPS data handling 
//
//-----------------------------------------------------------------------------------------


-(bool)IsValidGPSData:(uint8_t *)BarcodeBuffer:(int)length;
{
	//NSLog(@"%s",__FUNCTION__);
	
	int i = 0;
	int offset;
	int state = 0;
	char ch;
	
	while ( i < length ) {
		ch = BarcodeBuffer[i++];
		
		switch (state) {
			case 0:		if ( ch == ',' )	state = 1;
						break;
			case 1:		if ( ch == ',' )	state = 2;
						break;
			case 2:		if ( ch == 'V' )	return false;
						state = 3;
						offset = 0;
						break;
			case 3:		if ( ch == ',' )	state = 10;
						break;
// Get Latitude				
			case 10:	if ( ch == ',' )	{
							state = 11;
							latitudestring[offset] = 0;
							offset = 0;
						} else 
							latitudestring[offset++] = ch;
						break;
			case 11:	if ( ch == 'S' )	bIsSouth = true;
						else				bIsSouth = false;
						state = 12;
						break;
			case 12:	if ( ch == ',')	state = 20;
						break;
// Get Longitude				
			case 20:	if ( ch == ',' )	{
							state = 21;
							longitudestring[offset] = 0;
							offset = 0;
						} else
							longitudestring[offset++] = ch;
						break;
			case 21:	if ( ch == 'W' )	bIsWest = true;
						else				bIsWest = false;
						state = 30;
			default:	break;
		}	//case
		if ( state == 30 )	break;
	}	// while
	[self CalcurateLocation];
	return true;
}

-(void)MakeGPSDataEx:(uint8_t *)BarcodeBuffer:(int)length;
{
	//NSLog(@"%s",__FUNCTION__);
	
	if ( ! [self IsValidGPSData:BarcodeBuffer:length] )	return;
	
    if ( IsAlertEnabled )   [appDelegate DisplayAlert:false:nil:nil:true];
    
	if ( (latitudedecimal != latitudedecimal_backup) || (longitudedecimal != longitudedecimal_backup) ) {
		latitudedecimal_backup = latitudedecimal;
		longitudedecimal_backup = longitudedecimal;
		
		if ( latitudedecimal > 90 )	return;
		if ( latitudedecimal < -90 )	return;
		if ( longitudedecimal > 180 )	return;
		if ( longitudedecimal < -180 )	return;
		
		[mapDelegate setLocation:latitudedecimal:longitudedecimal];	
	}
}

-(void)MakeGPSData:(uint8_t *)ReadBuffer:(int)length;
{
	int i;
	
	for (i = 0; i < length; i++) BarcodeBuffer[i] = ReadBuffer[i];
	BarcodeBuffer[i] = 0x00;
	
    if ( BarcodeBuffer[0] != '$' )  return;
    
	if ( strstr((const char*)BarcodeBuffer, "$GPRMC") != nil ) {
		if ( mapDelegate != nil )	return [self MakeGPSDataEx:BarcodeBuffer:length];	
		
        if ( IsAlertEnabled )   [appDelegate DisplayAlert:false:nil:nil:true];
    }
        [gpsDelegate DisplayGPSLog:(char *)BarcodeBuffer];
	//}	
}
//======================================================================================
//
//  Handle incomming data
//
//======================================================================================
-(void)HandlePacketData:(uint8_t *)Buffer:(int)length;
{	
    int appoffset;
    
	BufferOffset = 4;
	BarcodeBufferOffset = 0;
    
    BarcodeBuffer[BarcodeBufferOffset] = 0x00;
	
	[self GetBarcodeLength:Buffer];
    
    if ( [self HandleMSRData:Buffer] )  return;
    
	if ( IsSupportPartialSync ) appoffset = length - 4 - 4;
	else                        appoffset = length - 4;
    
    
    NSLog(@"BarcodeLength[%d],length[%d],appoffset[%d],data[%x]\n", BarcodeLength, length, appoffset, Buffer[appoffset]);
    
    if ( Buffer[appoffset] == 0xff ) {   //Application Data
        BarcodeLength -= 2;
        if ( (! IsSyncNonCompliant) && (Buffer[appoffset+1] & 0x80 ) )  return;
    }
    
    
	if ( IsAttachSerial )	{
        [self AttachSerialNumber:Buffer];
        [self GetDataDelimiter:Buffer];
    }
	[self GetBarcodeType:Buffer];
	[self GetBarcodeData:Buffer];
	[self GetTimeStamp:Buffer:BufferOffset:&LastDateValue:&LastTimeValue];
    
	if ( IsAttachTimestamp )	{
        [self GetDataDelimiter:Buffer];
        [self AttachTimestamp:Buffer];
	}
    
    if ( IsAttachQuantity ) {   //Application Data
        [self AttachQuantity:Buffer:appoffset];
    }
	if ( IsSupportPartialSync ) {
		LastBarcodeIndex = [self MakeOneNumber:&Buffer[length-5]];
		//BarcodeBufferOffset += sprintf((char *)(BarcodeBuffer+BarcodeBufferOffset), "[%d]", LastBarcodeIndex+1);	
	}
	[self GetRecordDelimiter:Buffer];
	
	BarcodeBuffer[BarcodeBufferOffset] = 0x00;
    
}
-(void)MakeBarcodeStringEx:(uint8_t *)ReadBuffer:(int)length;
{	

	TotalDataLength = 0;
	BarcodeBuffer[0] = 0x00;
    
    NSLog(@"%s[%d]\n", __FUNCTION__, length);

	[self HandlePacketData:ReadBuffer:length];
	
	if ( BarcodeBuffer[0] != 0x00 )	[appDelegate BarcodeDataArrived:(char *)BarcodeBuffer];	
	
}

-(void)MakeBarcodeString:(uint8_t *)ReadBuffer:(int)length;
{	
	int i = 0;

	NSLog(@"%s", __FUNCTION__);

	if ( (ReadBuffer[0] == 0x03) && (TotalDataLength == 0) ) {
        NSLog(@"Packet Data\n");        
		CurrentDataLength = 0;
		TotalDataLength = (unsigned int)((ReadBuffer[1] << 16) + (ReadBuffer[2] << 8) + ReadBuffer[3] + 6);
		//6 means 0x3 + @ + index(4 bytes)
		if ( length == TotalDataLength )	[self MakeBarcodeStringEx:ReadBuffer:length];
		else {
			for (i = 0; i < length; i++ ) TempDataBuffer[CurrentDataLength+i] = ReadBuffer[i];
			CurrentDataLength += length;
		}
	} else {
        
        NSLog(@"%s[%d/%d]\n",__FUNCTION__, CurrentDataLength, TotalDataLength);
        
		if ( CurrentDataLength != 0 ) {	//Large Data
			for (i = 0; i < length; i++) TempDataBuffer[CurrentDataLength+i] = ReadBuffer[i];
			CurrentDataLength += length;
			if ( CurrentDataLength == TotalDataLength )	[self MakeBarcodeStringEx:TempDataBuffer:TotalDataLength];
		} else { //Barcode Only or GPS Data
			if ( IsGPSUsing )	[self MakeGPSData:ReadBuffer:length];            
			else {
                NSLog(@"Barcode Only\n");
/*                
                if ( (ReadBuffer[0] == '$') && (ReadBuffer[1] == 'G') && (ReadBuffer[2] == 'P') )   return;
				for (i = 0; i < length; i++) BarcodeBuffer[i] = ReadBuffer[i];
				BarcodeBuffer[i] = 0x00;
				[appDelegate BarcodeDataArrived:(char *)BarcodeBuffer];
*/
            }
		}
	}
}

//======================================================================================
//
//  Handle command responses
//
//======================================================================================
-(bool)IsNeedPartialSynchronize:(uint8_t *)ReadBuffer:(int)length;
{
	unsigned int datevalue;
	unsigned int timevalue;
	
	[self GetTimeStamp:ReadBuffer:(length-10):&datevalue:&timevalue];
	
	if ( (datevalue != LastDateValue) || (timevalue != LastTimeValue) )	return false;
	
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'N';
	
	return true;
}

-(void)DoPartialSynchronize;
{

	NSLog(@"%s", __FUNCTION__);
	
	if ( SyncEndIndex != LastBarcodeIndex+1 )	{	
		IsCommandDone = true;
		IsSynchronizeOn = true;
		[self Synchronize:LastBarcodeIndex+1];
	}
}


-(void)InitGPSSetting
{
	NSLog(@"%s",__FUNCTION__);
	
	if ( IsGPSSupported ) {
		if ( gpsDelegate != nil ) {
			IsGPSUsing = true;
			[self SetGPSPowerMode:true:true:false];
		} else {
			[self SetGPSPowerMode:IsGPSEnabled:false:false];
        }
	}	
}

-(void)InitialSetting
{
    
    NSLog(@"%s",__FUNCTION__);
    
    IsKDC300 = false;
    IsGPSSupported = false;
    IsSupportPartialSync = false;
    IsMSREnabled = false;
    
    if ( FWVersion[5] == '3' )	{
        IsKDC300 = true;
        if ( (FWVersion[6] == '5') && (FWVersion[2] == '1') ) IsKDC300 = false;
    }
    if ( (FWVersion[5] == '2') && (FWVersion[6] == '5') )	IsGPSSupported = true;
    if ( FWVersion[9] >= '9' )	IsSupportPartialSync = true;
    if ( FWVersion[5] == '4' ) {
        IsMSREnabled = true;
        if ( FWVersion[6] == '2' )  IsKDC300 = true;
        if ( FWVersion[6] == '5' )  IsKDC300 = true;
    }
    if ( FWVersion[0] == '3' ) {    //V3.00
        IsSupportPartialSync = true;
    }
    
    printer_packet_length = 240;
    
    TotalDataLength = 0;
    
}

-(void)InitializeMSRData
{
    [self SetMSRDataFormat:1];
    [self SendCommandGetResult:11:48:"GnMkG":5];
    [self SendCommandGetResult:11:49:"GnMKG":5];
}

-(void)TruncateSerialNumber:(int)length
{
	int i;
	
	for (i = 0; i < length; i++) {
		if ( SerialNo[i] == '@' ) break;
	}
	SerialNo[i] = 0;
}

-(void)SetBitInformation:(uint8_t *)Buffer:(uint32_t)bitmask
{
    KDCSetting &= ~(bitmask);
    if ( [self MakeOneNumber:Buffer] == 1 ) KDCSetting |= bitmask;
}

-(void)SetBitInformationEx:(uint8_t *)Buffer:(uint32_t)bitmask
{
    OptionSetting &= ~(bitmask);
    if ( [self MakeOneNumber:Buffer] == 1 ) OptionSetting |= bitmask;
}

-(void)SelectTracks:(uint8_t *)Buffer
{
    KDCSetting &= ~(0x00001C00);
    if ( [self MakeOneNumber:Buffer] & 0x01 ) KDCSetting |= 0x00000400;
    if ( [self MakeOneNumber:Buffer] & 0x02 ) KDCSetting |= 0x00000800;
    if ( [self MakeOneNumber:Buffer] & 0x04 ) KDCSetting |= 0x00001000;    
}

-(void)SetBTOptions:(uint8_t *)Buffer
{
    KDCSetting &= ~(0x000000FD);
 
    KDCSetting |= ([self MakeOneNumber:Buffer] & 0x000000FD);
}

-(void)SetFixData:(uint8_t *)Buffer:(char *)dest:(int)length
{    
    int i;
    for (i = 0; i < length; i++) {
        if ( Buffer[i] == '@' )  break;
        dest[i] = (char)Buffer[i];
    }
    dest[i] = 0;
}

-(bool)MakeNewPrinterList
{
    NSLog(@"%s[%d:%s]",__FUNCTION__, TotalDataLength, TempDataBuffer);
    
    int offset = 1;
    int index = 1;  // Start index of printer
//Get MAC address
    while ( TempDataBuffer[offset] != 0xfe ) {
        TempDataBuffer[offset+12] = 0;
        NSString* temp =[NSString stringWithFormat:@"%s", TempDataBuffer+offset];
        NSLog(@"%@", temp);
        [listOfMAC replaceObjectAtIndex:index++ withObject:temp];
        offset += 16;
    }
    offset++;
    index = 1;
//Get Friendly name
    while( TempDataBuffer[offset] != 0xfe ) {
        int i = offset;
        while ( TempDataBuffer[i++] != 0xAA )  ;
        TempDataBuffer[i-1] = 0;
        NSString* temp =[NSString stringWithFormat:@"%s", TempDataBuffer+offset];
        NSLog(@"%@", temp);
        [listOfPrinters replaceObjectAtIndex:index++ withObject:temp];
        offset = i;
    }
    
    if ( index > 1 ) {
        for (int i = index; i < 12; i++) {
            [listOfPrinters addObject:@""];
            [listOfMAC addObject:@""];
        }
	}
    
    TotalDataLength = 0;
    return true;
}

-(bool)RefreshPrinterList:(uint8_t *)Buffer:(int)length;
{
    NSLog(@"%s[%d:%d]",__FUNCTION__, length, TotalDataLength);
    
    if ((Buffer[0] == '!') && (TotalDataLength == 0))   return true; //No new device available
    
    for(int i = 0; i < length; i++) TempDataBuffer[TotalDataLength+i] = Buffer[i];
    TotalDataLength += length;
    
    if ( (Buffer[length-1] == 0xfe) && (Buffer[length-2] == 0xfe) ) return [self MakeNewPrinterList];
    return false;
}

-(void)HandleCommandData:(uint8_t *)Buffer:(int)length;
{
    NSLog(@"%s",__FUNCTION__);
    
    int tmp;
    
	BarcodeBuffer[0] = 0x00;
	switch ( commandType ) {

        case 10:    [self CopyStringDataEx:Buffer:length];
                    NSLog(@"%s[%d]",__FUNCTION__, __LINE__);
                    [viewDelegate loadView:viewIndex];
                    break;
        case 11:    
                    switch ( subcmdType ) {
                        case 1: BarcodeStored = [self MakeOneNumber:Buffer];    break;
                        case 2: MemoryLeft = [self MakeOneNumber:Buffer];       break;
                        case 3: SleepTimeout = [self MakeOneNumber:Buffer];     break;
                        case 4: [self SetBitInformation:Buffer:0x00002000];     break;  //beep sound
                        case 5: [self SetBitInformation:Buffer:0x00010000];     break;  //beep volume
                        case 6: [self SetBitInformation:Buffer:0x00004000];     break;  //auto erase     
                        case 7: [self SetBitInformation:Buffer:0x00008000];     break;  //menu barcode
                        case 8: [self CopyStringData:Buffer:DateTime:7];        break;  //date/time
                        case 9: MSRDataFormat = [self MakeOneNumber:Buffer];    break;
                        case 10: TrackTerminator = [self MakeOneNumber:Buffer]; break;
                        case 11: [self SetBitInformation:Buffer:0x00000200];    break;  //Encrypt MSR
                        case 12: [self SelectTracks:Buffer];                    break; //Track select
                        case 13: HIDAutoLock = [self MakeOneNumber:Buffer];     break;
                        case 14: HIDKeyboard = [self MakeOneNumber:Buffer];     break;
                        case 15: HIDInitDelay = [self MakeOneNumber:Buffer];    break;
                        case 16: HIDCharDelay = [self MakeOneNumber:Buffer];    break;
                        case 17: HIDCtrlChar = [self MakeOneNumber:Buffer];     break;
                        case 18: ConnectDevice = [self MakeOneNumber:Buffer];   break;
                        case 19: [self SetBTOptions:Buffer];                    break;
                        case 20: PowerOnTime = [self MakeOneNumber:Buffer];     break; 
                        case 21: PowerOffTime = [self MakeOneNumber:Buffer];    break;  
                        case 22: WedgeStore = [self MakeOneNumber:Buffer];      break;
                        case 23: DataFormat = [self MakeOneNumber:Buffer];      break;
                        case 24: Terminator = Buffer[0] - (char)'0';            break;
                        case 25: [self SetBitInformation:Buffer:0x00000002];    break;
                        case 26: AimID = [self MakeOneNumber:Buffer];           break;
                        case 27: StartPosition = [self MakeOneNumber:Buffer];   break;
                        case 28: NoOfChars = [self MakeOneNumber:Buffer];       break;
                        case 29: Action = [self MakeOneNumber:Buffer];          break;
                        case 30: [self SetFixData:Buffer:Prefix:length];        break;
                        case 31: [self SetFixData:Buffer:Suffix:length];        break;
                        case 32: OptionSetting = [self MakeOneNumber:Buffer];   break;                         
                        case 33: SecurityLevel = [self MakeOneNumber:Buffer];   break;                            
                        case 34: ReadingTimeout = [self MakeOneNumber:Buffer];  break;  
                        case 35: MinimumLength = [self MakeOneNumber:Buffer];   break;  
                        case 36: [self SetBitInformation:Buffer:0x00000100];    break;
                        case 37: RereadDelay = [self MakeOneNumber:Buffer];     break;
                        case 38: BarcodeSetting = [self MakeOneNumber:Buffer];  break;
                        case 39: BarcodeSettingHHP_1 = [self MakeOneNumber:Buffer];
                                 BarcodeSettingHHP_2 = [self MakeOneNumber:(Buffer+4)]; break;       
                        case 40: BarcodeOptionHHP_1 = [self MakeOneNumber:Buffer];
                                 BarcodeOptionHHP_2 = [self MakeOneNumber:(Buffer+4)]; break;
                        case 41: [self SetBitInformation:Buffer:0x00020000];    break;  //MSR Beep On Error
                        case 42: tmp = [self MakeOneNumber:Buffer];
                                 if ( tmp == 1 )    bIsPrinterConnected = true;
                                 break;
                        case 43: if ( [self RefreshPrinterList:Buffer:length] ) break;
                                 else                                           return;
                        case 44: if ( Buffer[0] == '@' )    bIsPrinterConnected = true;
                                 else                       bIsPrinterConnected = false;
                                 break;
                        case 45: MSRStartPosition = [self MakeOneNumber:Buffer];   break;
                        case 46: MSRNoOfChars = [self MakeOneNumber:Buffer];       break;
                        case 47: MSRAction = [self MakeOneNumber:Buffer];          break;         
                        case 48: AESKeyLength = [self MakeOneNumber:Buffer];       break;
                        case 49: [self SetFixData:Buffer:Key:length];           break;
                        case 50: if ( Buffer[0] != '!' ) printer_packet_length = [self MakeOneNumber:Buffer];
                                 break;
                        default:    break;
                    }
                    if ( bLoadView )    {
                        [appDelegate DisplayAlert:false:nil:nil:false];
                        [viewDelegate loadView:viewIndex];
                    }
                    bLoadView = false;
                    break;
        case 12:    //Send file data to printer
                    bPrintResult = false;
                    if ( Buffer[0] == 1 )   return;
                    if ( Buffer[0] == '!')  break;
                    bPrintResult = true;
                    if ( IsMenuAlertStarted )    {
                        if ( (( (dataOffset+packet) % 1024 ) == 0 ) || ((dataOffset + packet) == dataLength) ) {
                            [viewDelegate loadView:dataOffset+packet];
                        }
                    }
                
                    break;
        case '3':   //GPS Command
                    if ( Buffer[0] != '@' ) return;
                    break;
		case '4':	[self CopyStringData:Buffer:MacAddress:length];	
                    [self InitialSetting];	break; 
		case '5':	
                    [self CopyStringData:Buffer:BTVersion:length];	
                    [self InitialSetting];	break;             
		case 'A':	//[appDelegate DisplayConnectionStatus];
					break;
		case 'M':	if ( Buffer[10] != '@' ) return;
					[self CopyStringData:Buffer:SerialNo:length];	
					[self TruncateSerialNumber:length]; break;
            
		case 'V':	if ( Buffer[10] != '@' ) return;
					[self CopyStringData:Buffer:FWVersion:length];	
					[self InitialSetting];	break;
		case 'I':	
                    [self CopyStringData:Buffer:FWBuild:length];	
                    [self InitialSetting];	break;            
		case 'N':	SyncEndIndex = [self MakeOneNumber:Buffer];	
					if ( IsPartialSyncStarted ) {
						IsPartialSyncStarted = false;
						[self DoPartialSynchronize];
					}
					break;
		case 'p':	[self MakeBarcodeString:Buffer:length];			break;
		case 'q':	if ( [self IsNeedPartialSynchronize:Buffer:length] )		IsPartialSyncStarted = true;
					break;
		case 'w':	//if ( ! IsSupportPartialSync )	[appDelegate DisplayConnectionStatus];
					//else							[self SendCTS];
                    [self InitGPSSetting];
					//[appDelegate DisplayConnectionStatus];
                    //if (  ! IsGPSUsing )  [appDelegate DisplayAlert:false:nil:nil:true];
                    if ( IsMSREnabled )   [self InitializeMSRData];

					break;
        case 'C':
        case 'E':
        case 'F':   
        case 254:   [appDelegate DisplayAlert:false:nil:nil:false]; break;
        case 'W':   if ( IsMenuAlertStarted ) {
                        IsMenuAlertStarted = false;
                        [appDelegate DisplayAlert:false:nil:nil:false];
                        if ( commandType == 12 ) [viewDelegate loadView:0];
                    }
                    break;
		default:	break;
	}
	if ( commandType == '1' )	[appDelegate SynchronizeFinished];
	IsCommandDone = true;
}
//-----------------------------------------------------------------------------------------
//
//			Initialization Functions
//
//-----------------------------------------------------------------------------------------
-(bool)InitKDC;
{
	NSLog(@"%s",__FUNCTION__);
	
	if ( commandThread == nil ) {
		commandThread = [[NSThread alloc] initWithTarget:self
													  selector:@selector(CommandThread)
														object:nil];
		[commandThread start];

	}

    IsCommandDone = true;
    cmdRead = cmdWrite = 0;
    
	//[self WakeupKDC:true];

	IsGPSUsing = false;
	
    if ( gpsDelegate != nil )   [self SendNullData];
	if ( IsFirstConnect || IsMultiOS ) {
		//[NSThread sleepForTimeInterval:2.0];        
		[self GetSerialNumber];
		[NSThread sleepForTimeInterval:0.2];
		[self GetFWVersion];
		[NSThread sleepForTimeInterval:0.2];
		[self GetFWBuild];
		[NSThread sleepForTimeInterval:0.2];        
		[self GetBTMACAddress];
		[NSThread sleepForTimeInterval:0.2];
		[self GetBTVersion];
		[NSThread sleepForTimeInterval:0.2];           
		IsFirstConnect = false;
	}
	[self SetWedgeMode:true];
	//[self SendCTS];

	return true;
}

-(void)ReadSettings
{
	NSLog(@"%s",__FUNCTION__);
	
	char KTSyncRegistry[256];
	
	for (int i = 0; i < 256; i++)	KTSyncRegistry[i] = '0';
	
	[fileDelegate ReadRegistry:REGISTRY_FILE:KTSyncRegistry];	
	IsDisconnect = false;
	IsAttachTimestamp = false;
	IsAttachType = false;
	IsAttachSerial = false;
	//IsSyncToFile = false;
	IsExit = false;
	IsAllSync = false;
	IsPartialSync = false;
	IsIdle = false;
	IsGPSEnabled = false;
    IsAttachLocationData = false;
    
    IsSyncNonCompliant = false;
    IsConsolidateData = false;
    IsAttachQuantity = false;
    
    IsEraseKDCMemory = false;
    
    IsDisplayScanButton = false;
	
	if ( KTSyncRegistry[0] == '1' )	IsDisconnect = true;
	if ( KTSyncRegistry[1] == '1' )	IsAttachTimestamp = true;
	if ( KTSyncRegistry[2] == '1' )	IsAttachType = true;
	if ( KTSyncRegistry[3] == '1' )	IsAttachSerial = true;
	//if ( KTSyncRegistry[4] == '1' )	IsSyncToFile = true;	
	if ( KTSyncRegistry[5] == '1' )	IsExit = true;
	if ( KTSyncRegistry[6] == '1' )	IsAllSync = true;
	if ( KTSyncRegistry[7] == '1' )	IsPartialSync = true;
	if ( KTSyncRegistry[8] == '1' )	IsIdle = true;
	SyncDestination = KTSyncRegistry[9] - '0';
	if ( KTSyncRegistry[10] == '1' ) IsGPSEnabled = true;
    if ( KTSyncRegistry[11] == '1' ) IsAttachLocationData = true;
    RecordDelimiter = KTSyncRegistry[12] - '0';
    DataDelimiter = KTSyncRegistry[13] - '0';
    
    if ( KTSyncRegistry[14] == '1' ) IsSyncNonCompliant = true;
    if ( KTSyncRegistry[15] == '1' ) IsConsolidateData = true;
    if ( KTSyncRegistry[16] == '1' ) IsAttachQuantity = true;
    
    if ( KTSyncRegistry[17] == '1' ) IsEraseKDCMemory = true;
    
    if ( KTSyncRegistry[18] == '1' ) IsDisplayScanButton = true;
	
	if ( (SyncDestination < 0) || (SyncDestination > 2) )	SyncDestination = 1;
	if ( (RecordDelimiter < 0) || (RecordDelimiter > 4) )	RecordDelimiter = 4;  
	if ( (DataDelimiter < 0) || (DataDelimiter > 5) )	DataDelimiter = 1;     
}

-(void)SaveSettings
{
	NSLog(@"%s",__FUNCTION__);
	
	NSString *RegString = @"";
	
	char KTSyncRegistry[256];
	for (int i = 0; i < 256; i++)	KTSyncRegistry[i] = '0';
	
	if ( IsDisconnect )			KTSyncRegistry[0] = '1';
	if ( IsAttachTimestamp )	KTSyncRegistry[1] = '1';
	if ( IsAttachType)			KTSyncRegistry[2] = '1';
	if ( IsAttachSerial)		KTSyncRegistry[3] = '1';
	//if ( IsSyncToFile )			KTSyncRegistry[4] = '1';
	if ( IsExit )				KTSyncRegistry[5] = '1';
	if ( IsAllSync )			KTSyncRegistry[6] = '1';
	if ( IsPartialSync )		KTSyncRegistry[7] = '1';
	if ( IsIdle )				KTSyncRegistry[8] = '1';
	KTSyncRegistry[9] = SyncDestination + '0';
	if ( IsGPSEnabled )			KTSyncRegistry[10] = '1';
    if ( IsAttachLocationData ) KTSyncRegistry[11] = '1';
    KTSyncRegistry[12] = RecordDelimiter + '0';
    KTSyncRegistry[13] = DataDelimiter + '0';	

    if ( IsSyncNonCompliant )   KTSyncRegistry[14] = '1';
    if ( IsConsolidateData )    KTSyncRegistry[15] = '1';
    if ( IsAttachQuantity )     KTSyncRegistry[16] = '1';
    
    if ( IsEraseKDCMemory )     KTSyncRegistry[17] = '1';
    
    if ( IsDisplayScanButton)   KTSyncRegistry[18] = '1';
    
	KTSyncRegistry[19] = 0;
	
	[fileDelegate SaveRegistry:REGISTRY_FILE:KTSyncRegistry:RegString];
	
	//[appDelegate SaveEmailSettings];
}

- (void)StopTimer
{

	//NSLog(@"%s", __FUNCTION__);
	
	if ( kdcTimer != nil ) {
		[kdcTimer invalidate];
		kdcTimer = nil;
	}
}

- (void)ResetTimer
{

	//NSLog(@"%s", __FUNCTION__);

	[self StopTimer];
	
	if ( ! IsIdle )	return;
	
	kdcTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
						target:self 
						selector:@selector(IdleTimerHappened)
						userInfo:nil
						repeats:NO];	
}
//-----------------------------------------------------------------------------------------
//
//			Called from Application
//
//-----------------------------------------------------------------------------------------
- (void)SetGPSAppDelegate:(id)gpsDel
{
	NSLog(@"%s",__FUNCTION__);
	
	gpsDelegate = gpsDel;
}

- (void)SetMapAppDelegate:(id)mapDel
{
	NSLog(@"%s",__FUNCTION__);
	
	mapDelegate = mapDel;
}

- (void)SetApplicationDelegate:(id)appDel
{
	appDelegate = appDel;
}

- (void)SetFileManagerDelegate:(id)fileDel
{
	fileDelegate = fileDel;
}

- (void)SetViewDelegate:(id)viewDel:(int)index
{
    viewDelegate = viewDel;
    viewIndex = index;
}

- (void)ConnectDevice
{	
	NSLog(@"%s", __FUNCTION__);	
	// Init iKEA library class
	self.ikea = [[iKEA alloc] init];	
	
	// Init iKEA variables	
	[ikea SetDeviceDelegate:self];				// Callback delegate
	//[ikea SetDeviceProtocol:"com.koamtac.kdc"];	// External device protocol
		
	[self ReadSettings];
	// Check if session is opened with external device

	IsFirstConnect = true;
	//bool result = 
	[ikea CheckIfDeviceConnected];
	//if ( result )	[self InitKDC];
	[self StopTimer];
}
	
- (void)DisconnectDevice
{
	NSLog(@"%s", __FUNCTION__);
	
	[self SaveSettings];
	
	if ( IsDisconnect ) {
		[self BluetoothPower:false]; 
		[NSThread sleepForTimeInterval:1.5];
	}
}

- (void)IdleTimerHappened
{
	[self SaveSettings];
	
	if ( IsIdle ) {
		[self BluetoothPower:false]; 
		[NSThread sleepForTimeInterval:1.5];
	}
	[self StopTimer];
}
//-----------------------------------------------------------------------------------------
//
//			Called from iKEA
//
//-----------------------------------------------------------------------------------------
-(void)StartPartialSynchronize;
{
    
	NSLog(@"%s", __FUNCTION__);
    
	if ( !IsSupportPartialSync )	return;
    
	SyncStartIndex = LastBarcodeIndex;
	
	cmdArray[cmdWrite++] = 1;
	cmdArray[cmdWrite++] = 'q';	
	
}
- (void)DeviceConnected
{
	IsConnected = true;
	IsWaiting = true;
	//[appDelegate DisplayConnectionStatus];
    
	[self InitKDC];
    
	if ( LastBarcodeIndex == -1 && ( IsAllSync || IsPartialSync) )	[appDelegate StartSynchronize];
	else if ( IsPartialSync )										[self StartPartialSynchronize];
}

- (void)DeviceDisconnected
{
    
	NSLog(@"%s", __FUNCTION__);
    
	[self SaveSettings];
	
	IsConnected = false;
	//[appDelegate DisplayConnectionStatus];
    
	if ( IsExit )	[appDelegate DeviceDisconnected];
}

-(void)DataFromDevice:(uint8_t *)ReadBuffer:(int)length;
{	
	if ( IsCommandDone ) { //Wedge Barcode Data
        
		NSLog(@"Barcode\n");
        
		[self MakeBarcodeString:ReadBuffer:length];			
	} else { // Command Data
        
		NSLog(@"Command\n");
        
		[self HandleCommandData:ReadBuffer:length];
	}
	[self ResetTimer];
}
//=========================================================================================
//
//
//
@end
