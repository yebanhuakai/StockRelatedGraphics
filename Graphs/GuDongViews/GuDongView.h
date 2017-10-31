//
//  GuDongView.h
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/7/18.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  股东人数
 */
@interface GuDongView : UIView

- (void)clearLayers;

- (void)requestDataWithStockCode:(NSString *)stockCode;

@end
