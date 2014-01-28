//
//  GMCPreferencesWindowController.h
//  Google Music Client
//
//  Created by Arthur Jamain on 27/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GMCPreferencesWindowController : NSWindowController <NSTextFieldDelegate>

@property (assign) IBOutlet NSButton *checkMediaKeys;
@property (assign) IBOutlet NSButton *checkSystemShortcut;
@property (assign) IBOutlet NSTextField *textSystemShortcut;

-(IBAction)toggleMediaKeys:(id)sender;
-(IBAction)toggleSystemShortcut:(id)sender;
-(IBAction)saveAndQuit:(id)sender;

@end
