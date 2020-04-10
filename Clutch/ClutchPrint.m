//
//  ClutchPrint.m
//  Clutch
//
//  Created by dev on 15/02/2016.
//
//

#import "ClutchPrint.h"

NSUInteger KJPrintCurrentLogLevel = KJPrintLogLevelDebug;

//static NSInteger KJPrintv(NSString *format, NSString *logLevel, const char *sourceFilePath, int sourceLineNo, va_list ap) {
//    if (![format hasSuffix:@"\n"]) {
//        format = [format stringByAppendingString:@"\n"];
//    }
//    NSString *s = [[NSString alloc] initWithFormat:format arguments:ap];
//    NSString *log = [NSString stringWithFormat:@"[%@][%@:%d]-> %@", logLevel, [NSString stringWithUTF8String:sourceFilePath].lastPathComponent, sourceLineNo, s];
//    return printf("%s", log.UTF8String);
//}
//
//void KJPrint(NSString *format, ...) {
//    va_list ap;
//    va_start(ap, format);
//    KJPrintv(format, @"Normal", __FILE__, __LINE__, ap);
//    va_end(ap);
//}
//
//void KJPrintVerbose(NSString *format, ...) {
//    if (KJPrintCurrentLogLevel < KJPrintLogLevelVerbose) {
//        return ;
//    }
//    va_list ap;
//    va_start(ap, format);
//    KJPrintv(format, @"Verbose", __FILE__, __LINE__, ap);
//    va_end(ap);
//}
//
//void KJDebug(NSString *format, ...) {
//    if (KJPrintCurrentLogLevel < KJPrintLogLevelDebug) {
//        return ;
//    }
//    va_list ap;
//    va_start(ap, format);
//    KJPrintv(format, @"Debug", __FILE__, __LINE__, ap);
//    va_end(ap);
//}
