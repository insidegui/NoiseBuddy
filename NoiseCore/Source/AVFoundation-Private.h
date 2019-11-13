//
//  AVFoundation-Private.h
//  OutputDevices
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

@import AVFoundation;

@interface AVOutputDevice: NSObject

@property(readonly, nonatomic) NSString *currentBluetoothListeningMode;
@property(readonly, nonatomic) NSArray *availableBluetoothListeningModes;
- (BOOL)setCurrentBluetoothListeningMode:(NSString *)mode error:(NSError **)outError;

@property (readonly, nonatomic) NSString *deviceID;
@property (readonly, nonatomic) NSString *name;

@end

@interface AVOutputContext: NSObject
+ (instancetype)sharedSystemAudioContext;
@property (nonatomic, readonly) NSArray <AVOutputDevice *> *outputDevices;
@end
