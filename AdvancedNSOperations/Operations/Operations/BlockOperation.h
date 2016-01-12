//
//  BlockOperation.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "Operation.h"

typedef void (^OperationBlock) (void);

@interface BlockOperation : Operation

- (instancetype)initWithBlock:(OperationBlock)block;

@end
