//  Copyright (c) 2013 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//  Some rights reserved: http://opensource.org/licenses/mit

#import <Foundation/Foundation.h>

@interface SlowGoldConfig : NSObject

- (id)initWithError:(NSError**)error;
- (NSString*)bundleIDForShortcut:(NSString*)shortcut;

@end
