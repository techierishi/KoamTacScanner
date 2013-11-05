//
//  iKEA.h
//
//  Created by KoamTac on 10. 3. 12..
//  Copyright 2010 KoamTac Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@class iKEA;

@interface iKEA: NSObject <EAAccessoryDelegate, NSStreamDelegate> {
	EASession *session;
}

@property (nonatomic, retain) EASession *session;

- (void)SetDeviceDelegate:(id)devDel;
- (bool)CheckIfDeviceConnected;
- (void)SetDeviceProtocol:(char *)protocol;
- (NSInteger)SendDataToDevice:(uint8_t *)buffer:(int)size;

@end
