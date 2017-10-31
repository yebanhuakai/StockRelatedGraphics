//
//  RankHistogramView.m
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/7/12.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import "RankHistogramView.h"
#import "UIViewExt.h"
#import "SHY_HttpRequest.h"
#import "NSString+Encoding.h"

@implementation RankHistogramView {
    CGFloat _originX;
    CGFloat _originY;
    CGFloat _spaceY;
    CGFloat _originTailSpace;
    CGFloat _bottomLineY; // 最底下的那根线的Y

    NSMutableArray<CAShapeLayer *> *_layers;

    NSString *_stockCode;
    BOOL _isDataBind;
    BOOL _isGeGu;

    __weak IBOutlet UILabel *titleRightLabel;
    __weak IBOutlet UILabel *titleLabel;

    __weak IBOutlet UILabel *paiHangTitleLabel;
    __weak IBOutlet UILabel *guJiaTitleLabel;

    __weak IBOutlet UILabel *paiHangLabel;
    __weak IBOutlet UILabel *guJiaLabel;

    CGFloat _stockPrice;
    NSUInteger _redIndex; //红色柱索引

    //图形相关
    NSUInteger _maxNum; //最大个股数量，需要遍历“groupList”确定,左轴纵坐标最大值计算值
    NSUInteger _zuNum;
    CGFloat _currentPrice;
    CGFloat _betweenSpace;
    CGFloat _numSpace;

    NSMutableArray<NSString *> *_priceArray;
    NSMutableArray<NSString *> *_leftNumArray;
    NSMutableArray<NSNumber *> *_stockNumArray;
    NSMutableArray<NSValue *> *_histogramPointsArray;
    NSMutableArray<NSValue *> *_whiteBlockPointsArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];

    _originX = 35.f;
    _originY = 105.f;
    _spaceY = 40.f;
    _originTailSpace = 15.f;
    _bottomLineY = _originY + _spaceY * 4;

    _maxNum = 0;
    _zuNum = 0;
    _currentPrice = .0f;

    _layers = [[NSMutableArray alloc] initWithCapacity:0];
    _priceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _leftNumArray = [[NSMutableArray alloc] initWithCapacity:0];
    _stockNumArray = [[NSMutableArray alloc] initWithCapacity:0];
    _histogramPointsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _whiteBlockPointsArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)layoutSubviews {
    self.width = 414;
    self.height = 310;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code

    CABasicAnimation *animation;
    animation = [CABasicAnimation animation];

    [animation setDuration:.25f];

    [[self layer] addAnimation:animation forKey:@"contents"];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, .5f);

    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);

    //个股数量标签
    [@"个股数量" drawInRect:CGRectMake(8, _originY - 20, 60, 30)
                 withAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:12] }];

    // 1.横纵线
    [[UIColor grayColor] set];
    //纵坐标线
    CGContextMoveToPoint(context, _originX, _originY);
    CGContextAddLineToPoint(context, _originX, _bottomLineY + 15);
    CGContextStrokePath(context);
    //横坐标线
    CGContextMoveToPoint(context, _originX - 15, _bottomLineY);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) - _originTailSpace, _bottomLineY);
    CGContextStrokePath(context);
    //横向3根线
    for (NSInteger i = 0; i < 3; i++) {
        CGContextMoveToPoint(context, _originX, _originY + _spaceY * (i + 1));
        CGContextAddLineToPoint(context, CGRectGetWidth(rect) - _originTailSpace, _originY + _spaceY * (i + 1));
        CGContextStrokePath(context);
    }
    //右下角单位
    [(_isGeGu ? @"(元)" : @"(亿)") drawInRect:CGRectMake(CGRectGetWidth(rect) - _originTailSpace, _originY + _spaceY * 4 - 10, _originTailSpace, 10)
                               withAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:8] }];
    //⚠️无数据返回
    if (_leftNumArray.count == 0) {
        return;
    }

    // 2.纵向5个数量坐标
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;

    NSDictionary *attrs = @{
        NSForegroundColorAttributeName: [UIColor blackColor],
        NSFontAttributeName: [UIFont systemFontOfSize:12],
        NSParagraphStyleAttributeName: paragraphStyle
    }; //在词典中加入文本的颜色 字体 大小

    for (NSUInteger i = 0; i < 5; i++) {
        [_leftNumArray[i] drawInRect:CGRectMake(0, _originY + (_spaceY - 3.5) * i, _originX - 5, 14) withAttributes:attrs];
    }

    // 3.绘制底部z个标签，注意左右间隙各为10，倾斜45°
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attrs = @{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragraphStyle };

    for (NSUInteger i = 0; i < _priceArray.count; i++) {

        CGContextSaveGState(context);

        CGFloat xAdd = _originX + _numSpace * i;
        CGFloat xSub = -xAdd;
        CGFloat yAdd = _bottomLineY + (CGRectGetHeight(rect) - _bottomLineY) / 2.f;
        CGFloat ySub = -yAdd;

        CGContextTranslateCTM(context, xAdd, yAdd);
        CGContextRotateCTM(context, -M_PI / 4);
        CGContextTranslateCTM(context, xSub, ySub);

        [_priceArray[i] drawInRect:CGRectMake(_originX - 20 + _numSpace * i, _bottomLineY + (CGRectGetHeight(rect) - _bottomLineY) / 2.f - 6, 40, 12)
                    withAttributes:attrs];

        CGContextRestoreGState(context);
    }

    // 4.绘制柱状图，宽度固定12
    paragraphStyle.alignment = NSTextAlignmentCenter;

    [[UIColor blueColor] set];
    CGContextSetLineWidth(context, 2.f);

    for (NSInteger i = 0; i < _stockNumArray.count; i++) {
        CGFloat height = [_stockNumArray[i] floatValue] / _maxNum * 150.f;

        if (_redIndex == i) {
            CGContextSaveGState(context);
            [[UIColor redColor] set];
            CGContextFillRect(context, CGRectMake(_originX + _betweenSpace + _numSpace * i, _bottomLineY, 12, -height));

            CGContextRestoreGState(context);
        } else {
            CGContextSaveGState(context);
            [[UIColor blueColor] set];
            CGContextStrokeRect(context, CGRectMake(_originX + _betweenSpace + _numSpace * i, _bottomLineY - height - 1.5f, 12, height));
            CGContextRestoreGState(context);

            if (height > 1) {
                CGContextSaveGState(context);
                //白色方块，挡住底部
                CGContextSetLineWidth(context, 1.f);
                [[UIColor whiteColor] set];
                CGContextFillRect(context, CGRectMake(_originX + _betweenSpace + _numSpace * i + 1, _bottomLineY - 2.5, 10, 2));
                CGContextRestoreGState(context);
            }
        }

        //标签
        attrs = @{
            NSForegroundColorAttributeName: (_redIndex == i) ? [UIColor redColor] : [UIColor blueColor],
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        NSString *letter = [_stockNumArray[i] stringValue];
        CGSize letterSize = [letter sizeWithFont:[UIFont systemFontOfSize:12]];
        [letter drawInRect:CGRectMake(_originX + _betweenSpace + _numSpace * i + 6 - letterSize.width / 2.f, _bottomLineY - height - letterSize.height - 3,
                                      letterSize.width, letterSize.height)
            withAttributes:attrs];
    }
}

