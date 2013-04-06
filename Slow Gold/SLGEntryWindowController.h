//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import <Cocoa/Cocoa.h>

@interface SLGEntryWindowController : NSWindowController
@property(assign, nonatomic)  IBOutlet NSTextField  *entryField;
@property(assign, nonatomic)  IBOutlet NSImageView  *matchImageView;
@property(assign, nonatomic)  IBOutlet NSTextField  *matchLabel;

- (IBAction)openAction:(id)sender;

@end
