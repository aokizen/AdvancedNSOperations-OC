//
//  OperationQueue.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

@protocol OperationQueueDelegate;

/**
 `OperationQueue` is an `NSOperationQueue` subclass that implements a large
 number of "extra features" related to the `Operation` class:
 
 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
@interface OperationQueue : NSOperationQueue

@property (weak, nonatomic) id<OperationQueueDelegate> delegate;

@end

@protocol OperationQueueDelegate <NSObject>

@optional
- (void)operationQueue:(OperationQueue *)operationQueue willAddOperation:(NSOperation *)operation;
- (void)operationQueue:(OperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors;

@end
