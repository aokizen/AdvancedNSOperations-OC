//
//  BlockOperation.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "BlockOperation.h"

@interface BlockOperation ()

@property (assign, nonatomic) OperationBlock block;

@end

@implementation BlockOperation

- (instancetype)initWithBlock:(OperationBlock)block {
    self = [self init];
    if (self) {
        _block = block;
    }
    return self;
}

- (void)execute {
    
    if (self.block) {
        self.block();
    }
    
    [self finish:nil];
}

@end
