//
//  AboutWindowController.m
//  AutoBlue
//
//  Created by Michael Vosseller on 10/19/14.
//  Copyright (c) 2014 MPV Software, LLC. All rights reserved.
//

#import "AboutWindowController.h"

@interface AboutWindowController ()
@property (nonatomic) IBOutlet NSTextField *titleTextField;
@property (nonatomic) IBOutlet NSTextField *detailTextField;
@end

@implementation AboutWindowController

- (id)init{
    self = [super initWithWindowNibName:@"AboutWindowController"];
    if(self) {
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.titleTextField.stringValue = @"AutoBlue";
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"AutoBlue"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* versionStr = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *informativeText = [NSString stringWithFormat:@"Version %@\nMPV Software, LLC\nCopyright © 2014", versionStr];
    self.detailTextField.stringValue = informativeText;
}

-(IBAction)showWindow:(id)sender {
    [[self window] center];
    [super showWindow:sender];
}

- (IBAction)handleOKButtonPressed:(id)sender {
    [self close];
}

- (IBAction)exitButtonPressed:(id)sender {
    exit(0);
}

@end