- (void)clearLayers {
    //清除重复的线
    for (CAShapeLayer *layer in _layers) {
        [layer removeFromSuperlayer];
    }
    [_layers removeAllObjects];
}

#pragma mark - request
- (void)requestDataWithStockCode:(NSString *)stockCode isGeGu:(BOOL)isGeGu {
    _stockCode = stockCode;
    
    [self setNeedsDisplay];
    if (stockCode == nil) {
        return;
    }

    _isGeGu = isGeGu;
    titleRightLabel.text = isGeGu ? @"行业股价排名" : @"行业流通市值排名";
    paiHangTitleLabel.text = isGeGu ? @"个股股价行业排名" : @"流通市值行业排名";
    guJiaTitleLabel.text = isGeGu ? @"股价" : @"流通市值";

    isGeGu ? [self requestRankingGeGu] : [self requestRankingHangYe];
}

- (void)requestRankingGeGu {
   
    NSString *url = [NSString stringWithFormat:@"https://hqdata.jrj.com.cn/ranking/share/%@_k_p.js", _stockCode];
    [SHY_HttpRequest requestGetWithUrl:url parameters:nil success:^(id responseObject) {
        [self bindRankingGeGuDataWithDic:responseObject];
    } failure:^(NSError *error) {
        //
    }];
    
}

