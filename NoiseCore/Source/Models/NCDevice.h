//
//  NCDevice.h
//  NoiseCore
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NCDevice: NSObject

@property (copy) NSString *identifier;
@property (copy) NSString *name;

@property (copy) NSString *_listeningMode;
@property (copy) NSArray <NSString *> *_availableListeningModes;

@property (copy) void(^listeningModeDidChange)(NCDevice *device);

@end

NS_ASSUME_NONNULL_END
