//
//  GMCTextField.h
//  Google Music Client
//
//  Created by Arthur Jamain on 27/01/14.
//  Copyright (c) 2014 Arthur Jamain. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GMCPreferencesWindowController.h"
#import "JFHotkeyManager.h"

@interface GMCTextField : NSTextField {

    NSString *displayText;
    GMCPreferencesWindowController *parent;
    
}
@end
