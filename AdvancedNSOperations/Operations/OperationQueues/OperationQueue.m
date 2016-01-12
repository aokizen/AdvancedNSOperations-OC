//
//  OperationQueue.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "OperationQueue.h"

#import "Operation.h"
#import "OperationBlockObserver.h"

#import "OperationCondition.h"
#import "ExclusivityController.h"

#import "NSOperation+Operations.h"

@implementation OperationQueue

- (void)dealloc {
    _delegate = nil;
}

- (void)addOperation:(NSOperation *)op {
    
    if ([op isKindOfClass:[Operation class]]) {
        
        Operation *operation = (Operation *)op;
        
        __weak OperationQueue *weakSelf = self;
        
        id<OperationObserver> delegate = [[OperationBlockObserver alloc] initWithStartHandler:nil produceHandler:^(Operation *operat, NSOperation *newOperation) {
            if (weakSelf) {
                [weakSelf addOperation:newOperation];
            }
        } finishHandler:^(Operation *operat, NSArray *error) {
            OperationQueue *queue = weakSelf;
            if (queue) {
                if (queue.delegate && [queue.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                    [queue.delegate operationQueue:queue operationDidFinish:operat withErrors:error];
                }
            }
        }];
        [operation addObserver:delegate];
        
        NSMutableArray *dependencies = [NSMutableArray array];
        for (id<OperationCondition> condition in operation.conditions) {
            NSOperation *dependency = [condition dependencyForOperation:operation];
            if (dependency) {
                [dependencies addObject:dependency];
            }
        }
        
        for (NSOperation *dependency in dependencies) {
            [operation addDependency:dependency];
            
            [self addOperation:dependency];
        }
        
        /*
         With condition dependencies added, we can now see if this needs
         dependencies to enforce mutual exclusivity.
         */
        NSMutableArray *concurrencyCategories = [NSMutableArray array];
        for (id<OperationCondition> condition in operation.conditions) {
            if ([condition isMutuallyExclusive]) {
                [concurrencyCategories addObject:NSStringFromClass([condition class])];
            }
        }
        
        if (concurrencyCategories.count > 0) {
            ExclusivityController *exclusivityController = [ExclusivityController shareExclusivityController];
            [exclusivityController addOperation:operation categories:concurrencyCategories];
            
            [operation addObserver:[[OperationBlockObserver alloc] initWithStartHandler:^(Operation *operat) {
                [exclusivityController removeOperation:operat categories:concurrencyCategories];
            }produceHandler:nil finishHandler:nil]];
        }
        
        /*
         Indicate to the operation that we've finished our extra work on it
         and it's now it a state where it can proceed with evaluating conditions,
         if appropriate.
         */
        [operation willEnqueue];
    }
    else {
        
        __weak OperationQueue *weakSelf = self;
        __weak NSOperation *operation = op;
        
        [op addCompletionBlock:^(void) {
            
            OperationQueue *queue = weakSelf;
            if (queue && operation) {
                if (queue.delegate && [queue.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                    [queue.delegate operationQueue:queue operationDidFinish:operation withErrors:@[]];
                }
            }
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]) {
        [self.delegate operationQueue:self willAddOperation:op];
    }
    
    [super addOperation:op];
}

- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait {
    
    for (NSOperation *operation in ops) {
        [self addOperation:operation];
    }
    
    if (wait) {
        for (NSOperation *operation in ops) {
            [operation waitUntilFinished];
        }
    }
}

@end
