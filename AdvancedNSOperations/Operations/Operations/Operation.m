//
//  Operation.m
//  AdvancedNSOperations
//
//  Created by Jiangwei Wu on 16/1/12.
//
//

#import "Operation.h"

static inline BOOL OperationStateTransitionIsValid(OperationState fromState, OperationState targetState) {
    switch (targetState) {
        case OperationStatePending:
            return (fromState == OperationStateInitialized);
            break;
        case OperationStateEvaluatingConditions:
            return (fromState == OperationStatePending);
            break;
        case OperationStateReady:
            return (fromState == OperationStateEvaluatingConditions);
            break;
        case OperationStateExecuting:
            return (fromState == OperationStateReady);
            break;
        case OperationStateFinishing:
            return (fromState == OperationStateReady || fromState == OperationStateExecuting);
            break;
        case OperationStateFinished:
            return (fromState == OperationStateFinishing);
            break;
        default:
            return NO;
            break;
    }
}

@interface Operation ()

@property (strong, nonatomic) NSMutableArray *_internalErrors;
@property (assign, nonatomic) BOOL hasFinishedAlready;

@end

@implementation Operation

@synthesize state = _state;
@synthesize _internalErrors;

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = OperationStateInitialized;
        _internalErrors = [NSMutableArray array];
    }
    return self;
}

+ (NSSet *)keyPathsForValuesAffectingIsReady {
    return [NSSet setWithObject:@"state"];
}

+ (NSSet *)keyPathsForValuesAffectingIsExecuting {
    return [NSSet setWithObject:@"state"];
}

+ (NSSet *)keyPathsForValuesAffectingIsFinished {
    return [NSSet setWithObject:@"state"];
}

- (void)willEnqueue {
    self.state = OperationStatePending;
}

- (OperationState)state {
    @synchronized(self) {
        return _state;
    }
}

- (void)setState:(OperationState)state {
    
    @synchronized(self) {
        
        if (_state == OperationStateFinished) {
            return;
        }
        
        if (!OperationStateTransitionIsValid(_state, state)) {
            return;
        }
        
        if (_state == state) {
            return;
        }

        [self willChangeValueForKey:@"state"];
        
        _state = state;
        
        [self didChangeValueForKey:@"state"];
    }
}

- (BOOL)isReady {
    switch (self.state) {
        case OperationStateInitialized:
            return [self isCancelled];
            break;
        case OperationStatePending:
            if ([self isCancelled]) {
                return YES;
            }
            if ([super isReady]) {
                [self evaluateConditions];
            }
            return NO;
        case OperationStateReady:
            return ([super isReady] || [self isCancelled]);
        default:
            return NO;
            break;
    }
}

- (BOOL)userInitiated {
    if (![self respondsToSelector:@selector(setQualityOfService:)]) {
        return self.queuePriority == NSOperationQueuePriorityHigh;
    }
    return self.qualityOfService == NSQualityOfServiceUserInitiated;
}

- (void)setUserInitiated:(BOOL)userInitiated {
    if (self.state < OperationStateExecuting) {
        if (![self respondsToSelector:@selector(setQualityOfService:)]) {
            self.queuePriority = userInitiated ? NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
            return;
        }
        self.qualityOfService = userInitiated ? NSQualityOfServiceUserInitiated : NSQualityOfServiceDefault;
    }
}

- (NSArray *)errors {
    if (_internalErrors && _internalErrors.count > 0) {
        return _internalErrors;
    }
    else {
        return nil;
    }
}

- (BOOL)isExecuting {
    return self.state == OperationStateExecuting;
}

- (BOOL)isFinished {
    return self.state == OperationStateFinished;
}

- (void)evaluateConditions {
    
    if (self.state == OperationStatePending && ![self isCancelled]) {
        
        self.state = OperationStateEvaluatingConditions;
        
        [OperationConditionEvaluator evaluateConditions:self.conditions forOperation:self completion:^(NSArray *failures) {
            if (failures) {
                [_internalErrors addObjectsFromArray:failures];
            }
            self.state = OperationStateReady;
        }];
        
    }
}

- (void)addCondition:(id<OperationCondition>)condition {
    if (self.state < OperationStateEvaluatingConditions) {
        
        NSMutableArray *conditions = [NSMutableArray array];
        if (self.conditions) {
            [conditions addObjectsFromArray:self.conditions];
        }
        if (![conditions containsObject:condition]) {
            [conditions addObject:condition];
            _conditions = conditions;
        }
    }
}

- (void)addObserver:(id<OperationObserver>)observer {
    
    if (self.state < OperationStateExecuting) {
        
        NSMutableArray *observers = [NSMutableArray array];
        if (self.observers) {
            [observers addObjectsFromArray:self.observers];
        }
        if (![observers containsObject:observer]) {
            [observers addObject:observer];
            _observers = observers;
        }
    }
}

- (void)addDependency:(NSOperation *)op {
    if (self.state < OperationStateExecuting) {
        [super addDependency:op];
    }
}

- (void)start {
    [super start];
    
    if ([self isCancelled]) {
        [self finish:nil];
    }
}

- (void)main {
    
    if (self.state == OperationStateReady) {
        
        if (_internalErrors.count == 0 && ![self isCancelled]) {
            
            self.state = OperationStateExecuting;
            
            for (id<OperationObserver> observer in self.observers) {
                [observer operationDidStart:self];
            }
            
            [self execute];
        }
        else {
            [self finish:nil];
        }
    }
}

- (void)execute {
    
    
    [self finish:nil];
}

- (void)cancelWithError:(NSError *)error {
    if (error) {
        [_internalErrors addObject:error];
    }
    
    [self cancel];
}

- (void)produceOperation:(NSOperation *)operation {
    for (id<OperationObserver> observer in self.observers) {
        [observer operation:self didProduceOperation:operation];
    }
}

- (void)finishWithError:(NSError *)error {
    if (error) {
        [self finish:@[error]];
    }
    else {
        [self finish:nil];
    }
}

- (void)finish:(NSArray *)errors {
    if (!_hasFinishedAlready) {
        _hasFinishedAlready = YES;
        self.state = OperationStateFinishing;
        
        [_internalErrors addObjectsFromArray:errors];
        [self finished:_internalErrors];
        
        for (id<OperationObserver> observer in self.observers) {
            [observer operationDidFinishe:self errors:_internalErrors];
        }
        
        self.state = OperationStateFinished;
    }
}

- (void)finished:(NSArray *)error {
    
}

- (void)waitUntilFinished {
    
}

@end
