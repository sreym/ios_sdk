//
//  window_timers.m
//  SparkLib
//
//  Created by alexeym on 04/08/16.
//  Copyright © 2017 hola. All rights reserved.
//
//  NOTE: This file copied from HolaCDN ios_sdk with minimum modifications.
//  Entire loader submodule will be reused by HolaCDN once added to SparkLib.
//  XXX volodymyr: fix conventions
//


#import "window_timers.h"

@implementation WTWindowTimers {
    NSUInteger _timeoutCounter;
    dispatch_queue_t _queue;
    NSMapTable *_dispatchSourcesMapping;
}

- (instancetype)init {
    if (self = [super init]) {
        _timeoutCounter = 0;
        _queue = dispatch_get_main_queue();
        _dispatchSourcesMapping = [NSMapTable weakToWeakObjectsMapTable];
        _tolerance = 10;
    }
    return self;
}

- (void)extend:(id)context {
    context[@"setTimeout"] = self.setTimeout;
    context[@"clearTimeout"] = self.clearTimeout;
    context[@"setInterval"] = self.setInterval;
    context[@"clearInterval"] = self.clearTimeout;
}

- (NSNumber*)intervalWithCallable:(JSValue*)function timeout:(JSValue*)timeout arguments:(NSArray*)arguments isInterval:(bool)isInterval {
    __block NSNumber *timeoutID = @(_timeoutCounter += 1);
    __block dispatch_source_t dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_event_handler(dispatchSource, ^{
        if (!isInterval) {
            dispatch_source_cancel(dispatchSource);
        }

        // Unfortunately, JavaScript allows it that the first argument is a string which will be
        // evaluated as callback.
        if ([function isString]) {
            [function.context evaluateScript:[function toString]];
            // In all other cases, execute the callback. TODO explain the arguments.
        } else {
            [function callWithArguments:arguments];
        }

    });
    dispatch_time_t dispatchInterval = [timeout toUInt32] * NSEC_PER_MSEC;
    dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, dispatchInterval);
    dispatch_source_set_timer(dispatchSource, dispatchTime, isInterval ? dispatchInterval : DISPATCH_TIME_FOREVER, _tolerance * NSEC_PER_MSEC);
    dispatch_resume(dispatchSource);
    [_dispatchSourcesMapping setObject:dispatchSource forKey:timeoutID];

    return timeoutID;
}

- (id)setTimeout {
    return ^(JSValue* function, JSValue* timeout) {
        NSArray *originalArguments = [JSContext currentArguments];
        NSArray *arguments = @[];
        if ([originalArguments count] > 2) {
            arguments = [originalArguments subarrayWithRange:NSMakeRange(2, [originalArguments count] - 2)];
        }
        return [self intervalWithCallable:function timeout:timeout arguments:arguments isInterval:NO];
    };
}

- (id)clearTimeout {
    return ^(NSNumber* timeout) {
        dispatch_source_t source = [_dispatchSourcesMapping objectForKey:timeout];
        if (source != nil) {
            dispatch_source_cancel(source);
        }
    };
}

- (id)setInterval {
    return ^(JSValue* function, JSValue* timeout, ...) {
        NSArray* originalArguments = [JSContext currentArguments];
        NSArray* arguments = @[];
        if ([originalArguments count] > 2) {
            arguments = [originalArguments subarrayWithRange:NSMakeRange(2, [originalArguments count] - 2)];
        }
        return [self intervalWithCallable:function timeout:timeout arguments:arguments isInterval:YES];
    };
}

@end
