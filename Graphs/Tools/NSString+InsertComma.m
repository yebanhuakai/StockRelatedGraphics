//
//  NSString+InsertComma.m
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/9/21.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import "NSString+InsertComma.h"

@implementation NSString (InsertComma)

+ (NSString *)insertComma:(NSString *)num
{
    int count = 0;
    long long int a = num.longLongValue;
    while (a != 0)
    {
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:num];
    NSMutableString *newstring = [NSMutableString string];
    while (count > 3) {
        count -= 3;
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        [newstring insertString:@"," atIndex:0];
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}

- (NSString *)insertComma
{
    int count = 0;
    long long int a = self.longLongValue;
    while (a != 0)
    {
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:self];
    
    //计算小数点位置
    NSRange dotRange = [string rangeOfString:@"."];
    //取从小数点开始的数据
    NSString *dotString;
    if (dotRange.location != NSNotFound) {
        dotString = [string substringFromIndex:dotRange.location];
        string = [[string substringToIndex:dotRange.location] mutableCopy];
    } else {
        dotString = @"";
    }
    NSMutableString *newstring = [NSMutableString stringWithString:dotString];
    
    while (count > 3) {
        count -= 3;
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        [newstring insertString:@"," atIndex:0];
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}

@end
