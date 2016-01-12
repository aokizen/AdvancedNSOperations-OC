//
//  GroupOperation.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "GroupOperation.h"

#import "OperationQueue.h"

@interface GroupOperation () <OperationQueueDelegate>

@property (strong, nonatomic) NSMutableArray *aggregatedErrors;

@end

@implementation GroupOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _aggregatedErrors = [NSMutableArray array];
        
        _startingOperation = [NSBlockOperation blockOperationWithBlock:^(void) { }];
        _finishOperation = [NSBlockOperation blockOperationWithBlock:^(void) { }];
        
        _internalQueue = [[OperationQueue alloc] init];
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;
        [_internalQueue addOperation:_startingOperation];
    }
    return self;
}

- (instancetype)initWithOperations:(NSArray *)operations {
    self = [self init];
    if (self) {
        
        for (NSOperation *operation in operations) {
            [_internalQueue addOperation:operation];
        }
    }
    return self;
}

- (void)cancel {
    [self.internalQueue cancelAllOperations];
    [super cancel];
}

- (void)execute {
    self.internalQueue.suspended = NO;
    [self.internalQueue addOperation:self.finishOperation];
}

- (void)addOperation:(NSOperation *)operation {
    [self.internalQueue addOperation:operation];
}

- (void)aggregateError:(NSError *)error {
    [self.aggregatedErrors addObject:error];
}

- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors {
    
}

#pragma mark - OperationQueueDelegate
- (void)operationQueue:(OperationQueue *)operationQueue willAddOperation:(NSOperation *)operation {
    if (!self.finishOperation.finished && !self.finishOperation.executing) {
        
        /*
         Some operation in this group has produced a new operation to execute.
         We want to allow that operation to execute before the group completes,
         so we'll make the finishing operation dependent on this newly-produced operation.
         */
        if (operation != self.finishOperation) {
            [self.finishOperation addDependency:operation];
        }
        
        /*
         All operations should be dependent on the "startingOperation".
         This way, we can guarantee that the conditions for other operations
         will not evaluate until just before the operation is about to run.
         Otherwise, the conditions could be evaluated at any time, even
         before the internal operation queue is unsuspended.
         */
        if (operation != self.startingOperation) {
            [operation addDependency:self.startingOperation];
        }
    }
}

- (void)operationQueue:(OperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors {
    
    if (errors) {
        [self.aggregatedErrors addObjectsFromArray:errors];
    }
    
    if (operation == self.finishOperation) {
        self.internalQueue.suspended = YES;
        [self finish:self.aggregatedErrors];
    }
    else if (operation != self.startingOperation) {
        [self operationDidFinish:operation withErrors:errors];
    }
}


@end
