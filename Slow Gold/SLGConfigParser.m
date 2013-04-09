#import "SLGConfigParser.h"
#import "Hypo.h"
#import "JREnum.h"
#import "JRErr.h"

JREnum(SLGConfigParserState,
       ExpectingEntryKeyOrComment,
       ExpectingFirstLineOfEntryData,
       ExpectingAddtionalDataLinesOrSeparatingNewlines,
       );

@interface NSRegularExpression (jr_matches)
- (BOOL)jr_matches:(NSString*)string;
@end

@interface SLGConfigParser ()
@property(assign, nonatomic)  SLGConfigParserState  state;
@property(retain, nonatomic)  NSError               *error;
@property(retain, nonatomic)  NSRegularExpression   *bundleRegex;
@property(retain, nonatomic)  NSRegularExpression   *urlRegex;
@property(retain, nonatomic)  NSRegularExpression   *pathRegex;
@property(retain, nonatomic)  NSRegularExpression   *scriptRegex;
@end

@implementation SLGConfigParser

- (void)dealloc {
    [_SLGBundleEntry release];
    [_SLGURLEntry release];
    [_SLGPathEntry release];
    [_SLGScriptEntry release];
    
    [_error release];
    [_bundleRegex release];
    [_urlRegex release];
    [_pathRegex release];
    [_scriptRegex release];
    [super dealloc];
}

- (BOOL)parse:(NSString*)file
     filename:(NSString*)filename
        error:(NSError**)error
        block:(void (^)(id<SLGEntryProtocol> entry))block
{
    if (self.error) {
        if (error) *error = self.error;
        return NO;
    }
    
    if (!self.bundleRegex) {
        self.bundleRegex = JRPushErr([NSRegularExpression regularExpressionWithPattern:@"^[^\\.]+\\."
                                                                               options:NSRegularExpressionAnchorsMatchLines
                                                                                 error:jrErrRef]);
        if (!jrErr) {
            self.urlRegex = JRPushErr([NSRegularExpression regularExpressionWithPattern:@"://"
                                                                                   options:0
                                                                                     error:jrErrRef]);
        }
        if (!jrErr) {
            self.pathRegex = JRPushErr([NSRegularExpression regularExpressionWithPattern:@"^[/\\.~]"
                                                                                options:NSRegularExpressionAnchorsMatchLines
                                                                                  error:jrErrRef]);
        }
        if (!jrErr) {
            self.scriptRegex = JRPushErr([NSRegularExpression regularExpressionWithPattern:@"^\\#!"
                                                                                 options:NSRegularExpressionAnchorsMatchLines
                                                                                   error:jrErrRef]);
        }
    }
    
    if (!jrErr) {
        NSMutableArray *lines = [[[file componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy] autorelease];
        
        // Tack on a couple of newlines to make the logic easier to flush the file's final entry.
        [lines addObjectsFromArray:@[@"",@""]];
        
        NSString *entryKey = nil;
        id<SLGEntryProtocol> entry = nil;
        NSMutableArray *entryDataAccumulator = nil;
        
        NSUInteger lineIndex = 0;
        for (NSString *line in lines) {
            switch (_state) {
                case ExpectingEntryKeyOrComment:
                    if ([line length]) {
                        if ([line hasPrefix:@"#"]) {
                            // Comment.
                        } else {
                            entryKey = line;
                            _state = ExpectingFirstLineOfEntryData;
                        }
                    } else {
                        // Skip leading newlines.
                    }
                    break;
                case ExpectingFirstLineOfEntryData:
                    if ([line length]) {
                        if ([line hasPrefix:@"#"] && ![line hasPrefix:@"#!"]) {
                            JRPushErrMsg(@"Configuration Syntax Error",
                                         ([NSString stringWithFormat:@"Unexpected Comment (under Entry Key %@ at %@:%ld)",
                                           entryKey,
                                           filename,
                                           (unsigned long)lineIndex]));
                            break;
                        } else {
                            if ([self.bundleRegex jr_matches:line]) {
                                entry = [self.SLGBundleEntry hypo_new];
                            } else if ([self.urlRegex jr_matches:line]) {
                                entry = [self.SLGURLEntry hypo_new];
                            } else if ([self.pathRegex jr_matches:line]) {
                                entry = [self.SLGURLEntry hypo_new];
                            } else if ([self.scriptRegex jr_matches:line]) {
                                entry = [self.SLGScriptEntry hypo_new];
                            } else {
                                JRPushErrMsg(@"Configuration Syntax Error",
                                             ([NSString stringWithFormat:@"Unmatched Entry Data Format (under Entry Key %@ at %@:%ld)",
                                               entryKey,
                                               filename,
                                               (unsigned long)lineIndex]));
                                break;
                            }
                            entry.key = entryKey;
                            
                            entryDataAccumulator = [NSMutableArray array];
                            [entryDataAccumulator addObject:line];
                            
                            _state = ExpectingAddtionalDataLinesOrSeparatingNewlines;
                        }
                    } else {
                        JRPushErrMsg(@"Configuration Syntax Error",
                                     ([NSString stringWithFormat:@"Empty Entry Data (under Entry Key %@ at %@:%ld)",
                                       entryKey,
                                       filename,
                                       (unsigned long)lineIndex]));
                        break;
                    }
                    break;
                case ExpectingAddtionalDataLinesOrSeparatingNewlines:
                    [entryDataAccumulator addObject:line];
                    
                    if ([entryDataAccumulator count] >= 2
                        && [[entryDataAccumulator lastObject] isEqualToString:@""])
                    {
                        [entryDataAccumulator removeLastObject];
                        entry.data = [entryDataAccumulator componentsJoinedByString:@"\n"];
                        block(entry);
                        _state = ExpectingEntryKeyOrComment;
                    }
                    break;
                default:
                    NSAssert1(NO, @"%@", SLGConfigParserStateToString(_state));
                    break;
            }
            lineIndex++;
        }
    }
    
    self.error = jrErr;
    returnJRErr();
}

@end

@implementation NSRegularExpression (jr_matches)

- (BOOL)jr_matches:(NSString*)string {
    return [self rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])].location != NSNotFound;
}

@end

@implementation SLGBundleEntry
@synthesize key = _key;
@synthesize data = _data;

- (void)dealloc {
    [_key release];
    [_data release];
    [super dealloc];
}
@end

@implementation SLGURLEntry
@synthesize key = _key;
@synthesize data = _data;

- (void)dealloc {
    [_key release];
    [_data release];
    [super dealloc];
}
@end

@implementation SLGPathEntry
@synthesize key = _key;
@synthesize data = _data;

- (void)dealloc {
    [_key release];
    [_data release];
    [super dealloc];
}
@end

@implementation SLGScriptEntry
@synthesize key = _key;
@synthesize data = _data;

- (void)dealloc {
    [_key release];
    [_data release];
    [super dealloc];
}
@end