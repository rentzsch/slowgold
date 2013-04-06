//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "SLGAppDelegate.h"
#import "SLGEntryWindowController.h"
#include <Carbon/Carbon.h>

@interface SLGAppDelegate ()
@property(retain, nonatomic)  SLGEntryWindowController  *entryWindowController;
@end

@implementation SLGAppDelegate

OSStatus SLGHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
    SLGAppDelegate *self = (SLGAppDelegate*)userData;
    [self hotkeyPressed];
    return noErr;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    self.entryWindowController = [[[SLGEntryWindowController alloc] init] autorelease];
    [self.entryWindowController.window  makeKeyAndOrderFront:nil];
    
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(SLGHotKeyHandler, 1, &eventType, self, NULL);
    
    EventHotKeyRef hotkeyRef;
    RegisterEventHotKey(kVK_Space,
                        controlKey,
                        (EventHotKeyID){'wolf', 1},
                        GetApplicationEventTarget(),
                        0,
                        &hotkeyRef);
}

- (void)dealloc {
    [_entryWindowController release];
    [super dealloc];
}

- (void)hotkeyPressed {
    // from http://www.cocoabuilder.com/archive/cocoa/304994-activate-app-but-bring-only-one-window-to-the-front.html :
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    
    [self.entryWindowController.window makeKeyAndOrderFront:nil];
}

@end
