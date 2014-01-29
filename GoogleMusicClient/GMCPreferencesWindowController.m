//
//  GMCPreferencesWindowController.m
//  Google Music Client
//
//  Created by Arthur Jamain on 27/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import "GMCPreferencesWindowController.h"

@interface GMCPreferencesWindowController ()

@end

@implementation GMCPreferencesWindowController

@synthesize checkMediaKeys, checkSystemShortcut, textSystemShortcut;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self initInputs];
}

- (void)initInputs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger systemshortcut = [[defaults valueForKey:@"systemshortcut"] integerValue];
    NSInteger mediakeys = [[defaults valueForKey:@"mediakeys"] integerValue];
    NSMutableDictionary *shortcut = [defaults valueForKey:@"shortcut"];

    [checkSystemShortcut setState:systemshortcut];
    [checkMediaKeys setState:mediakeys];
    [textSystemShortcut setEnabled:systemshortcut];
    if (shortcut != nil) {
        [textSystemShortcut setStringValue:[shortcut valueForKey:@"printableKey"]];
    }
    [textSystemShortcut setDelegate:self];
}

-(void)setShortcut:(NSMutableDictionary *)shortcut
{
    [textSystemShortcut performSelector:@selector(setStringValue:) withObject:[shortcut valueForKey:@"printableKey"] afterDelay:0.01];
    [[self window] performSelector:@selector(makeFirstResponder:) withObject:[[self window] nextResponder] afterDelay:0.02];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:shortcut forKey:@"shortcut"];
    [defaults synchronize];
}

-(IBAction)toggleMediaKeys:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSString stringWithFormat:@"%ld", (long)[checkMediaKeys state]] forKey:@"mediakeys"];
    [defaults synchronize];
}

-(IBAction)toggleSystemShortcut:(id)sender
{
    [textSystemShortcut setEnabled:[checkSystemShortcut state]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSString stringWithFormat:@"%ld", (long)[checkSystemShortcut state]] forKey:@"systemshortcut"];
    [defaults synchronize];
}

-(IBAction)saveAndQuit:(id)sender
{
    [[self window] makeFirstResponder:nil];
    [[self window] close];
}

@end
