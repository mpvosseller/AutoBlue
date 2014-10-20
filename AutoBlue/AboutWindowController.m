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
@property (nonatomic) IBOutlet NSButton *supportButton;
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
    
    NSColor *color = [NSColor blueColor];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.supportButton attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [self.supportButton setAttributedTitle:colorTitle];
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

- (IBAction)handleSupportButtonPressed:(id)sender {
    
    NSString *supportEmailAddress = @"mpv@mpvsoftware.com";
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *subjectStr = [NSString stringWithFormat:@"AutoBlue Support Version %@", versionStr];
    subjectStr = [subjectStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *mailLinkStr = [NSString stringWithFormat:@"mailto:%@?subject=%@", supportEmailAddress, subjectStr];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailLinkStr]];
}

@end
