#import <Foundation/Foundation.h>

@class HypoClass;

@protocol SLGEntryProtocol <NSObject>
@property(copy, nonatomic)  NSString  *key;
@property(copy, nonatomic)  NSString  *data;
@end

@interface SLGBundleEntry : NSObject <SLGEntryProtocol>
@end

@interface SLGURLEntry : NSObject <SLGEntryProtocol>
@end

@interface SLGPathEntry : NSObject <SLGEntryProtocol>
@end

@interface SLGScriptEntry : NSObject <SLGEntryProtocol>
@end

@interface SLGConfigParser : NSObject
@property(retain, nonatomic)  HypoClass  *SLGBundleEntry;
@property(retain, nonatomic)  HypoClass  *SLGURLEntry;
@property(retain, nonatomic)  HypoClass  *SLGPathEntry;
@property(retain, nonatomic)  HypoClass  *SLGScriptEntry;

- (BOOL)parse:(NSString*)file
     filename:(NSString*)filename
        error:(NSError**)error
        block:(void (^)(id<SLGEntryProtocol> entry))block;

@end
