//
//  OperationErrors.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

extern NSString * const OperationErroDomain;

typedef enum : NSInteger {
    OperationErrorCodeConditionFailed = 1,
    OperationErrorCodeExecutionFailed = 2,
}OperationErrorCode;

@interface NSError (Operation)

- (instancetype)initWithCode:(NSInteger)code userInfo:(NSDictionary *)dict;

- (BOOL)isTheSameError:(NSError *)error;

@end
