//
//  AutoBlue.m
//  AutoBlue
//
//  Created by Michael Vosseller on 9/26/14.
//  Copyright (c) 2014 MPV Software, LLC. All rights reserved.
//

#import "AutoBlue.h"

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <Cocoa/Cocoa.h>

@interface AutoBlue()
@property (nonatomic, readonly) BOOL isConnectedToExternalDisplay;
@property (nonatomic) BOOL bluetoothEnabled;
- (void) updateBluetoothState;
+ (AutoBlue*) sharedAutoBlue;
@end


int IOBluetoothPreferenceGetControllerPowerState();
void IOBluetoothPreferenceSetControllerPowerState(int);

static void displayChanged(CGDirectDisplayID displayID, CGDisplayChangeSummaryFlags flags, void *userInfo) {
    [[AutoBlue sharedAutoBlue] updateBluetoothState];
}


@implementation AutoBlue

+ (void) setup {
    [AutoBlue sharedAutoBlue];
}

+ (AutoBlue*) sharedAutoBlue {
    static dispatch_once_t once;
    static AutoBlue *sharedAutoBlue;
    dispatch_once(&once, ^{
        sharedAutoBlue = [[self alloc] init];
    });
    return sharedAutoBlue;
}

- (id) init {
    self = [super init];
    if (self) {
        CGDisplayRegisterReconfigurationCallback(displayChanged, NULL);
        [self updateBluetoothState];
    }
    return self;
}

- (BOOL) isConnectedToExternalDisplay {    
    uint32_t maxDisplays = 100;
    CGDirectDisplayID onlineDisplays[maxDisplays];
    uint32_t displayCount;
    CGError error = CGGetOnlineDisplayList(maxDisplays, onlineDisplays, &displayCount);
    
    if (!error) {
        for (uint32_t i=0; i<displayCount; i++) {
            CGDirectDisplayID displayId = onlineDisplays[i];
            boolean_t isBuiltInDisplay = CGDisplayIsBuiltin(displayId);
            if (!isBuiltInDisplay) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) bluetoothEnabled {
     return IOBluetoothPreferenceGetControllerPowerState() != 0;
}

- (void) setBluetoothEnabled:(BOOL)bluetoothEnabled {
    if (bluetoothEnabled) {
        NSLog(@"Detected external display. Turning Bluetooth ON.");
    } else {
        NSLog(@"No external displays. Turning Bluetooth OFF.");
    }
    IOBluetoothPreferenceSetControllerPowerState(bluetoothEnabled ? 1 : 0);
    usleep(2500000);
}

- (void) updateBluetoothState {
    if (self.isConnectedToExternalDisplay && !self.bluetoothEnabled) {
        self.bluetoothEnabled = YES;
    } else if (!self.isConnectedToExternalDisplay && self.bluetoothEnabled) {
        self.bluetoothEnabled = NO;
    }
}


@end
