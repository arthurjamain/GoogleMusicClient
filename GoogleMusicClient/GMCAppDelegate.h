//
//  GMCAppDelegate.h
//  GoogleMusicClient
//
//  Created by Arthur Jamain on 22/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SPMediaKeyTap.h"

@interface GMCApp : NSApplication
@end

@interface GMCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) SPMediaKeyTap *keyTap;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;

@end
