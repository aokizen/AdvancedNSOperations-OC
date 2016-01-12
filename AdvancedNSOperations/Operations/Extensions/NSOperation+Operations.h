//
//  NSOperation+Operations.h
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import <Foundation/Foundation.h>

@interface NSOperation (Operations)

- (void)addCompletionBlock:(void (^)(void))block;
- (void)addDenpendencies:(NSArray *)dependencies;

@end
