//
//  ClutchPrint.h
//  Clutch
//
//  Created by dev on 15/02/2016.
//
//

FOUNDATION_EXTERN NSUInteger KJPrintCurrentLogLevel;
typedef NS_ENUM(NSUInteger, KJPrintLogLevel) {
    KJPrintLogLevelNormal = 0,
    KJPrintLogLevelVerbose = 1,
    KJPrintLogLevelDebug = 2,
};

#define __NSLog(s, ...) do { \
NSMutableString *logString = [NSMutableString stringWithFormat:@"[%@(%d)] ",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__]; \
if (s) { \
[logString appendFormat:(s), ##__VA_ARGS__]; \
} \
else { \
    [logString appendString:@"(null)"]; \
} \
NSLog(@"%@", logString); \
} while(0);

#define SGLog(...) __NSLog(__VA_ARGS__)




#define __Print(l,f,n,c) do { \
NSString *log = [NSString stringWithFormat:@"[%@][%@:%d]-> %@",l, [NSString stringWithUTF8String:f].lastPathComponent, n, c]; \
printf("%s\n", log.UTF8String); \
} while(0);

#define KJPrint(...) do { \
NSString *s = @"TODO: "; \
__Print(@"Normal ", __FILE__, __LINE__, s) \
} while(0);

#define KJPrintVerbose(...) do { \
if (KJPrintCurrentLogLevel < KJPrintLogLevelVerbose) { break; } \
NSString *s = @"TODO: "; \
__Print(@"Verbose", __FILE__, __LINE__, s) \
} while(0);

#define KJDebug(...) do { \
if (KJPrintCurrentLogLevel < KJPrintLogLevelDebug) { break; } \
NSString *s = @"TODO: "; \
__Print(@"Debug  ", __FILE__, __LINE__, s) \
} while(0);
