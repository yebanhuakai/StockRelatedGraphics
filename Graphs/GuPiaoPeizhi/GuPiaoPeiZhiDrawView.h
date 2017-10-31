//
//  GuPiaoPeiZhiDrawView.h
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/9/8.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  股票配置绘图
 */
@interface GuPiaoPeiZhiDrawView : UIView

/**
 *  绘画方法
 *
 *  @param percents 角度（不用转为弧度），必须为@[@"-90", ..., @"270"]格式
 *  @param maxIndex 加粗线索引
 */
- (void)bindDataWithAngles:(NSArray<NSString *> *)angles maxIndex:(NSInteger)maxIndex;

- (void)startAnimation;
- (void)clearLayers;

@end
