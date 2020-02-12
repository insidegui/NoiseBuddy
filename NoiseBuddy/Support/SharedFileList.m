//
//  SharedFileList.m
//  SyzygyKit
//
//  Created by Dave DeLong on 9/22/18.
//  Copyright © 2018 Syzygy. All rights reserved.
//

#import "SharedFileList.h"

#import <CoreServices/CoreServices.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

void sharedFileListDidChange(LSSharedFileListRef inList, void *context);

@implementation SharedFileList {
    LSSharedFileListRef _listRef;
    
    NSSet *_listSnapshot;
}

+ (BOOL)automaticallyNotifiesObserversOfItems { return NO; }

+ (instancetype)sessionLoginItems {
    return [[self alloc] initWithType:kLSSharedFileListSessionLoginItems];
}

- (instancetype)initWithType:(CFStringRef)type {
    self = [super init];
    if (self) {
        _listRef = LSSharedFileListCreate(NULL, type, NULL);
        _listSnapshot = [self _snapshot];
        
        LSSharedFileListAddObserver(_listRef,
                                    CFRunLoopGetMain(),
                                    (CFStringRef)NSDefaultRunLoopMode,
                                    sharedFileListDidChange,
                                    (voidPtr)CFBridgingRetain(self));
    }
    return self;
}

- (void)dealloc {
    LSSharedFileListRemoveObserver(_listRef,
                                   CFRunLoopGetMain(),
                                   (CFStringRef)NSDefaultRunLoopMode,
                                   sharedFileListDidChange,
                                   (__bridge void *)(self));
    CFRelease(_listRef);
}

- (NSSet *)items { return [_listSnapshot copy]; }

- (NSSet *)_snapshot {
    NSMutableSet *snapshot = [NSMutableSet set];
    
    NSArray *listSnapshot = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(_listRef, NULL));
    for (id itemObject in listSnapshot) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        NSURL *itemURL = CFBridgingRelease(currentItemURL);
        if (itemURL != nil) {
            [snapshot addObject:itemURL];
        }
    }
    
    return snapshot;
}

- (void)_listDidChange {
    NSSet *newSnapshot = [self _snapshot];
    
    [self willChangeValueForKey:@"items"];
    _listSnapshot = newSnapshot;
    [self didChangeValueForKey:@"items"];
    
    if (self.changeHandler != nil) {
        self.changeHandler(self);
    }
}

- (BOOL)containsItem:(NSURL *)url { return [_listSnapshot containsObject:url]; }

- (void)addItem:(NSURL *)url {
    if ([self containsItem:url] == YES) { return; }
    LSSharedFileListInsertItemURL(_listRef, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)url, NULL, NULL);
}

- (void)removeItem:(NSURL *)url {
    if ([self containsItem:url] == NO) { return; }
    
    NSArray *listSnapshot = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(_listRef, NULL));
    for (id itemObject in listSnapshot) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        NSURL *itemURL = CFBridgingRelease(currentItemURL);
        if ([itemURL isEqual:url]) {
            LSSharedFileListItemRemove(_listRef, item);
        }
    }
}

@end

void sharedFileListDidChange(LSSharedFileListRef inList, void *context) {
    SharedFileList *list = (__bridge id)context;
    [list _listDidChange];
}

#pragma clang diagnostic pop
