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

@synthesize keyTap, webView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://music.google.com"]]];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap]) {
		[keyTap startWatchingMediaKeys];
	} else {
		NSLog(@"Media key monitoring disabled");
    }
    
    JFHotkeyManager *hkm = [[JFHotkeyManager alloc] init];
    [hkm bind:@"command shift up" target:self action:@selector(shortcutInvoked)];
}

-(void)shortcutInvoked
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[self window] orderFrontRegardless];
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
