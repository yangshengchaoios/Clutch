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

#define __Print(l, s, ...) do { \
NSMutableString *logString = [NSMutableString stringWithFormat:@"[%@][%@(%d)] ",l, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__]; \
if (s) { [logString appendFormat:(s), ##__VA_ARGS__]; } else { [logString appendString:@"(null)"]; } \
printf("%s\n", logString.UTF8String); \
} while(0);


#define KJPrint(...) do { \
__Print(@"Normal ", __VA_ARGS__) \
} while(0);

#define KJPrintVerbose(...) do { \
if (KJPrintCurrentLogLevel < KJPrintLogLevelVerbose) { break; } \
__Print(@"Verbose", __VA_ARGS__) \
} while(0);

#define KJDebug(...) do { \
if (KJPrintCurrentLogLevel < KJPrintLogLevelDebug) { break; } \
__Print(@"Debug  ", __VA_ARGS__) \
} while(0);
