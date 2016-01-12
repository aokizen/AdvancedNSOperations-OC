//
//  NSOperation+Operations.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "NSOperation+Operations.h"

@implementation NSOperation (Operations)

- (void)addCompletionBlock:(void (^)(void))block {
    
    void (^existing)(void) = self.completionBlock;
    
    if (existing) {
        /*
         If we already have a completion block, we construct a new one by
         chaining them together.
         */
        self.completionBlock = ^(void) {
            existing();
            block();
        };
    }
    else {
        self.completionBlock = block;
    }
}

- (void)addDenpendencies:(NSArray *)dependencies {
    for (NSOperation *dependency in dependencies) {
        [self addDependency:dependency];
    }
}

@end
