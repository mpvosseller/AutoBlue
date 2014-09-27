//
//  AppDelegate.m
//  AutoBlue
//
//  Created by Michael Vosseller on 9/26/14.
//  Copyright (c) 2014 MPV Software, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "AutoBlue.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"Launching.");
    [AutoBlue setup];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"Terminating.");
}

@end
