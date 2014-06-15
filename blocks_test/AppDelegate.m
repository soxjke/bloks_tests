//
//  AppDelegate.m
//  blocks_test
//
//  Created by Petro Korienev on 6/15/14.
//  Copyright (c) 2014 Petro Korienev. All rights reserved.
//

#import "AppDelegate.h"
#import "NSObject+BlocksInfo.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *methodNameBase = @"blocksTest";
    for (int i = 1, stop = 0; !stop; i++)
    {
        NSString *methodName = [methodNameBase stringByAppendingString:[@(i) stringValue]];
        SEL selector = NSSelectorFromString(methodName);
        if ([self respondsToSelector:selector])
        {
            [self performSelector:selector];
        }
        else
        {
            stop = 1;
        }
    }
    NSLog(@"finished tests");
    return YES;
}

#pragma mark - tests

//
// Simple blocks syntax
// Blocks are normally copying context by value
// Context variables without __block specifier are constant (see warning)
//
- (void)blocksTest1;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);

    int a = 1;
    int b = 2;

    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        int *pB = &b;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block1");
    };
    
    block1();

    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
// Calling same block twice
// See a and b inside of block are incremented twice
//
- (void)blocksTest2;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        int *pB = &b;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block1");
    };
    
    block1();
    block1();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//  Copying block doesn't duplicate the context
//  However objects are retained (see further examples)
//
- (void)blocksTest3;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        int *pB = &b;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block1");
    };
    
    block1();
    ((void(^)())[block1 copy])();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   Creating two different blocks
//   Each has own context
//
- (void)blocksTest4;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        int *pB = &b;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block1");
    };
    
    void (^block2)() = ^()
    {
        NSLog(@"called block2");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        int *pB = &b;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block2");
    };
    
    block1();
    block2();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   __block specifier affects how reference to context variables is passed to block
//   __block specifier allows to modify context variables and changes made inside block
//   are reflected into owners context
//
- (void)blocksTest5;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    __block int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, &b);
        (*pA)++;
        b++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block1");
    };
    
    block1();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   Calling of two blocks
//
- (void)blocksTest6;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    __block int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, &b);
        (*pA)++;
        b++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block1");
    };
    
    void (^block2)() = ^()
    {
        NSLog(@"called block2");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, &b);
        (*pA)++;
        b++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished block2");
    };
    
    block1();
    block2();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   Block inside block
//   Context variables are copied with nesting
//
- (void)blocksTest7;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    __block int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called outer block");
        NSLog(@"a = %d; b = %d", a, b);
        int *pA = &a;
        int *pB = &b;

        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        
        void (^block2)() = ^()
        {
            NSLog(@"called inner block");
            NSLog(@"a = %d; b = %d", a, b);
            NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
            (*pA)++;
            (*pB)++;
            NSLog(@"a = %d; b = %d", a, b);
            NSLog(@"finished inner block");
        };
        
        block2();
        
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished outer block");
    };
    
    block1();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   Block inside block
//   Context variables are copied with nesting
//
- (void)blocksTest8;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    int a = 1;
    __block int b = 2;
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    void (^block1)() = ^()
    {
        NSLog(@"called outer block");
        NSLog(@"a = %d; b = %d", a, b);
        __block int *pA = &a;
        int *pB = &b;
        
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        
        void (^block2)() = ^()
        {
            NSLog(@"called inner block");
            NSLog(@"a = %d; b = %d", a, b);
            NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
            (*pA)++;
            (*pB)++;
            NSLog(@"a = %d; b = %d", a, b);
            pA = &a;
            (*pA)++;
            NSLog(@"a = %d; b = %d", a, b);
            NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
            NSLog(@"finished inner block");
        };
        
        block2();
        
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"pointer to a = %p, pointer to b = %p", pA, pB);
        
        (*pA)++;
        (*pB)++;
        NSLog(@"a = %d; b = %d", a, b);
        NSLog(@"finished outer block");
    };
    
    block1();
    
    NSLog(@"a = %d; b = %d", a, b);
    NSLog(@"pointer to a = %p, pointer to b = %p", &a, &b);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//    Blocks retain objects
//
- (void)blocksTest9;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSString *string = [NSString stringWithFormat:@"Some String"];
    
    NSLog(@"string = %@", string);
    NSLog(@"string retain count = %d", (int)[string performSelector:NSSelectorFromString(@"retainCount")]);
    
    @autoreleasepool
    {
        void (^block1)() = ^()
        {
            NSLog(@"called block1");
            NSLog(@"string = %@", string);
            NSLog(@"string retain count = %d", (int)[string performSelector:NSSelectorFromString(@"retainCount")]);
            NSLog(@"finished block1");
        };
    
        block1();
    }
    
    NSLog(@"string = %@", string);
    NSLog(@"string retain count = %d", (int)[string performSelector:NSSelectorFromString(@"retainCount")]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//    In ARC environment, self is captured strongly by the block. So this may lead to retain cycle.
//    Consider the following example:
//    1) UIViewController holds strong reference to it's view
//    2) The view has custom subview with block property which holds block, which is called when subview state is changed
//    3) UIViewController sets this block in viewDidLoad, with self captured strongly by block
//    Retain cycle - block holds view controller, view controller holds view, view holds subview, subview holds block.
//
- (void)blocksTest14;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
    
    dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
    
    @autoreleasepool
    {
        void (^block1)() = ^()
        {
            NSLog(@"called block1");
            NSLog(@"self = %@", self);
            NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
            NSLog(@"finished block1");
            dispatch_semaphore_signal(dsema);
        };
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), block1);
        
        NSLog(@"self = %@", self);
        NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
        dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
    }

    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//    In ARC all time-continous references which are captured by block should be weakified to avoid retain cycle