- (void)bindRankingGeGuDataWithDic:(NSDictionary *)dic {

    [_priceArray removeAllObjects];
    [_stockNumArray removeAllObjects];

    titleLabel.text = [NSString unicodeToUtf8:dic[@"boardName"]];
    paiHangLabel.text = [NSString stringWithFormat:@"%ld/%ld", [dic[@"pos"] integerValue], [dic[@"total"] integerValue]];
    guJiaLabel.text =
    _isGeGu ? [NSString stringWithFormat:@"%.2f元", [dic[@"price"] floatValue]] : [NSString stringWithFormat:@"%.2f亿", [dic[@"price"] floatValue] / 10000.f];

    // 1.基准值赋值
    _zuNum = [dic[@"groupSize"] unsignedIntegerValue];
    _currentPrice = [dic[@"price"] floatValue];

    NSArray *groupList = dic[@"groupsList"];

    __block NSUInteger maxNumber = 0;
    CGFloat currentPirce = [dic[@"price"] floatValue];
    //    CGFloat groupGap = [dic[@"gap"] floatValue];
    __block CGFloat lastMaxPrice = 0;

    [groupList enumerateObjectsUsingBlock:^(NSDictionary *subDic, NSUInteger idx, BOOL *_Nonnull stop) {
        NSUInteger number = [subDic[@"number"] unsignedIntegerValue];
        CGFloat maxPrice = [subDic[@"maxprice"] floatValue];
        CGFloat minPrice = [subDic[@"minprice"] floatValue];

        //确定红柱图索引(组间距无效了）
        if (lastMaxPrice < currentPirce && currentPirce <= maxPrice) {
            _redIndex = idx;
        }
        
        //存储本次最大值方便下次计算
        if (maxPrice > lastMaxPrice) {
            lastMaxPrice = maxPrice;
        }

        if (number > maxNumber) {
            maxNumber = number;
        }

        //第一个数据添加最小值
        if (idx == 0) {
            if (minPrice < maxPrice) {
                [_priceArray addObject:(_isGeGu ? [NSString stringWithFormat:@"%.2f", minPrice] : [NSString stringWithFormat:@"%.0f", minPrice / 10000.f])];
            } else {
                [_priceArray addObject:@""];
            }
        }

        [_priceArray addObject:(_isGeGu ? [NSString stringWithFormat:@"%.2f", maxPrice] : [NSString stringWithFormat:@"%.0f", maxPrice / 10000.f])];
        [_stockNumArray addObject:@(number)];
        
    }];

    // 2.确定左侧最大数量并分段，4均分，为了保证最大值上面的数量不超界限，最大值放大1.2倍。同时数量不能出现小数
    for (NSUInteger i = (NSUInteger)(maxNumber * 1.1f); i < NSUIntegerMax; i++) {
        if (i % 4 == 0) {
            _maxNum = i;
            break;
        }
    }

    _leftNumArray = [@[
        [NSString stringWithFormat:@"%lu", (unsigned long)_maxNum],
        [NSString stringWithFormat:@"%lu", (unsigned long)(_maxNum * .75f)],
        [NSString stringWithFormat:@"%lu", (unsigned long)(_maxNum * .5f)],
        [NSString stringWithFormat:@"%lu", (unsigned long)(_maxNum * .25f)],
        @"0"
    ] mutableCopy];

    // 3.计算坐标

    //柱状图之间空隙间距
    _betweenSpace = (self.width - _originX - _originTailSpace - 12 * _zuNum) / (_zuNum + 1);
    //柱状图等分间距
    _numSpace = (self.width - _originX - _originTailSpace - _betweenSpace) / _zuNum;

    [self setNeedsDisplay];
}

- (void)requestRankingHangYe {
    NSString *url = [NSString stringWithFormat:@"https://hqdata.jrj.com.cn/ranking/share/%@_k_c.js", _stockCode];
    [SHY_HttpRequest requestGetWithUrl:url parameters:nil success:^(id responseObject) {
        [self bindRankingGeGuDataWithDic:responseObject];
    } failure:^(NSError *error) {
        //
    }];
}

- (void)setCurrentPrice:(NSString *)currentPrice {
    guJiaLabel.text = [NSString stringWithFormat:@"%@元", currentPrice];
}

@end
