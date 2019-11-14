//
//  IOBluetooth-Private.h
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 14/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

@import IOBluetooth;

@interface IOBluetoothDevice (Private)

- (BOOL)isANCSupported;

@property(readonly) BOOL isTransparencySupported;
@property(nonatomic) unsigned char listeningMode;

@end
