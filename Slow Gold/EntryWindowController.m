//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "EntryWindowController.h"
#import "SlowGoldConfig.h"

static NSMutableArray* controllers() {
    static NSMutableArray *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NSMutableArray alloc] init];
    });
    return result;
}

@interface EntryWindowController ()
@property(retain, nonatomic)  SlowGoldConfig  *config;
@end

@implementation EntryWindowController

- (id)init {
    self = [super initWithWindowNibName:@"EntryWindowController"];
    if (self) {
        [controllers() addObject:self];
        _config = [[SlowGoldConfig alloc] initWithError:nil];
    }
    
    return self;
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
}

@end