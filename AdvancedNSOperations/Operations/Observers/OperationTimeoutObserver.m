//
//  OperationTimeoutObserver.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "OperationTimeoutObserver.h"

#import "Operation.h"

#import "OperationErrors.h"

static NSString * timeoutKey = @"OperationTimeout";

@interface OperationTimeoutObserver ()

@property(assign, nonatomic, readonly) NSTimeInterval timeout;

@end

@implementation OperationTimeoutObserver

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = [self init];
    if (self) {
        _timeout = timeout;
    }
    return self;
}

- (void)operationDidStart:(Operation *)operation {
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (long)(self.timeout * NSEC_PER_SEC));
    
    dispatch_after(when, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        if (!operation.finished && !operation.cancelled) {
            NSError *error = [[NSError alloc] initWithCode:OperationErrorCodeExecutionFailed userInfo:@{timeoutKey : @(self.timeout)}];
            
            [operation cancelWithError:error];
        }
    });
}

- (void)operation:(Operation *)operation didProduceOperation:(NSOperation *)newOperation {
    
}

- (void)operationDidFinishe:(Operation *)operation errors:(NSArray *)errors {
    
}


@end
