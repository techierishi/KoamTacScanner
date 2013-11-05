//
//  FileHandle.h
//  KTSync
//
//  Created by Ben Yoo on 10. 3. 26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileHandle;

@interface FileHandle : NSObject {
	NSArray *paths;
	NSFileManager *fileManager;
}

- (NSString *)GetSyncFileName;
- (void)CreateBarcodeDirectory;
- (void)ReadRegistry:(NSString *)RegFile:(char *)RegData;
- (void)SaveRegistry:(NSString *)RegFile:(char *)RegData:(NSString *)RegString;
- (NSString *)ReadDataFromFile:(int)path:(NSString *)filename:(char *)data;
- (void)WriteDataToFile:(int)path:(NSString *)filename:(NSString *)data:(NSString *)content; 
- (NSArray *)GetFileList:(int)path;
- (NSString *)GetDirectory:(int)path;

@property (nonatomic, retain) NSArray *paths;
@property (nonatomic, retain) NSFileManager *fileManager;

@end