//
- (void)blocksTest15;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
    
    @autoreleasepool
    {
        void (^block1)() = ^()
        {
            NSLog(@"called block1");
            NSLog(@"self = %@", weakSelf);
            NSLog(@"self retain count = %d", (int)[weakSelf performSelector:NSSelectorFromString(@"retainCount")]);
            NSLog(@"finished block1");
            dispatch_semaphore_signal(dsema);
        };
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), block1);
    }
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
        
    dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self performSelector:NSSelectorFromString(@"retainCount")]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//  More complex block syntax - block with parameters
//  typedef and inline block snippets
//  Block-based factorial calculation
//

typedef void (^BlockWithFloatResult)(CGFloat result);

- (void)blocksTest16
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    void (^block)(CGFloat result) = ^(CGFloat result)
    {
        NSLog(@"result = %f", result);
    };
    
    [self calculateFactorialForNumber:25 withCompletion:block];
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   Internal structure of block
//   Runtime information about block
//   NSGlobalBlock
//
- (void)blocksTest17
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    NSString *string = [NSString stringWithFormat:@"Some string"];
    void (^block)(CGFloat result) = ^(CGFloat result)
    {
        NSLog(@"result = %f", result);
    };

    void (^block2)(CGFloat result, NSUInteger intResult) = ^(CGFloat result, NSUInteger intResult)
    {
        NSLog(@"result = %f, intResult = %d", result, intResult);
    };

    void (^block3)(CGFloat result, NSUInteger intResult, NSNumber *boolNumber) = ^(CGFloat result, NSUInteger intResult, NSNumber *boolNumber)
    {
        NSLog(@"result = %f, intResult = %d, boolResult = %d", result, intResult, [boolNumber boolValue]);
    };
    
    CGFloat (^block4)(CGFloat result, NSUInteger intResult, NSNumber *boolNumber) = ^(CGFloat result, NSUInteger intResult, NSNumber *boolNumber)
    {
        NSLog(@"result = %f, intResult = %d, boolResult = %d", result, intResult, [boolNumber boolValue]);
        return result;
    };
    
    [self testBlock:string];
    [self testBlock:block];
    [self testBlock:block2];
    [self testBlock:block3];
    [self testBlock:block4];
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   NSMallocBlock and NSStackBlock
//
- (void)blocksTest18
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    NSString *string = [NSString stringWithFormat:@"Some string"];
    NSComparisonResult (^block)(id obj1, id obj2) = ^(id obj1, id obj2)
    {
        NSLog(@"%@", string);
        return [obj1 compare:obj2];
    };
    
    NSArray* (^block2)(id obj1, id obj2) = ^(id obj1, id obj2)
    {
        NSLog(@"%@", string);
        block(obj1, obj2);
        return @[obj1, obj2];
    };
    
    CGRect (^block3)(NSArray *array, NSError *error, BOOL completed) = ^(NSArray *array, NSError *error, BOOL completed)
    {
        NSLog(@"%@", string);
        return CGRectMake(0, 0, array.count, [error code]);
    };
    
    void (^block4)(CGFloat result, void(^)(NSError* error)) = ^(CGFloat result, void(^blk)(NSError* error))
    {
        NSLog(@"%@", string);
        if (result < 0)
        {
            if (blk)
            {
                blk([NSError new]);
            }
        }
    };
    
    NSLog(@"%@", block);
    NSLog(@"%@", block2);
    NSLog(@"%@", block3);
    NSLog(@"%@", block4);
    
    [self testBlock:string];
    [self testBlock:block];
    [self testBlock:block2];
    [self testBlock:block3];
    [self testBlock:block4];
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

#pragma clang diagnostic pop

#pragma mark - helpers

- (void)calculateFactorialForNumber:(int)number withCompletion:(BlockWithFloatResult)completion
{
    if (!number) completion(1);
    else [self calculateFactorialForNumber:number-1 withCompletion:^(CGFloat result)
    {
        completion(result * number);
    }];
}

- (void)testBlock:(id)obj
{
    BOOL isBlock = [obj isBlock];
    NSLog(@"Object %@ is %@block", obj, isBlock ? @"" : @"not a ");
    if (isBlock)
    {
        NSLog(@"It's signature: %@", [obj signature]);
        NSLog(@"Pointer to implementation function: %p", [obj implementation]);
        NSLog(@"Number of arguments: %d", [obj numberOfArguments]);
    }
}
@end