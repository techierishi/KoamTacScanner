//
//  FileHandle.m
//  KTSync
//
//  Created by Ben Yoo on 10. 3. 26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileHandle.h"
#import "common.h"

#define	BARCODE_DIRECTORY	[NSString stringWithFormat:@"/var/mobile/Media/DCIM/myData"]

@implementation FileHandle

@synthesize paths;
@synthesize fileManager;

- (void)CreateBarcodeDirectory
{
	BOOL	IsDir = YES;

	if ( IsMultiOS )	return;
	
	fileManager = [NSFileManager defaultManager];
	
	if ( ![fileManager fileExistsAtPath:BARCODE_DIRECTORY isDirectory:&IsDir] ) {
		if ( ![fileManager createDirectoryAtPath:BARCODE_DIRECTORY  withIntermediateDirectories:YES attributes:nil error:nil] )
			NSLog(@"Error to create folder %@", BARCODE_DIRECTORY);
	} else 
		NSLog(@"%@ is existed", BARCODE_DIRECTORY);

}

- (void)WriteDataToFile:(int)path:(NSString *)filename:(NSString *)data:(NSString *)content; 
{
	NSLog(@"%s%@\r\n%@",__FUNCTION__, filename, data);
	
	NSString *destDirectory;
	
	//get the documents directory:
	if ( path == CACHE )	{
		paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
		destDirectory= [paths objectAtIndex:0];
	}
	if ( path == DOCUMENT) {
		if ( IsMultiOS ) {
			NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
			destDirectory = [docPaths objectAtIndex:0];
		} else
			destDirectory = BARCODE_DIRECTORY;
	}
	
	NSString *fileName = [NSString stringWithFormat:@"%@/%@", destDirectory, filename];
	//create content - four lines of text
	NSString *filecontent = [NSString stringWithFormat:@"%@",data];
	//save content to the documents directory
	[filecontent writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
	
}

- (NSString *)GetDirectory:(int)path
{
	//get the documents directory:
	if ( path == CACHE )	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if ( path == DOCUMENT)	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *destDirectory = [paths objectAtIndex:0];
    
    return destDirectory;
}

- (NSArray *)GetFileList:(int)path
{
    
	NSString *destDirectory = [self GetDirectory:path];
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:destDirectory error:nil];

    return contentOfFolder;
//	NSLog(@"contentOfFolder: %@", contentOfFolder);
//[fileManager fileExistsAtPath:fileName];
//[fileManager removeItemAtPath:fileName error:NULL];
//[fileManager release];
}

- (NSString *)ReadDataFromFile:(int)path:(NSString *)filename:(char *)data;
{

	NSString *destDirectory = [self GetDirectory:path];
	
	//make a file name to write the data to using the documents directory:
	NSString *fileName = [NSString stringWithFormat:@"%@/%@", destDirectory, filename];
	//NSString
	NSString *filecontent = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:nil error:nil];
	//use simple alert from my library (see previous post for details)
	
    //NSData *binData = [NSData dataWithContentsOfFile:fileName];
    
    //NSLog(@"%s[%d]",__FUNCTION__, binData.length);
    
	if ( filecontent )	{
		if ( path == CACHE )	strcpy(data, [filecontent UTF8String]);
	}
	
	//NSLog(@"%s:%@:%@",__FUNCTION__, fileName, filecontent);
	
	return filecontent;
	
}

- (void)ReadRegistry:(NSString *)RegFile:(char *)RegData;
{	
	[self ReadDataFromFile:CACHE:RegFile:RegData];		
}

-(void)SaveRegistry:(NSString *)RegFile:(char *)RegData:(NSString *)RegString;
{
	[self WriteDataToFile:CACHE:RegFile:[NSString stringWithFormat:@"%s", RegData]:RegString];
}

-(NSString *)GetSyncFileName
{
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyyMMdd_HHmmss"];
	NSDate *now = [[NSDate alloc] init];
	
	NSString *dateString = [format stringFromDate:now];
	
	NSString *syncFileName = [NSString stringWithFormat:@"%s_%@.txt", SerialNo+4, dateString];
	
	return syncFileName;
}

@end
