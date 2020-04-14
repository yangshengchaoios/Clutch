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
NSMutableString *logString = [NSMutableString stringWithFormat:@"[%@][%d][%@(%d)] ",l, getpid(), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__]; \
if (s) { [logString appendFormat:(s), ##__VA_ARGS__]; } else { [logString appendString:@"(null)"]; } \
printf("%s\n", logString.UTF8String); \
} while(0);


#define KJPrint(...)        __Print(@"Normal ", __VA_ARGS__)
#define KJPrintVerbose(...) if (KJPrintCurrentLogLevel >= KJPrintLogLevelVerbose) { __Print(@"Verbose", __VA_ARGS__); }
#define KJDebug(...)        if (KJPrintCurrentLogLevel >= KJPrintLogLevelDebug) { __Print(@"Debug  ", __VA_ARGS__); }
