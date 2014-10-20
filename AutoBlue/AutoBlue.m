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
#import "AboutWindowController.h"

@interface AutoBlue()
@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) NSMenuItem *statusMenuItem;
@property (nonatomic) NSMenuItem *toggleMenuItem;
@property (nonatomic) BOOL enabled;
@property (nonatomic, readonly) BOOL isConnectedToExternalDisplay;
@property (nonatomic) BOOL bluetoothEnabled;
@property (nonatomic) AboutWindowController *aboutWindowController;
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
        [self configureStatusBarMenu];
    }
    return self;
}

- (void) configureStatusBarMenu {
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    
    self.statusMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    self.toggleMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(toggleButtonPressed) keyEquivalent:@""];
    self.toggleMenuItem.target = self;
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About AutoBlue" action:@selector(aboutButtonPressed) keyEquivalent:@""];
    aboutMenuItem.target = self;
    
    [menu addItem:self.statusMenuItem];
    [menu addItem:self.toggleMenuItem];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:aboutMenuItem];

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"StatusItem"];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setMenu:menu];
    
    [self refreshStatusBarMenu];
}

- (void) refreshStatusBarMenu {
    self.statusItem.button.appearsDisabled = self.enabled ? NO : YES;
    self.statusMenuItem.title = self.enabled ? @"AutoBlue: On" : @"AutoBlue: Off";
    self.toggleMenuItem.title = self.enabled ? @"Turn AutoBlue Off" : @"Turn AutoBlue On";    
}

- (IBAction) toggleButtonPressed {
    self.enabled = !self.enabled;
    [self refreshStatusBarMenu];
    
    if (self.enabled) {
        [self updateBluetoothState];
    }
}

- (void) aboutButtonPressed {
    if (self.aboutWindowController == nil) {
        self.aboutWindowController = [[AboutWindowController alloc] init];
    }
    [self.aboutWindowController showWindow:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void) setEnabled:(BOOL)enabled {
    BOOL disabled = !enabled;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:disabled forKey:@"com.mpvsoftware.autoblue.disabled"];
    [defaults synchronize];
}

- (BOOL) enabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL disabled = [defaults boolForKey:@"com.mpvsoftware.autoblue.disabled"];
    return !disabled;
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
    if (self.enabled) {
        if (self.isConnectedToExternalDisplay && !self.bluetoothEnabled) {
            self.bluetoothEnabled = YES;
            [self refreshStatusBarMenu];
        } else if (!self.isConnectedToExternalDisplay && self.bluetoothEnabled) {
            self.bluetoothEnabled = NO;
            [self refreshStatusBarMenu];
        }
    }
}


@end
