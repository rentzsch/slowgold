//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "SLGAppDelegate.h"
#import "SLGEntryWindowController.h"

@implementation SLGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    [[SLGEntryWindowController new].window makeKeyAndOrderFront:nil];
}

@end
