//
//  GMCAppDelegate.h
//  GoogleMusicClient
//
//  Created by Arthur Jamain on 22/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "GMCPreferencesWindowController.h"
#import "GMCWindow.h"
#import "SPMediaKeyTap.h"
#import "JFHotkeyManager.h"

@interface GMCApp : NSApplication
@end

@interface GMCAppDelegate : NSObject <NSApplicationDelegate>
{
    JFHotkeyManager *hkm;
    JFHotKeyRef hkmRef;
}
@property (assign) SPMediaKeyTap *keyTap;
@property (assign) GMCPreferencesWindowController *preferences;
@property (assign) IBOutlet GMCWindow *window;
@property (assign) IBOutlet WebView *webView;

-(IBAction)openPreferences:(id)sender;

@end
