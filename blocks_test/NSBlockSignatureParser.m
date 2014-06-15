//
//  NSBlockSignatureParser.m
//  blocks_test
//
//  Created by Petro Korienev on 6/15/14.
//  Copyright (c) 2014 ids. All rights reserved.
//
//  Inspired by http://stackoverflow.com/questions/9048305/checking-objective-c-block-type
//  Some code grabbed from https://github.com/mikeash/MABlockClosure
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#define SEND_SAFE_MESSAGE(aTarget, aSelector, ...) [self sendSafeMessageToTarget:aTarget selector:aSelector, __VA_ARGS__]

#import "NSBlockSignatureParser.h"

@interface NSBlockSignatureParser ()

@property (nonatomic, strong) NSString *signature;

@end

@implementation NSBlockSignatureParser

+ (instancetype)parserWithSignatureString:(NSString *)signature
{
    return [[self alloc] initWithSignatureString:signature];
}

- (instancetype)initWithSignatureString:(NSString *)signature
{
    self = [super init];
    if (self)
    {
        self.signature = signature;
    }
    return self;
}

- (void)parse
{
    SEND_SAFE_MESSAGE(self.delegate, @selector(parserDidFinish:), self);
}

- (void)sendSafeMessageToTarget:(id)target selector:(SEL)selector, ...
{
    if ([target respondsToSelector:selector])
    {
        NSInvocation *invocation = [NSInvocation new];
        
        [invocation setArgument:(__bridge void *)(target)   atIndex:0];
        [invocation setArgument:selector                    atIndex:1];
        
        va_list args;
        va_start(args, selector);
        
        void *arg = selector;
        int i = 1;
        
        while ((arg = va_arg(args, void *)))
        {
            [invocation setArgument:arg atIndex:++i];
        }
        va_end(args);
        
        [invocation invoke];
    }
}

@end
