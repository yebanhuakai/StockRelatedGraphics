//
//  JRJStockGuPiaoPeiZhiView.m
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/9/7.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import "GuPiaoPeiZhiDrawView.h"
#import "JRJStockGuPiaoPeiZhiView.h"

@interface JRJStockGuPiaoPeiZhiView ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (weak, nonatomic) IBOutlet GuPiaoPeiZhiDrawView *guPiaoPeiZhiDrawView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowBlockStartTopConst;

@end

@implementation JRJStockGuPiaoPeiZhiView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[[UINib nibWithNibName:@"JRJStockGuPiaoPeiZhiView" bundle:nil] instantiateWithOwner:self options:nil] objectAtIndex:0];
        containerView.frame = self.bounds;
        [self addSubview:containerView];
    }
    return self;
}

- (IBAction)shouYiBtnClick:(UIButton *)sender {
}

- (void)startAnimation {
    [_guPiaoPeiZhiDrawView startAnimation];
}

- (void)clearLayers {
    [_guPiaoPeiZhiDrawView clearLayers];
}

#pragma mark - request
- (void)requestZuHePeiZhiWithGroupID:(NSString *)groupID userID:(NSString *)userID
{
    NSArray *dataArray = @[
                           @{@"cnt": @9, @"indu_name": @"香奈儿"},
                           @{@"cnt": @7, @"indu_name": @"古驰"},
                           @{@"cnt": @3, @"indu_name": @"迪奥"},
                           @{@"cnt": @6, @"indu_name": @"路易威登"},
                           @{@"cnt": @5, @"indu_name": @"爱马仕"},
                           @{@"cnt": @3, @"indu_name": @"阿玛尼"}, ];
    [self bindDataWithArray:dataArray];
}

- (void)bindDataWithArray:(NSArray *)array
{
    
    if (array.count == 0) {
        return;
    }
    //cnt = 1,
    //indu_name = 医药生物,
    //indu_code = 370000
    
    //1.遍历数组并排序
  NSArray <NSDictionary *>*resultArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
       NSNumber *cnt1 = dic1[@"cnt"];
       NSNumber *cnt2 = dic2[@"cnt"];

       NSComparisonResult result = [cnt1 compare:cnt2];
       return result == NSOrderedAscending;
   }];
    
    //2.计算个数总量
    __block NSInteger maxCount = 0;
    __block NSInteger bef5Count = 0;
    [resultArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger count = [dic[@"cnt"] integerValue];
        maxCount += count;
        //赋值行业名称
        if (idx < 6) {
            UIImageView *imageV = _images[idx];
            imageV.hidden = NO;
            UILabel *label = _labels[idx];
            label.hidden = NO;
            if (idx < 5) {
                label.text = [NSString stringWithFormat:@"%@(%ld)", dic[@"indu_name"], (long)count];
                bef5Count += count;
            }
        }

    }];
    
    UILabel *label = _labels[5];
    label.text = [NSString stringWithFormat:@"其他(%ld)", maxCount - bef5Count];
    
    //3.每个行业所占百分比
    __block NSInteger maxPercentIndex = 0;
    __block CGFloat maxPercent = 0.0f;
    __block CGFloat addUPPercent = 0.0f;//前5累计百分比，用来计算“其他”行业的百分比所占，来确定那根线最粗
    __block NSMutableArray <NSString *>*angles = [[NSMutableArray alloc] initWithCapacity:0];
    
    [angles addObject:@"-90"];//第一个点为12点位置

    [resultArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < 5) {
            NSInteger count = [dic[@"cnt"] integerValue];
            CGFloat percent = (CGFloat)count / maxCount;
            addUPPercent += percent;
            [angles addObject:[NSString stringWithFormat:@"%.2f", -90 + addUPPercent * 360.f]];
            
            if (maxPercent < percent) {
                maxPercent = percent;
                maxPercentIndex = idx;
            }
        }
    }];
    [angles addObject:@"270"];
    
    CGFloat otherPercent = 1.f - addUPPercent;
    if (otherPercent > maxPercent) {
        maxPercentIndex = 5;
    }
    
    [_guPiaoPeiZhiDrawView bindDataWithAngles:angles maxIndex:maxPercentIndex];
    
    //调整右侧行业列表起始位置
//    CGFloat height =  25 + 19 * 6 + 10 * 5 + 21; // 210 总高度空间
    NSInteger count = resultArray.count > 6 ? 6 : resultArray.count;
     CGFloat contentHeight = count == 1 ? 19 : (19 + 10) * (count - 1) + 19;
    _yellowBlockStartTopConst.constant = (210 - contentHeight + 4) / 2.f;
}

@end
