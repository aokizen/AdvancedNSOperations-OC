//
//  GroupOperation.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "Operation.h"

@class OperationQueue;

@interface GroupOperation : Operation

@property (strong, nonatomic, readonly) OperationQueue *internalQueue;
@property (strong, nonatomic, readonly) NSOperation *startingOperation;
@property (strong, nonatomic, readonly) NSOperation *finishOperation;

- (instancetype)initWithOperations:(NSArray *)operations;

- (void)addOperation:(NSOperation *)operation;
- (void)aggregateError:(NSError *)error;
- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors;

@end
