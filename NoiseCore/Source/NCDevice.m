//
//  NCDevice.m
//  NoiseCore
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

#import "NCDevice.h"

#import "AVFoundation-Private.h"

NSString * const kCurrentListeningModeKeyPath = @"currentBluetoothListeningMode";

@interface NCDevice ()

@property (nonatomic, strong) AVOutputDevice *avDevice;

// TODO: Figure out a way to get notified when the current listening mode changes, instead of using this timer hack.
@property (nonatomic, strong) NSTimer *currentModeTimer;

@end

@implementation NCDevice

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"NCDevice(identifier: %@, name: %@, listeningMode: %@, availableListeningModes: %@)",
            self.identifier, self.name, self._listeningMode, self._availableListeningModes];
}

- (NSString *)description {
    return self.debugDescription;
}

- (void)setAvDevice:(AVOutputDevice *)avDevice
{
    [self.currentModeTimer invalidate];
    self.currentModeTimer = nil;

    _avDevice = avDevice;

    self.currentModeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentListeningMode:) userInfo:nil repeats:YES];
    self.currentModeTimer.tolerance = 5.0;
}

- (void)updateCurrentListeningMode:(id)sender
{
    NSString *previousMode = self._listeningMode;
    NSString *currentMode = self.avDevice.currentBluetoothListeningMode;
    if ([previousMode isEqualToString:currentMode]) return;

    self._listeningMode = currentMode;

    if (self.listeningModeDidChange) self.listeningModeDidChange(self);
}

- (void)dealloc
{
    [self.avDevice removeObserver:self forKeyPath:kCurrentListeningModeKeyPath];
}

@end
