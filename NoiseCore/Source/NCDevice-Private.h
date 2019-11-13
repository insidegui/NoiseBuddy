//
//  NCDevice-Private.h
//  NoiseCore
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

#import "NCDevice.h"

@class AVOutputDevice;

@interface NCDevice (Private)

@property (nonatomic, strong) AVOutputDevice *avDevice;

@end
