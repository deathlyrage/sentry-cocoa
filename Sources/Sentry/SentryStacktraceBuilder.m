#include <execinfo.h>
#import "SentryStacktraceBuilder.h"
#import "SentryFrame.h"
#import "SentryStacktrace.h"
#import "SentryThread.h"
#import "SentryCrashThread.h"
#import "SentryCrashMachineContext.h"
#import "SentryCrashMonitorContext.h"
#import "SentryCrashDynamicLinker.h"
#import "SentryCrashStackCursor.h"
#import "SentryCrashCachedData.h"
#import "SentryCrashCPU.h"
#import "SentryCrashStackCursor_SelfThread.h"
#import <Foundation/Foundation.h>

#define kStackContentsPushedDistance 20
#define kStackContentsPoppedDistance 10

@implementation SentryStacktraceBuilder

+ (SentryStacktrace *)buildStacktraceForCurrentThread {
    NSMutableArray<SentryFrame *> *frames = [NSMutableArray new];

    const int imageCount = sentrycrashdl_imageCount();
    for (int iImg = 0; iImg < imageCount; iImg++) {
        SentryCrashBinaryImage image = {0};
        sentrycrashdl_getBinaryImage(iImg, &image);
        image.address;

        SentryFrame *frame = [[SentryFrame alloc] init];


    }

    SentryCrashMC_NEW_CONTEXT(baseThreadContext);
    sentrycrashmc_getContextForThread(
            sentrycrashthread_self(), baseThreadContext, true);
    int threadCount = sentrycrashmc_getThreadCount(baseThreadContext);

    SentryCrashMC_NEW_CONTEXT(iteratingContext);
    for (int i = 0; i < threadCount; i++) {
        SentryCrashThread thread
                = sentrycrashmc_getThreadAtIndex(baseThreadContext, i);

        sentrycrashmc_getContextForThread(
                thread, iteratingContext, true);

        const char *threadName = sentrycrashccd_getThreadName(thread);
        const char *queueName = sentrycrashccd_getQueueName(thread);

        SentryCrashStackCursor *stackCursor;
        sentrycrashsc_initSelfThread(stackCursor, 0);

        while (stackCursor->advanceCursor(stackCursor)) {

            if (stackCursor->symbolicate(stackCursor)) {
                if (stackCursor->stackEntry.imageName != NULL) {
                    stackCursor->stackEntry.imageName;
                }
                stackCursor->stackEntry.imageAddress;
                if (stackCursor->stackEntry.symbolName != NULL) {
                    stackCursor->stackEntry.symbolName;
                }
                stackCursor->stackEntry.symbolAddress;
            }

            stackCursor->stackEntry.address;
        }


        uintptr_t sp = sentrycrashcpu_stackPointer(iteratingContext);
        if ((void *) sp == NULL) {
            continue;
        }

        uintptr_t lowAddress = sp
                + (uintptr_t) (kStackContentsPushedDistance * (int) sizeof(sp)
                * sentrycrashcpu_stackGrowDirection() * -1);
        uintptr_t highAddress = sp
                + (uintptr_t) (kStackContentsPoppedDistance * (int) sizeof(sp)
                * sentrycrashcpu_stackGrowDirection());
        if (highAddress < lowAddress) {
            uintptr_t tmp = lowAddress;
            lowAddress = highAddress;
            highAddress = tmp;
        }

        int oo = 20;
    }


    return [[
            SentryStacktrace alloc
    ] initWithFrames:@[] registers:@{
    }];
}

// 0   Sentry                              0x0000000107956a82
// +[SentryStacktraceBuilder buildStacktraceForCurrentThread] + 82 1 SentryTests
// 0x000000010772eb50 $s11SentryTests0a7ThreadsB0C11testExampleyyF + 64,
+ (SentryFrame *)fillFrame:(NSString *)symbol {

    SentryFrame *frame = [[SentryFrame alloc] init];
    frame.package = [symbol substringWithRange:NSMakeRange(4, 35)];
    frame.instructionAddress = [symbol substringWithRange:NSMakeRange(40, 18)];

    NSString *functionInfo = [symbol substringFromIndex:59];
    NSRange range = [functionInfo rangeOfString:@"+" options:NSBackwardsSearch];
    if (range.length > 0) {
        frame.function = [functionInfo substringToIndex:range.location - 1];

        NSString *lineNumber =
                [functionInfo substringFromIndex:range.location + 2];
        frame.lineNumber = [NSNumber numberWithInt:[lineNumber integerValue]];
    } else {
        frame.function = functionInfo;
    }

    return frame;
}

@end

// NSLog(@"a %@", [NSThread callStackSymbols]);
//   NSLog(@"b %@", [NSThread callStackReturnAddresses]);
//   NSString *sourceString =
//       [NSString stringWithFormat:@"%@", [NSThread callStackSymbols]];
//
//   NSCharacterSet *separatorSet =
//       [NSCharacterSet characterSetWithCharactersInString:@"\n"];
//   NSMutableArray *array = [NSMutableArray
//       arrayWithArray:[sourceString
//                          componentsSeparatedByCharactersInSet:separatorSet]];
//   [array removeObject:@""];
//
//   NSLog(@"Source %@", sourceString);
//   NSLog(@"Stack = %@", [array objectAtIndex:0]);
//   NSLog(@"Framework = %@", [array objectAtIndex:1]);
//   NSLog(@"Memory address = %@", [array objectAtIndex:2]);
//   NSLog(@"Class caller = %@", [array objectAtIndex:3]);
//   NSLog(@"Function caller = %@", [array objectAtIndex:4]);
