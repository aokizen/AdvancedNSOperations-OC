//
//  ExclusivityController.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

@class Operation;

@interface ExclusivityController : NSObject

+ (instancetype)shareExclusivityController;

- (void)addOperation:(Operation *)operation categories:(NSArray *)categories;
- (void)removeOperation:(Operation *)operation categories:(NSArray *)categories;

@end
