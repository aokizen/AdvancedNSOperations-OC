//
//  OperationObserver.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

@class Operation;

@protocol OperationObserver <NSObject>

- (void)operationDidStart:(Operation *)operation;

- (void)operation:(Operation *)operation didProduceOperation:(NSOperation *)newOperation;

- (void)operationDidFinishe:(Operation *)operation errors:(NSArray *)errors;

@end
