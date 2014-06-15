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
#import "NSBlockSignatureParser.h"
#import <objc/runtime.h>

@interface NSObject (BlocksIngo) <NSBlockSignatureParserDelegate>

@property (nonatomic, strong) NSString *returnType;
@property (nonatomic, strong) NSMutableArray *argumentTypes;
@property (nonatomic, strong) NSError *parseError;

@end

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
    NSInteger numberOfArguments;
    [self prototypeReturningNumberOfArguments:&numberOfArguments];
    return numberOfArguments;
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
    if (block->flags & copyDisposeFlag)
    {
        index += 2;
    }
    
    return [NSString stringWithCString:block->descriptor->rest[index] encoding:NSUTF8StringEncoding];
}

- (NSString*)prototype
{
    return [self prototypeReturningNumberOfArguments:NULL];
}

- (NSString*)prototypeReturningNumberOfArguments:(NSInteger*)pNumberOfArguments
{
    if ([self isBlock])
    {
        self.returnType     = nil;
        self.argumentTypes  = [NSMutableArray new];
        
        NSBlockSignatureParser *parser = [NSBlockSignatureParser parserWithSignatureString:[self signature]];
        
        parser.delegate = self;
        [parser parse];
        if (!self.parseError)
        {
            NSMutableString *prototype = [NSMutableString stringWithFormat:@"(%@)(^block)(", self.returnType];
            NSInteger argCount = (NSInteger)[self.argumentTypes count];
            [self.argumentTypes enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop)
            {
                [prototype appendFormat:@"%@ arg%d%@",type, idx, (idx == argCount - 1) ? @"" : @","];
            }];
            [prototype appendString:@")"];
            
            if (pNumberOfArguments) *pNumberOfArguments = argCount;
            return prototype;
        }
    }
    
    if (pNumberOfArguments) *pNumberOfArguments = NSNotFound;
    return nil;
}

#pragma mark - NSBlockSignatureParser delegate

- (void)parser:(NSBlockSignatureParser *)parser didParseReturnType:(NSString *)returnType
{
    self.returnType = returnType;
}

- (void)parser:(NSBlockSignatureParser *)parser didParseArgument:(NSString *)argument
{
    [self.argumentTypes addObject:argument];
}

- (void)parserDidFinish:(NSBlockSignatureParser *)parser
{
    self.parseError = nil;
}

- (void)parser:(NSBlockSignatureParser *)parser didFailWithError:(NSError *)error
{
    self.parseError = error;
}

#pragma mark setter/getter

- (void)setReturnType:(NSString *)returnType
{
    objc_setAssociatedObject(self, @selector(returnType), returnType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)returnType
{
    return objc_getAssociatedObject(self, @selector(returnType));
}

- (void)setArgumentTypes:(NSMutableArray *)argumentTypes
{
    objc_setAssociatedObject(self, @selector(argumentTypes), argumentTypes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray*)argumentTypes
{
    return objc_getAssociatedObject(self, @selector(argumentTypes));
}

- (void)setParseError:(NSError *)parseError
{
    objc_setAssociatedObject(self, @selector(parseError), parseError, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSError*)parseError
{
    return objc_getAssociatedObject(self, @selector(parseError));
}

@end
