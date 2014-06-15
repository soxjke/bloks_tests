//
//  AppDelegate+NoARC.m
//  blocks_test
//
//  Created by Petro Korienev on 6/15/14.
//  Copyright (c) 2014 Petro Korienev. All rights reserved.
//

#if __has_feature(objc_arc)
#error This code should be compiled without ARC
#endif

#import "AppDelegate+NoARC.h"

@implementation AppDelegate (NoARC)

//
//   However in nonARC environment nothing are retained automatically
//
- (void)blocksTest10;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSString *string = [NSString stringWithFormat:@"Some String"];
    
    NSLog(@"string = %@", string);
    NSLog(@"string retain count = %d", (int)[string retainCount]);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"string = %@", string);
        NSLog(@"string retain count = %d", (int)[string retainCount]);
        NSLog(@"finished block1");
    };
    
    block1();
    
    NSLog(@"string = %@", string);
    NSLog(@"string retain count = %d", (int)[string retainCount]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//   However in nonARC environment by copying, passed objects are retained
//
- (void)blocksTest11;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSString *string = [NSString stringWithFormat:@"Some String"];
    
    NSLog(@"string = %@", string);
    NSLog(@"string retain count = %d", (int)[string retainCount]);
    
    void (^block1)() = [^()
    {
        NSLog(@"called block1");
        NSLog(@"string = %@", string);
        NSLog(@"string retain count = %d", (int)[string retainCount]);
        NSLog(@"finished block1");
    } copy];
    
    block1();
    [block1 release];
    
    NSLog(@"string = %@", string);
    NSLog(@"string retain count = %d", (int)[string retainCount]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//    Using self inside block. In nonARC environment this is OK, because nothing is retained.
//
- (void)blocksTest12;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self retainCount]);
    
    void (^block1)() = ^()
    {
        NSLog(@"called block1");
        NSLog(@"self = %@", self);
        NSLog(@"self retain count = %d", (int)[self retainCount]);
        NSLog(@"finished block1");
    };
    
    block1();
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self retainCount]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

//
//    However, by copying block self is retained, so this may lead to retain cycle
//
- (void)blocksTest13;
{
    NSLog(@"______________\nStarted  %s", __PRETTY_FUNCTION__);
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self retainCount]);
    
    void (^block1)() = [^()
    {
        NSLog(@"called block1");
        NSLog(@"self = %@", self);
        NSLog(@"self retain count = %d", (int)[self retainCount]);
        NSLog(@"finished block1");
    } copy];
    
    block1();
    [block1 release];
    
    NSLog(@"self = %@", self);
    NSLog(@"self retain count = %d", (int)[self retainCount]);
    
    NSLog(@"Finished %s\n______________", __PRETTY_FUNCTION__);
}

@end
