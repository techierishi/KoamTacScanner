//
//  AES.h
//  KTSync
//
//  Created by Ben Yoo on 11-09-12.
//  Copyright 2011 KoamTac Inc. All rights reserved.
//

int getSBoxInvert(int num);
int getSBoxValue(int num);
void KeyExpansion();
void AddRoundKey(int round);
void InvSubBytes();
void InvShiftRows();
void InvMixColumns();
void InvCipher();

short	DecryptMSRData(unsigned char *dest, unsigned char *src, int length);