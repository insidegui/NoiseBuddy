//
//  NCAVListeningModeController.h
//  NoiseCore
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

@import Foundation;

@class NCDevice;

NS_ASSUME_NONNULL_BEGIN

@protocol NCListeningModeStatusProvider <NSObject>

- (void)startListeningForUpdates;

@property (nonatomic, copy) void(^outputDeviceDidChange)(NCDevice *__nullable device);

@property (nonatomic, readonly) NSArray <NSString *> *_availableListeningModes;
@property (nonatomic, copy) NSString *_listeningMode;
- (void)_setListeningMode:(NSString *)listeningMode;

@end

@interface NCAVListeningModeController : NSObject <NCListeningModeStatusProvider>

- (void)startListeningForUpdates;

@property (nonatomic, copy) void(^outputDeviceDidChange)(NCDevice *__nullable device);

@property (nonatomic, readonly) NSArray <NSString *> *_availableListeningModes;
@property (nonatomic, copy) NSString *_listeningMode;
- (void)_setListeningMode:(NSString *)listeningMode;

@end

NS_ASSUME_NONNULL_END
