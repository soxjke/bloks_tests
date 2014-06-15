//
//  NSBlockSignatureParser.h
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


#import <Foundation/Foundation.h>

@class NSBlockSignatureParser;

@protocol NSBlockSignatureParserDelegate <NSObject>

- (void)parser:(NSBlockSignatureParser*)parser didParseReturnType:(NSString*)returnType;
- (void)parser:(NSBlockSignatureParser*)parser didParseArgument:(NSString*)argument;
- (void)parserDidFinish:(NSBlockSignatureParser*)parser;
- (void)parser:(NSBlockSignatureParser*)parser didFailWithError:(NSError*)error;

@end

@interface NSBlockSignatureParser : NSObject

+ (instancetype)parserWithSignatureString:(NSString*)signature;
- (instancetype)initWithSignatureString:(NSString*)signature;

- (void)parse;

@property (nonatomic, weak) id <NSBlockSignatureParserDelegate> delegate;

@end
