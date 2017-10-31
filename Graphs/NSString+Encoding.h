//
//  NSString+Encoding.h
//  JRJNews
//
//  Created by Mr.Yang on 14-4-28.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)

// unicode->utf8
+ (NSString *)unicodeToUtf8:(NSString *)string;
// utf8->unicode
+ (NSString *)utf8ToUnicode:(NSString *)string;
// utf8->unicode
+ (NSString *)encodedUnicode:(NSString *)string;

//字符串转16进制编码
+ (NSString *)hexStringFromString:(NSString *)string;
//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString2:(NSString *)string;
//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString1:(NSString *)string;
//对特殊字符也可编码，默认UTF-8
- (NSString *)urlEncode;

@end
