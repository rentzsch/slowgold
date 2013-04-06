//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import "SLGConfig.h"
#import "JRErr.h"

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
    
    NSRegularExpression *validConfigLineRegex;
    if (!jrErr) {
        validConfigLineRegex = JRPushErr([NSRegularExpression regularExpressionWithPattern:@"^([^ #]+) +(.+)$"
                                                                                   options:NSRegularExpressionAnchorsMatchLines
                                                                                     error:jrErrRef]);
    }
    
    if (!jrErr) {
        [validConfigLineRegex enumerateMatchesInString:configFile
                                               options:0
                                                 range:NSMakeRange(0, [configFile length])
                                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                NSString *shortcut = [configFile substringWithRange:[result rangeAtIndex:1]];
                                                NSString *bundleID = [configFile substringWithRange:[result rangeAtIndex:2]];
                                                [_lookup setObject:bundleID forKey:shortcut];
                                            }];
    }
    
    returnJRErr(self);
}

- (void)dealloc {
    [_lookup release];
    [super dealloc];
}

- (NSString*)bundleIDForShortcut:(NSString*)shortcut {
    return [self.lookup objectForKey:shortcut];
}

@end
