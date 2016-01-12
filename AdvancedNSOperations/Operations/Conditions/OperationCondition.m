//
//  OperationCondition.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "OperationCondition.h"

#import "Operation.h"

#import "OperationErrors.h"

@implementation OperationConditionResult

- (BOOL)isEqualToResult:(OperationConditionResult *)result {
    if (self.state == result.state) {
        
        if (self.state == OperationConditionResultStateSatisfied) {
            return YES;
        }
        else if (self.error && result.error){
            if ([self.error isTheSameError:result.error]) {
                return YES;
            }
        }
    }
    return NO;
}

@end

@implementation OperationConditionEvaluator

+ (void)evaluateConditions:(NSArray *)conditions forOperation:(Operation *)operation completion:(void (^)(NSArray *errors))completion {
    
    dispatch_group_t conditionGroup = dispatch_group_create();
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:conditions];
    
    for (int index = 0; index < conditions.count; index ++) {
        id<OperationCondition> condition = [conditions objectAtIndex:index];
        dispatch_group_enter(conditionGroup);
        [condition evaluateForOperation:operation completion:^(OperationConditionResult *result) {
            [results replaceObjectAtIndex:index withObject:result];
            dispatch_group_leave(conditionGroup);
        }];
    }
    
    dispatch_group_notify(conditionGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        NSMutableArray *failures = [NSMutableArray array];
        for (OperationConditionResult *result in results) {
            if (result.error) {
                [failures addObject:result.error];
            }
        }
        
        if (operation.cancelled) {
            [failures addObject:[[NSError alloc] initWithCode:OperationErrorCodeConditionFailed userInfo:nil]];
        }
        
        if (completion) {
            completion(failures);
        }
    });
}

@end
