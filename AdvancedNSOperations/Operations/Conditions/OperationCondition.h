//
//  OperationCondition.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

@class Operation;

typedef enum : NSInteger {
    OperationConditionResultStateSatisfied,
    OperationConditionResultStateFailed,
} OperationConditionResultState;

@interface OperationConditionResult : NSObject

@property (assign, nonatomic) OperationConditionResultState state;
@property (strong, nonatomic) NSError *error;

- (BOOL)isEqualToResult:(OperationConditionResult *)result;

@end

@protocol OperationCondition <NSObject>

/**
 The name of the condition. This is used in userInfo dictionaries of `.ConditionFailed`
 errors as the value of the `OperationConditionKey` key.
 */
- (NSString *)name;

/**
 Specifies whether multiple instances of the conditionalized operation may
 be executing simultaneously.
 */
- (BOOL)isMutuallyExclusive;

/**
 Some conditions may have the ability to satisfy the condition if another
 operation is executed first. Use this method to return an operation that
 (for example) asks for permission to perform the operation
 
 - parameter operation: The `Operation` to which the Condition has been added.
 - returns: An `NSOperation`, if a dependency should be automatically added. Otherwise, `nil`.
 - note: Only a single operation may be returned as a dependency. If you
 find that you need to return multiple operations, then you should be
 expressing that as multiple conditions. Alternatively, you could return
 a single `GroupOperation` that executes multiple operations internally.
 */
- (NSOperation *)dependencyForOperation:(Operation *)operation;


- (void)evaluateForOperation:(Operation *)operation completion:(void (^)(OperationConditionResult *result))completion;

@end

@interface OperationConditionEvaluator : NSObject

+ (void)evaluateConditions:(NSArray *)conditions forOperation:(Operation *)operation completion:(void (^)(NSArray *errors))completion;

@end
