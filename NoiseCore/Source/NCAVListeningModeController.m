//
//  NCAVListeningModeController.m
//  NoiseCore
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

#import "NCAVListeningModeController.h"

@import AVFoundation;

#import "AVFoundation-Private.h"

#import "fishhook.h"

#import "NCDevice.h"
#import "NCDevice-Private.h"

@import os.log;

@interface NCDevice (AV)

+ (NCDevice *)deviceWithOutputDevice:(AVOutputDevice *)avDevice;

@end

// HACK!
// AVFoundation does the entitlement checking for the system output context in-process,
// which means we can just hook the entitlement-checking method at runtime and override it
// to always return true.

static CFTypeRef (*orig_stcvfe)(SecTaskRef  _Nonnull task, CFStringRef  _Nonnull entitlement, CFErrorRef  _Nullable * _Nullable error);

CFTypeRef my_SecTaskCopyValueForEntitlement(SecTaskRef  _Nonnull task, CFStringRef  _Nonnull entitlement, CFErrorRef  _Nullable * _Nullable error) {
    if (kCFCompareEqualTo == CFStringCompare(entitlement, CFSTR("com.apple.avfoundation.allow-system-wide-context"), 0)) {
        return kCFBooleanTrue;
    } else {
        return orig_stcvfe(task, entitlement, error);
    }
}

static void hookAVFEntitlement() {
    rebind_symbols((struct rebinding[1]){"SecTaskCopyValueForEntitlement", my_SecTaskCopyValueForEntitlement, (void *)&orig_stcvfe}, 1);
}

@interface NCAVListeningModeController ()

@property (strong) os_log_t log;
@property (strong) AVOutputContext *context;
@property (nonatomic, strong) AVOutputDevice *currentOutputDevice;

// TODO: Figure out a way to get notified when the current output device changes, instead of using this timer hack.
@property (nonatomic, strong) NSTimer *deviceTimer;

@end

@implementation NCAVListeningModeController

+ (instancetype)shared
{
    static NCAVListeningModeController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [NCAVListeningModeController new];
    });
    return controller;
}

- (instancetype)init
{
    self = [super init];

    self.log = os_log_create("codes.rambo.NoiseCore", "NCAVListeningModeController");

    return self;
}

- (void)startListeningForUpdates
{
    os_log_debug(self.log, "%{public}@", NSStringFromSelector(_cmd));

    hookAVFEntitlement();

    self.context = [AVOutputContext sharedSystemAudioContext];

    self.deviceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkOutputDevice:) userInfo:nil repeats:YES];
    self.deviceTimer.tolerance = 5.0;

    self.currentOutputDevice = self.context.outputDevices.firstObject;

    [self _callOutputDeviceDidChangeWithDevice:self.currentOutputDevice];
}

- (void)checkOutputDevice:(id)sender
{
    AVOutputDevice *previousDevice = self.currentOutputDevice;
    AVOutputDevice *currentDevice = self.context.outputDevices.firstObject;

    if (!previousDevice && !currentDevice) return;

    if ([previousDevice.deviceID isEqualToString:currentDevice.deviceID]) return;

    self.currentOutputDevice = self.context.outputDevices.firstObject;

    [self _callOutputDeviceDidChangeWithDevice:self.currentOutputDevice];
}

- (void)_callOutputDeviceDidChangeWithDevice:(AVOutputDevice *)outputDevice
{
    os_log_debug(self.log, "%{public}@ %@", NSStringFromSelector(_cmd), outputDevice);

    if (!self.outputDeviceDidChange) return;

    NCDevice *dev = (outputDevice) ? [NCDevice deviceWithOutputDevice:outputDevice] : nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.outputDeviceDidChange(dev);
    });
}

- (void)_setListeningMode:(NSString *)listeningMode
{
    NSError *error;

    if (![self.currentOutputDevice setCurrentBluetoothListeningMode:listeningMode error:&error]) {
        os_log_error(self.log, "Error setting listening mode on %@: %{public}@", self.currentOutputDevice.name, error);
    } else {
        os_log_debug(self.log, "Changed listening mode on %@ to %@", self.currentOutputDevice.name, listeningMode);
    }
}

- (NSString *)_listeningMode
{
    return [self.currentOutputDevice.currentBluetoothListeningMode copy];
}

- (NSArray<NSString *> *)_availableListeningModes
{
    return [self.currentOutputDevice.availableBluetoothListeningModes copy];
}

@end

@implementation NCDevice (AV)

+ (NCDevice *)deviceWithOutputDevice:(AVOutputDevice *)avDevice
{
    NCDevice *device = [NCDevice new];

    device.identifier = avDevice.deviceID;
    device.name = avDevice.name;
    device._listeningMode = avDevice.currentBluetoothListeningMode;
    device._availableListeningModes = avDevice.availableBluetoothListeningModes;
    device.avDevice = avDevice;

    return device;
}

@end
