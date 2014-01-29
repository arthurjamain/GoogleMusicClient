//
//  GMCAppDelegate.m
//  GoogleMusicClient
//
//  Created by Arthur Jamain on 22/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import "GMCAppDelegate.h"


@implementation GMCApp
- (void)sendEvent:(NSEvent *)theEvent
{
    // If event tap is not installed, handle events that reach the app instead
    BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
        [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
    }
    [super sendEvent:theEvent];
}
@end

@implementation GMCAppDelegate

@synthesize keyTap, webView, preferences, window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://music.google.com"]]];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    hkm = [[JFHotkeyManager alloc] init];
    
    [self refreshMediakeys];
    [self refreshSystemShortcut];
}

-(void)refreshSystemShortcut
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger systemshortcut = [[defaults valueForKey:@"systemshortcut"] integerValue];
    NSMutableDictionary *shortcut = [defaults valueForKey:@"shortcut"];
    if (systemshortcut && shortcut != nil) {
        NSMutableDictionary *modifiers = [shortcut valueForKey:@"modifiers"];
        
        int modInt = 0;
        modInt += [[modifiers valueForKey:@"cmd"] integerValue];
        modInt += [[modifiers valueForKey:@"ctrl"] integerValue];
        modInt += [[modifiers valueForKey:@"alt"] integerValue];
        modInt += [[modifiers valueForKey:@"shift"] integerValue];
        
        NSLog(@"%d", modInt);
        
        if (&hkmRef != nil) {
            [hkm unbind:hkmRef];
        }
        hkmRef = [hkm
                  bindKeyRef:       [[shortcut valueForKey:@"key"] integerValue]
                  withModifiers:    modInt
                  target:           self
                  action:           @selector(shortcutInvoked)];
    } else {
        if (&hkmRef != nil) {
            [hkm unbind:hkmRef];
        }
    }
    
}
-(void)refreshMediakeys
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger mediakeys = [[defaults valueForKey:@"mediakeys"] integerValue];
    
    if (mediakeys) {
        if([SPMediaKeyTap usesGlobalMediaKeyTap]) {
            [keyTap startWatchingMediaKeys];
        } else {
            NSLog(@"Media key monitoring disabled");
        }
    } else {
        [keyTap stopWatchingMediaKeys];
    }
}

-(void)preferenceWindowWillClose
{
    [[[self preferences] textSystemShortcut] resignFirstResponder];
    [self refreshSystemShortcut];
    [self refreshMediakeys];
}

-(IBAction)openPreferences:(id)sender
{
    if(!preferences) {
        preferences = [[GMCPreferencesWindowController alloc] initWithWindowNibName:@"GMCPreferencesWindowController"];
    }
    [preferences showWindow:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferenceWindowWillClose)
                                                 name:NSWindowWillCloseNotification
                                               object:[preferences window]];
}

-(void)shortcutInvoked
{
    
    if ([[preferences window] isVisible]) {
        [preferences initInputs];
        [[preferences window] makeFirstResponder:nil];
        return;
    }
    
    if (![[NSApplication sharedApplication] isHidden]) {
        [window orderOut:self];
        [[NSApplication sharedApplication] hide:self];
    } else {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        [window orderFrontRegardless];
    }
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                [self sendKey:49];
				break;
				
			case NX_KEYTYPE_FAST:
				debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self sendKey:124];
				break;
				
			case NX_KEYTYPE_REWIND:
				debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [self sendKey:123];
				break;
			default:
				debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
        NSLog(@"%@", debugString);
	}
}

-(void)sendKey:(int) key
{
    CGEventRef event;
    event = CGEventCreateKeyboardEvent(NULL, key, true);
    ProcessSerialNumber mpsn;
    GetCurrentProcess(&mpsn);
    CGEventPostToPSN(&mpsn, event);
    CFRelease(event);
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[self window] orderFrontRegardless];
    return YES;
}
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[self window] orderFrontRegardless];
}
@end
