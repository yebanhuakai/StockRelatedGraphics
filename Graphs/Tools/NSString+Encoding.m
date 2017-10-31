//
//  NSString+Encoding.m
//  JRJNews
//
//  Created by Mr.Yang on 14-4-28.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import "NSString+Encoding.h"

;

static char toHex(int nibble) {

    static char hexDigit[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

    NSInteger i = nibble & 0xF;
    return hexDigit[i];
}

@implementation NSString (Encoding)

+ (NSString *)unicodeToUtf8:(NSString *)string {
    if (string == nil) {
        return nil;
    }
    return [NSString stringWithCString:[string cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
}

+ (NSString *)utf8ToUnicode:(NSString *)string {
    NSUInteger length = [string length];
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < length; i++) {
        unichar _char = [string characterAtIndex:i];
        //判断是否为英文和数字
        if (_char <= '9' && _char >= '0') {
            [s appendFormat:@"%@", [string substringWithRange:NSMakeRange(i, 1)]];
        } else if (_char >= 'a' && _char <= 'z') {
            [s appendFormat:@"%@", [string substringWithRange:NSMakeRange(i, 1)]];
        } else if (_char >= 'A' && _char <= 'Z') {
            [s appendFormat:@"%@", [string substringWithRange:NSMakeRange(i, 1)]];
        } else {

            [s appendFormat:@"\\u"];
            [s appendFormat:@"%c", toHex((_char >> 12) & 0xF)];
            [s appendFormat:@"%c", toHex((_char >> 8) & 0xF)];
            [s appendFormat:@"%c", toHex((_char >> 4) & 0xF)];
            [s appendFormat:@"%c", toHex(_char & 0xF)];
        }
    }

    return s;
}

+ (NSString *)encodedUnicode:(NSString *)string {
    BOOL escapeSpace = false;
    NSMutableString *mutStr = [NSMutableString string];
    for (int x = 0; x < string.length; x++) {
        const char *charStr = [string UTF8String];
        char aChar = charStr[x];

        // Handle common case first, selecting largest block that
        // avoids the specials below
        if ((aChar > 61) && (aChar < 127)) {
            if (aChar == '\\') {
                [mutStr appendString:@"\\"];
                [mutStr appendString:@"\\"];
                continue;
            }
            [mutStr appendFormat:@"%c", aChar];
            continue;
        }

        switch (aChar) {
            case ' ':
                if (x == 0 || escapeSpace)
                    [mutStr appendFormat:@"\\"];

                [mutStr appendFormat:@" "];
                break;
            case '\t':
                [mutStr appendFormat:@"\\"];
                [mutStr appendFormat:@"t"];
                break;
            case '\n':
                [mutStr appendFormat:@"\\n"];
                break;
            case '\r':
                [mutStr appendFormat:@"\\r"];
                break;
            case '\f':
                [mutStr appendFormat:@"\\f"];
                break;
            case '=': // Fall through
            case ':': // Fall through
            case '#': // Fall through
            case '!':
                [mutStr appendFormat:@"\\"];
                [mutStr appendFormat:@"%c", aChar];
                break;
            default:
                if ((aChar < 0x0020) || (aChar > 0x007e)) {
                    // 每个unicode有16位，每四位对应的16进制从高位保存到低位
                    [mutStr appendFormat:@"\\u"];
                    [mutStr appendFormat:@"%c", toHex((aChar >> 12) & 0xF)];
                    [mutStr appendFormat:@"%c", toHex((aChar >> 8) & 0xF)];
                    [mutStr appendFormat:@"%c", toHex((aChar >> 4) & 0xF)];
                    [mutStr appendFormat:@"%c", toHex(aChar & 0xF)];

                } else {
                    [mutStr appendFormat:@"%c", aChar];
                }
        }
    }

    return mutStr;
}

//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //    const char *str = [string UTF8String];
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for (int i = 0; i < [myD length]; i++) {

        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff]; /// 16进制数
        if ([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr, newHexStr];
    }

    return hexStr;
}

//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString2:(NSString *)string {
    const char *str = [string UTF8String];
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for (int i = 0; i < strlen(str); i++) {

        NSString *newHexStr = [NSString stringWithFormat:@"%x", str[i] & 0xff]; /// 16进制数
        if ([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr, newHexStr];
    }

    return hexStr;
}

//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString1:(NSString *)string {
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    NSLog(@"%s", bytes);
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for (int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff]; /// 16进制数

        if (bytes[i] >= 0 && bytes[i] < 16) {
            hexStr = [hexStr stringByAppendingString:@"0"];
        } else {
            hexStr = [hexStr stringByAppendingString:newHexStr];
        }
    }

    return hexStr;
}

- (NSString *)urlEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') || (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02x", thisChar];
        }
    }
    return output;
}

@end
