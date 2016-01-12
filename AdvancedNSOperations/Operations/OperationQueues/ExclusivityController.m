//
//  ExclusivityController.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "ExclusivityController.h"

#import "Operation.h"

@interface ExclusivityController ()

@property (strong, nonatomic, readonly) dispatch_queue_t serialQueue;
@property (strong, nonatomic) NSMutableDictionary *operations;

@end

@implementation ExclusivityController

+ (instancetype)shareExclusivityController {
    static ExclusivityController *_shareExclusivityController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareExclusivityController = [[ExclusivityController alloc] init];
    });
    
    return _shareExclusivityController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("Operations.ExclusivityController", DISPATCH_QUEUE_SERIAL);
        _operations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addOperation:(Operation *)operation categories:(NSArray *)categories {
    
    dispatch_sync(_serialQueue, ^(void) {
        for (NSString *category in categories) {
            [self noqueue_addOperation:operation category:category];
        }
    });
}

- (void)removeOperation:(Operation *)operation categories:(NSArray *)categories {
    
    dispatch_sync(_serialQueue, ^(void) {
        for (NSString *category in categories) {
            [self noqueue_removeOperation:operation category:category];
        }
    });
}

- (void)noqueue_addOperation:(Operation *)operation category:(NSString *)category {
    
    NSMutableArray *operationsWithThisCategory = [NSMutableArray array];
    
    if ([self.operations objectForKey:category]) {
        [operationsWithThisCategory addObjectsFromArray:[self.operations objectForKey:category]];
    }
    NSOperation *last = [operationsWithThisCategory lastObject];
    if (last) {
        if (![operation.dependencies containsObject:last]) {
            [operation addDependency:last];
        }
    }
    
    if (![operationsWithThisCategory containsObject:operation]) {
        [operationsWithThisCategory addObject:operation];
        [self.operations setObject:operationsWithThisCategory forKey:category];
    }
}

- (void)noqueue_removeOperation:(Operation *)operation category:(NSString *)category {
    
    if ([self.operations objectForKey:category]) {
        NSMutableArray *operationsWithThisCategory = [NSMutableArray array];
        [operationsWithThisCategory addObjectsFromArray:[self.operations objectForKey:category]];
        
        if ([operationsWithThisCategory containsObject:operation]) {
            NSInteger index = [operationsWithThisCategory indexOfObject:operation];
            [operationsWithThisCategory removeObjectAtIndex:index];
            
            [self.operations setObject:operationsWithThisCategory forKey:category];
        }
    }
    
}

@end
