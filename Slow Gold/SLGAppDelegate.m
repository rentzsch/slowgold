//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "SLGAppDelegate.h"
#import "EntryWindowController.h"

@implementation SLGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    [[EntryWindowController new].window makeKeyAndOrderFront:nil];
}

@end
