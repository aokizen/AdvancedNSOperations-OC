//
//  OperationTimeoutObserver.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

#import "OperationObserver.h"

@interface OperationTimeoutObserver : NSObject <OperationObserver>

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end
