//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "SLGConfig.h"
#import "JRErr.h"
#import "SLGConfigParser.h"
#import "Hypo.h"

@interface SLGConfig ()
@property(retain, nonatomic)  NSMutableDictionary  *lookup;
@end

@implementation SLGConfig

- (id)initWithError:(NSError**)error {
    self = JRPushErr([super init]);

    if (!jrErr) {
        _lookup = [[NSMutableDictionary alloc] init];
    }
    
    NSURL *configURL = nil;
    if (!jrErr) {
        configURL = [[NSBundle mainBundle] URLForResource:@"default"
                                            withExtension:@"slowgoldconfig"];
    }
    
    NSString *configFile = nil;
    if (!jrErr) {
        configFile = JRPushErr([NSString stringWithContentsOfURL:configURL
                                                        encoding:NSUTF8StringEncoding
                                                           error:jrErrRef]);
    }
    
    if (!jrErr) {
        SLGConfigParser *parser = [SLGConfigParser hypo_new];
        JRPushErr([parser parse:configFile
             filename:[configURL lastPathComponent]
                error:jrErrRef
                block:^(id<SLGEntryProtocol> entry) {
                    [_lookup setObject:entry forKey:entry.key];
                }]);
    }
    
    returnJRErr(self);
}

- (void)dealloc {
    [_lookup release];
    [super dealloc];
}

- (NSString*)bundleIDForShortcut:(NSString*)shortcut {
    SLGBundleEntry *bundleEntry = [self.lookup objectForKey:shortcut];
    return bundleEntry.data;
}

@end
