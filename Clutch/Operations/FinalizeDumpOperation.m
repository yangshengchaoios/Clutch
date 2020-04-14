//
//  FinalizeDumpOperation.m
//  Clutch
//
//  Created by Anton Titkov on 12.02.15.
//
//

#import "FinalizeDumpOperation.h"
#import "Application.h"
#import "ClutchPrint.h"
#import "ZipArchive.h"
#import "ZipOperation.h"
#import <sys/time.h>

NSInteger diff_ms(struct timeval, struct timeval);
extern struct timeval gStart;

@interface FinalizeDumpOperation () {
    Application *_application;
    BOOL _executing, _finished;
    ZipArchive *_archive;
}
@end

@implementation FinalizeDumpOperation

- (nullable instancetype)init {
    return [self initWithApplication:nil];
}

- (nullable instancetype)initWithApplication:(nullable Application *)application {
    if (!application) {
        return nil;
    }
    self = [super init];
    if (self) {
        _executing = NO;
        _finished = NO;
        _application = application;
    }
    return self;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if (self.cancelled) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    NSString __weak *bundleIdentifier = _application.bundleIdentifier;
    self.completionBlock = ^{
        struct timeval end;
        gettimeofday(&end, NULL);
        NSInteger dif = diff_ms(end, gStart);
        CGFloat sec = ((dif + 500.0f) / 1000.0f);
        KJPrint(@"Finished dumping %@ in %0.1f seconds", bundleIdentifier, sec);
    };

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @try {
        if (_onlyBinaries) {
            NSDirectoryEnumerator *dirEnumerator =
                [NSFileManager.defaultManager enumeratorAtURL:[NSURL fileURLWithPath:_application.workingPath]
                                   includingPropertiesForKeys:@[ NSURLNameKey, NSURLIsDirectoryKey ]
                                                      options:0
                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                     CLUTCH_UNUSED(url);
                                                     CLUTCH_UNUSED(error);
                                                     return YES;
                                                 }];
            NSMutableArray *plists = [NSMutableArray new];
            for (NSURL *theURL in dirEnumerator) {
                NSNumber *isDirectory;
                [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
                if ([theURL.lastPathComponent isEqualToString:@"filesToAdd.plist"]) {
                    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:theURL];
                    if (dict) {
                        [plists addObject:theURL.path];
                    }
                    [[NSFileManager defaultManager] removeItemAtURL:theURL error:nil];
                }
            }
            __block BOOL status = plists.count == self.expectedBinariesCount;
            if (status) {
                KJPrint(@"Finished dumping %@ to %@", _application.bundleIdentifier, _application.workingPath);
            } else {
                KJPrint(@"Failed to dump %@ :(", _application.bundleIdentifier);
                return;
            }
            [self completeOperation];
            return;
        }

        if (_archive == nil) {
            _archive = [[ZipArchive alloc] init];
            [_archive CreateZipFile2:_application.ipaPath append:YES];
        }
        
        // add dumped binaries to ipa
        BOOL dumpedResult = NO;
        {
            NSDirectoryEnumerator *dirEnumerator =
                [NSFileManager.defaultManager enumeratorAtURL:[NSURL fileURLWithPath:_application.workingPath]
                                   includingPropertiesForKeys:@[ NSURLNameKey, NSURLIsDirectoryKey ]
                                                      options:0
                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                     CLUTCH_UNUSED(url);
                                                     CLUTCH_UNUSED(error);
                                                     return YES;
                                                 }];
            NSMutableArray *plists = [NSMutableArray new];
            for (NSURL *theURL in dirEnumerator) {
                NSNumber *isDirectory;
                [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
                if ([theURL.lastPathComponent isEqualToString:@"filesToAdd.plist"]) {
                    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:theURL];
                    if (dict) {
                        for (NSString *key in dict.allKeys) {
                            NSString *zipPath = dict[key];
                            [_archive addFileToZip:key newname:zipPath];
                            KJDebug(@"Added %@", zipPath);
                        }
                        [plists addObject:theURL.path];
                    }
                }
            }
            [_archive CloseZipFile2];
            KJPrint(@"Dumped binaries count: %ld", plists.count);
            KJPrint(@"Expected binaries count: %ld", self.expectedBinariesCount);
            dumpedResult = (plists.count == self.expectedBinariesCount);
        }
        
        NSString *dumpedIpaPath = [@"/private/var/mobile/Documents/Dumped" stringByAppendingPathComponent:_application.zipFilename];
        if (dumpedResult) {
            [[NSFileManager defaultManager] createDirectoryAtPath:@"/private/var/mobile/Documents/Dumped" withIntermediateDirectories:YES attributes:nil error:nil];
            if ([[NSFileManager defaultManager] fileExistsAtPath:dumpedIpaPath]) {
                KJPrint(@"Remove old ipa '%@'", dumpedIpaPath);
                [[NSFileManager defaultManager] removeItemAtPath:dumpedIpaPath error:nil];
            }
            NSError *anError;
            if ( ! [[NSFileManager defaultManager] moveItemAtPath:_application.ipaPath toPath:dumpedIpaPath error:&anError]) {
                KJPrint(@"Failed to move from '%@' to '%@' with error: %@", _application.ipaPath, dumpedIpaPath, anError);
            } else {
                KJPrint(@"Success move ipa from '%@' to '%@'", _application.ipaPath, dumpedIpaPath);
            }
            
            // clean
            KJPrint(@"Remove tmp dir: %@", _application.workingPath);
            [[NSFileManager defaultManager] removeItemAtPath:_application.workingPath error:nil];
        } else {
            KJPrint(@"Dump failed!!! tmp ipa path '%@'", _application.ipaPath);
        }

        // Do the main work of the operation here.
        [self completeOperation];
    } @catch (...) {
        // Do not rethrow exceptions.
    }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (NSUInteger)hash {
    return 4201234;
}

@end
