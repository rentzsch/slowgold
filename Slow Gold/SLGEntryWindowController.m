//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "SLGEntryWindowController.h"
#import "SLGConfig.h"

@interface SLGEntryWindowController ()
@property(retain, nonatomic)  SLGConfig  *config;
@end

@implementation SLGEntryWindowController

- (id)init {
    self = [super initWithWindowNibName:@"SLGEntryWindowController"];
    if (self) {
        _config = [[SLGConfig alloc] initWithError:nil];
    }
    
    return self;
}

- (void)dealloc {
    [_config release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)controlTextDidChange:(NSNotification*)notification {
    NSString *bundleID = [self.config bundleIDForShortcut:[self.entryField stringValue]];
    if (bundleID) {
        NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleID];
        if (appPath) {
            [self.matchLabel setStringValue:[[NSFileManager defaultManager] displayNameAtPath:appPath]];
            [self.matchImageView setImage:[[NSWorkspace sharedWorkspace] iconForFile:appPath]];
        } else {
            NSLog(@"-[NSWorkspace absolutePathForAppBundleWithIdentifier:%@] failed?", bundleID);
        }
    } else {
        [self.matchImageView setImage:nil];
        [self.matchLabel setStringValue:@"…"];
    }
}

- (IBAction)openAction:(id)sender {
    NSString *bundleID = [self.config bundleIDForShortcut:[self.entryField stringValue]];
    if (bundleID) {
        [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:bundleID
                                                             options:NSWorkspaceLaunchDefault
                                      additionalEventParamDescriptor:nil
                                                    launchIdentifier:nil];
    }
    [self.entryField setStringValue:@""];
    [self.matchImageView setImage:nil];
    [self.matchLabel setStringValue:@""];
    
    [[NSRunningApplication currentApplication] hide];
}

@end