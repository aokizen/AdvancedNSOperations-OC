//
//  OperationBlockObserver.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "OperationBlockObserver.h"

@interface OperationBlockObserver ()

@property (strong, nonatomic) void (^startHandler)(Operation *operation);
@property (strong, nonatomic) void (^produceHandler)(Operation *operation, NSOperation *newOperation);
@property (strong, nonatomic) void (^finishHandler)(Operation *operation, NSArray *errors);

@end

@implementation OperationBlockObserver

- (void)dealloc {
    [self setStartHandler:nil];
    [self setProduceHandler:nil];
    [self setFinishHandler:nil];
}

- (instancetype)initWithStartHandler:(void (^)(Operation *))startHandler produceHandler:(void (^)(Operation *, NSOperation *))produceHandler finishHandler:(void (^)(Operation *, NSArray *))finishHandler {
    self = [self init];
    if (self) {
        _startHandler = startHandler;
        _produceHandler = produceHandler;
        _finishHandler = finishHandler;
    }
    return self;
}

- (void)operationDidStart:(Operation *)operation {
    if (self.startHandler) {
        self.startHandler(operation);
    }
}

- (void)operation:(Operation *)operation didProduceOperation:(NSOperation *)newOperation {
    if (self.produceHandler) {
        self.produceHandler(operation, newOperation);
    }
}

- (void)operationDidFinishe:(Operation *)operation errors:(NSArray *)errors {
    if (self.finishHandler) {
        self.finishHandler(operation, errors);
    }
}


@end
