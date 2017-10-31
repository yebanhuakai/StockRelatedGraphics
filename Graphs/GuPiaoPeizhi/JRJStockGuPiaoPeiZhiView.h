//
//  JRJStockGuPiaoPeiZhiView.h
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/9/7.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  股票配置父视图
 */
@interface JRJStockGuPiaoPeiZhiView : UIView
@property (weak, nonatomic) IBOutlet UIButton *chiCangShouYiBtn;
@property (weak, nonatomic) IBOutlet UILabel *noPositionLabel;

- (void)requestZuHePeiZhiWithGroupID:(NSString *)groupID userID:(NSString *)userID;
- (void)startAnimation;
- (void)clearLayers;
@end
