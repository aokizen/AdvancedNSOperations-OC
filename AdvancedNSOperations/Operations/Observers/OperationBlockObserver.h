//
//  OperationBlockObserver.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

#import "OperationObserver.h"

@class Operation;

@interface OperationBlockObserver : NSObject <OperationObserver>

- (instancetype)initWithStartHandler:(void (^)(Operation *operation))startHandler produceHandler:(void (^)(Operation *operation, NSOperation *newOperation))produceHandler finishHandler:(void (^)(Operation *operation, NSArray *errors))finishHandler;


@end
