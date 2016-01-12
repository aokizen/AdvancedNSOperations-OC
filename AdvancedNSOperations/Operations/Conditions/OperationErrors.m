//
//  OperationErrors.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "OperationErrors.h"

NSString * const OperationErroDomain = @"OperationErrors";

@implementation NSError (Operation)

- (instancetype)initWithCode:(NSInteger)code userInfo:(NSDictionary *)dict {
    self = [self initWithDomain:OperationErroDomain code:code userInfo:dict];
    return self;
}

- (BOOL)isTheSameError:(NSError *)error {
    return ([self.domain isEqualToString:error.domain] && self.code == error.code);
}

@end
