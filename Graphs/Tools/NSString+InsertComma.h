//
//  NSString+InsertComma.h
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/9/21.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 插入逗号
 */
@interface NSString (InsertComma)

+ (NSString *)insertComma:(NSString *)num;

- (NSString *)insertComma;

@end
