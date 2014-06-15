//
//  NSObject+BlocksInfo.m
//  blocks_test
//
//  Created by Petro Korienev on 6/15/14.
//  Copyright (c) 2014 Petro Korienev. All rights reserved.
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

#import "NSObject+BlocksInfo.h"

@implementation NSObject (BlocksInfo)

typedef struct
{
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
} BlockDescriptor, *pBlockDescriptor;

typedef struct
{
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    pBlockDescriptor descriptor;
} Block, *pBlock;

- (BOOL)isBlock
{
    return [self isKindOfClass:NSClassFromString(@"NSBlock")];
}

- (NSInteger)numberOfArguments;
{
    if (![self isBlock])
    {
        return NSNotFound;
    }
    NSString *signature = [self signature];
    NSArray *signatureComponents = [signature componentsSeparatedByString:@"@?"];
    NSString *returnTypeEncode = [signatureComponents firstObject];
    NSString *parametersEncode = [signatureComponents lastObject];
    return [[returnTypeEncode substringFromIndex:1] integerValue] / sizeof(NSInteger) - 1;
}

- (IMP)implementation
{
    if (![self isBlock])
    {
        return NULL;
    }
    return ((__bridge pBlock)self)->invoke;
}

- (NSString*)signature
{
    if (![self isBlock])
    {
        return nil;
    }
    pBlock block = (__bridge pBlock)self;
    
    int copyDisposeFlag = 1 << 25;
    int signatureFlag = 1 << 30;
    
    assert(block->flags & signatureFlag);
    
    int index = 0;
    if(block->flags & copyDisposeFlag)
        index += 2;
    
    return [NSString stringWithCString:block->descriptor->rest[index] encoding:NSUTF8StringEncoding];
}

- (NSString*)prototype
{
    if (![self isBlock])
    {
        return nil;
    }
    return @"";
}


@end
