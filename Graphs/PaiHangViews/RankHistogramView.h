//
//  RankHistogramView.h
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/7/12.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *   个股股价排行柱状图
 */
@interface RankHistogramView : UIView

/**
 *  请求个股或行业排行数据
 *
 *  @param stockCode 股票代码
 *  @param isGeGu    YES：个股，NO：行业
 */
- (void)requestDataWithStockCode:(NSString *)stockCode isGeGu:(BOOL)isGeGu;

- (void)clearLayers;

- (void)setCurrentPrice:(NSString *)currentPrice;

@end
