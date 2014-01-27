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
    // Insert code here to initialize your application
    [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://music.google.com"]]];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");
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
                [self sendKey:' '];
				break;
				
			case NX_KEYTYPE_FAST:
				debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self sendKeyInt:124];
				break;
				
			case NX_KEYTYPE_REWIND:
				debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [self sendKeyInt:123];
				break;
			default:
				debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
        NSLog(@"%@", debugString);
	}
}

-(void)sendKey:(char) key
{
    CGKeyCode code = keyCodeForChar(key);
    NSLog(@"%d", code);
    CGEventRef event;
    event = CGEventCreateKeyboardEvent(NULL, code, true);
    ProcessSerialNumber mpsn;
    GetCurrentProcess(&mpsn);
    CGEventPostToPSN(&mpsn, event);
    CFRelease(event);
}
-(void)sendKeyInt:(int) key
{
    CGKeyCode code = key;
    NSLog(@"%d", code);
    CGEventRef event;
    event = CGEventCreateKeyboardEvent(NULL, code, true);
    ProcessSerialNumber mpsn;
    GetCurrentProcess(&mpsn);
    CGEventPostToPSN(&mpsn, event);
    CFRelease(event);
}
CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

CGKeyCode keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CGKeyCode code;
    UniChar character = c;
    CFStringRef charStr = NULL;
    
    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                CFRelease(string);
            }
        }
    }
    
    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    /* Our values may be NULL (0), so we need to use this function. */
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        code = UINT16_MAX;
    }
    
    CFRelease(charStr);
    return code;
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    [[self window] makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    return YES;
}
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [[self window] makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}
@end
