#include <execinfo.h>
#import "SentryStacktraceBuilder.h"
#import "SentryFrame.h"
#import "SentryStacktrace.h"
#import "SentryThread.h"
#import <Foundation/Foundation.h>

@implementation SentryStacktraceBuilder

+ (SentryStacktrace *)buildStacktraceForCurrentThread
{
    NSArray<NSString *> *callStackSymbols = [NSThread callStackSymbols];
    [NSThread callStackReturnAddresses];
    
    void *array[10];
    size_t size;
    char **strings;
    size_t i;
    
    size = backtrace (array, 10);
    strings = backtrace_symbols (array, size);
    
    printf ("Obtained %zd stack frames.\n", size);

    for (i = 0; i < size; i++)
       printf ("%s\n", strings[i]);

    free (strings);

    NSMutableArray<SentryFrame *> *frames = [NSMutableArray new];
    for (NSString *callStackSymbol in
        [callStackSymbols reverseObjectEnumerator]) {
        [frames addObject:[self fillFrame:callStackSymbol]];
    }

    return [[SentryStacktrace alloc] initWithFrames:frames registers:@{}];
}

// 0   Sentry                              0x0000000107956a82
// +[SentryStacktraceBuilder buildStacktraceForCurrentThread] + 82 1 SentryTests
// 0x000000010772eb50 $s11SentryTests0a7ThreadsB0C11testExampleyyF + 64,
+ (SentryFrame *)fillFrame:(NSString *)symbol
{

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
