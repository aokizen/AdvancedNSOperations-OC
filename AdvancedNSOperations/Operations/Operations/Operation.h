//
//  Operation.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

#import "OperationCondition.h"
#import "OperationObserver.h"

typedef NS_ENUM(NSInteger, OperationState) {
    OperationStateInitialized = 0,
    OperationStatePending,
    OperationStateEvaluatingConditions,
    OperationStateReady,
    OperationStateExecuting,
    OperationStateFinishing,
    OperationStateFinished,
};

@interface Operation : NSOperation

@property (nonatomic, assign) OperationState state;
@property (assign, nonatomic) BOOL userInitiated;
@property (strong, nonatomic, readonly) NSArray *errors;

@property (strong, nonatomic, readonly) NSArray *conditions;
@property (strong, nonatomic, readonly) NSArray *observers;

+ (NSSet *)keyPathsForValuesAffectingIsReady;
+ (NSSet *)keyPathsForValuesAffectingIsExecuting;
+ (NSSet *)keyPathsForValuesAffectingIsFinished;

- (void)willEnqueue;

- (void)addCondition:(id<OperationCondition>)condition;
- (void)addObserver:(id<OperationObserver>)observer;

- (void)execute;
- (void)cancelWithError:(NSError *)error;

- (void)produceOperation:(NSOperation *)operation;

- (void)finishWithError:(NSError *)error;
- (void)finish:(NSArray *)errors;
- (void)finished:(NSArray *)errors;

@end
