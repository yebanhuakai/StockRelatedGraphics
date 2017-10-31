//
//  GuDongView.m
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/7/18.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import "GuDongView.h"
#import "NSString+InsertComma.h"
#import "UIViewExt.h"
#import "SHY_HttpRequest.h"

@implementation GuDongView {
    CGFloat _originX;
    CGFloat _originY;
    CGFloat _originTailSpace;

    NSMutableArray<CAShapeLayer *> *_layers;

    NSString *_stockCode;
    BOOL _isDataBind;
    __weak IBOutlet UILabel *leftTitleLabel;

    NSMutableArray<NSString *> *_dateArray;
    NSMutableArray<NSString *> *_holderArray;
    NSMutableArray<NSString *> *_avgNumArray;
    NSMutableArray<NSString *> *_priceArray;

    //图形相关
    NSMutableArray<NSString *> *_leftAxisArray; //左轴数据
    NSMutableArray<NSString *> *_rightAxisArray;
    NSMutableArray<NSValue *> *_redLinePoints;
    NSMutableArray<NSValue *> *_histogramPoints;

    CGFloat _widthSpace;
    CGFloat _upLimitPrice;

    NSUInteger _upLimitNum;

    NSMutableArray *_showNumbersArray;

    BOOL _isIndex0;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];

    _originX = 50;
    _originY = 75;
    _originTailSpace = 45;

    _widthSpace = .0f;
    _upLimitPrice = .0f;
    _upLimitNum = 0;

    _layers = [[NSMutableArray alloc] initWithCapacity:3];
    _dateArray = [[NSMutableArray alloc] initWithCapacity:0];
    _holderArray = [[NSMutableArray alloc] initWithCapacity:0];
    _avgNumArray = [[NSMutableArray alloc] initWithCapacity:0];
    _priceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _leftAxisArray = [[NSMutableArray alloc] initWithCapacity:0];
    _redLinePoints = [[NSMutableArray alloc] initWithCapacity:0];
    _histogramPoints = [[NSMutableArray alloc] initWithCapacity:0];
    _showNumbersArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)layoutSubviews {
    self.width = 414;
    self.height = 270;
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {

    _isIndex0 = (sender.selectedSegmentIndex == 0);

    [_leftAxisArray removeAllObjects];
    [self createLeftAxisDataWithArray:((sender.selectedSegmentIndex == 0) ? _holderArray : _avgNumArray)];
    [self createHistogramAndRedLinePointsWithArray:((sender.selectedSegmentIndex == 0) ? _holderArray : _avgNumArray)];
    [self clearLayers];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code

    CABasicAnimation *animation;
    animation = [CABasicAnimation animation];
    [animation setDuration:.25f];
    [[self layer] addAnimation:animation forKey:@"contents"];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [[UIColor whiteColor] set];
    CGContextSetLineWidth(context, .5f);

    // 1.背景
    CGContextFillRect(context, CGRectMake(_originX, _originY, CGRectGetWidth(rect) - _originX - _originTailSpace, 150));

    // 2.边框
    [[UIColor grayColor] set];
    for (NSUInteger i = 0; i < 6; i++) {
        //横线
        CGContextMoveToPoint(context, _originX, _originY + 30 * i);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect) - _originTailSpace, _originY + 30 * i);
        CGContextStrokePath(context);
        //竖线
        if (i < 2) {
            CGContextMoveToPoint(context, _originX + (CGRectGetWidth(rect) - _originX - _originTailSpace) * i, _originY);
            CGContextAddLineToPoint(context, _originX + (CGRectGetWidth(rect) - _originX - _originTailSpace) * i, _originY + 150);
            CGContextStrokePath(context);
        }
    }

    //⚠️如果没有数据，只画出边框即可
    if (_dateArray.count == 0) {
        return;
    }

    // 3.左侧纵坐标，人数。右侧坐标，价格
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentRight;

    NSDictionary *attrs = @{
        NSForegroundColorAttributeName: [UIColor grayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:10],
        NSParagraphStyleAttributeName: paragraphStyle
    }; //在词典中加入文本的颜色 字体 大小

    //左右纵坐标
    for (NSUInteger i = 0; i < 6; i++) {
        paragraphStyle.alignment = NSTextAlignmentRight;
        [_leftAxisArray[i] drawInRect:CGRectMake(5, _originY + 30 * i - 6, _originX - 10, 12) withAttributes:attrs];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        [_rightAxisArray[i] drawInRect:CGRectMake(CGRectGetWidth(rect) - _originTailSpace + 5, _originY + 30 * i - 6, _originTailSpace, 12)
                        withAttributes:attrs];
    }

    // 4.下面日期
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attrs = @{
        NSForegroundColorAttributeName: [UIColor grayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:9],
        NSParagraphStyleAttributeName: paragraphStyle
    }; //在词典中加入文本的颜色 字体 大小

    paragraphStyle.alignment = NSTextAlignmentCenter;
    for (NSUInteger i = 0; i < _dateArray.count; i++) {
        [_dateArray[i] drawInRect:CGRectMake(_originX + _widthSpace * i, _originY + 150 + 5, _widthSpace, 12) withAttributes:attrs];
    }

    // 5.柱状图 宽35
    NSMutableArray<UIBezierPath *> *rectPaths = [[NSMutableArray alloc] initWithCapacity:0];

    for (NSUInteger i = 0; i < _histogramPoints.count; i++) {
        UIBezierPath *rectPath = [UIBezierPath bezierPath];
        [rectPath moveToPoint:CGPointMake(_originX + _widthSpace / 2.f + _widthSpace * i, _originY + 150)];
        [rectPath addLineToPoint:CGPointMake(_histogramPoints[i].CGPointValue.x, _histogramPoints[i].CGPointValue.y)];
        [rectPaths addObject:rectPath];
    }

    // 6.曲线，只有一个数据时画一个点
    UIBezierPath *redPath = [UIBezierPath bezierPath];
    [rectPaths addObject:redPath];

    for (NSUInteger i = 0; i < _redLinePoints.count - 1; i++) {
        [redPath moveToPoint:CGPointMake(_redLinePoints[i].CGPointValue.x, _redLinePoints[i].CGPointValue.y)];
        [redPath addLineToPoint:CGPointMake(_redLinePoints[i + 1].CGPointValue.x, _redLinePoints[i + 1].CGPointValue.y)];
    }

    for (NSUInteger i = 0; i < rectPaths.count; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = rectPaths[i].CGPath;
        layer.strokeColor = (i == rectPaths.count - 1) ? [UIColor redColor].CGColor : [UIColor blueColor].CGColor;
        layer.lineWidth = (i == rectPaths.count - 1) ? 2 : 35;
        layer.frame = self.bounds;
        [self.layer addSublayer:layer];

        CABasicAnimation *baseAni = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        baseAni.duration = .75f;
        baseAni.fromValue = @0;
        baseAni.toValue = @1;
        [layer addAnimation:baseAni forKey:@"strokeEnd"];
        [_layers addObject:layer];
    }

    // 7.增加股东数量文字
    [_showNumbersArray enumerateObjectsUsingBlock:^(NSString *numStr, NSUInteger idx, BOOL *_Nonnull stop) {
        [numStr drawInRect:CGRectMake(_histogramPoints[idx].CGPointValue.x - _widthSpace / 2.f, _histogramPoints[idx].CGPointValue.y - 12, _widthSpace, 12)
            withAttributes:attrs];
    }];
}

- (void)clearLayers {
    //清除重复的线
    for (CAShapeLayer *layer in _layers) {
        [layer removeFromSuperlayer];
    }
    [_layers removeAllObjects];
}

#pragma mark - request
- (void)requestDataWithStockCode:(NSString *)stockCode {
    _stockCode = stockCode;
    if (stockCode == nil || _isDataBind) {
        [self setNeedsDisplay];
        return;
    }

    [self requestHolders];
}

- (void)requestHolders {
    
    NSString *url = [NSString stringWithFormat:@"https://sslapi.jrj.com.cn/stock/action/rating/getHolder.jspa?code=%@&isJson=1", _stockCode];
    
    [SHY_HttpRequest requestGetWithUrl:url parameters:nil success:^(id responseObject) {
        [self bindHoldersDataWithArray:responseObject];
    } failure:^(NSError *error) {
        //
    }];

}

- (void)bindHoldersDataWithArray:(NSArray *)array {

    if (array.count > 4) {
        //最多4个
        array = [array subarrayWithRange:NSMakeRange(array.count - 4, 4)];
    }

    [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *_Nonnull stop) {
        [_dateArray addObject:dic[@"enddate"]];
        [_holderArray addObject:[dic[@"tot_holder"] stringValue]];
        [_avgNumArray addObject:[dic[@"avg_num"] stringValue]];
        [_priceArray addObject:[dic[@"tclose"] stringValue]];
    }];

    // 1.处理左纵轴数据,默认取股东人数
    [self createLeftAxisDataWithArray:_holderArray];

    // 2.计算右侧价格
    [self createRightAxisDataWithArray:_priceArray];

    // 3.计算红线坐标、计算柱状图坐标
    [self createHistogramAndRedLinePointsWithArray:_holderArray];

    [self setNeedsDisplay];
}

- (void)createLeftAxisDataWithArray:(NSArray *)array {
    __block NSUInteger maxNum = 0;
    [array enumerateObjectsUsingBlock:^(NSString *numStr, NSUInteger idx, BOOL *_Nonnull stop) {
        if (numStr.integerValue > maxNum) {
            maxNum = numStr.integerValue;
        }
    }];

    //计算左纵坐标上限值，范围4位到7位，100整数倍，方便除5
    _upLimitNum = (NSUInteger)(maxNum * 1.1f) / 100.f * 100.f;

    CGFloat factor = 1;
    NSString *unitMinStr = @"0";
    NSString *unitStr = @"";
    //判断单位
    if (_upLimitNum > 1E8) {
        //亿为单位
        factor = 1E8;
        unitStr = @"亿";
        unitMinStr = @"0.00";
    } else if (_upLimitNum > 1E4) {
        //万为单位
        factor = 1E4;
        unitStr = @"万";
        unitMinStr = @"0.00";
    }

    //    左轴：股东人数（户）
    leftTitleLabel.text = _isIndex0 ? [NSString stringWithFormat:@"左轴：股东人数（%@户）", unitStr] :
                                      [NSString stringWithFormat:@"左轴：人均持股（%@股）", unitStr];

    [_leftAxisArray removeAllObjects];

    NSString *getStr = ([unitMinStr isEqualToString:@"0"]) ? @"%.f" : @"%.2f";

    _leftAxisArray = [@[
        [NSString stringWithFormat:getStr, _upLimitNum / factor],
        [NSString stringWithFormat:getStr, (_upLimitNum * .8f) / factor],
        [NSString stringWithFormat:getStr, (_upLimitNum * .6f) / factor],
        [NSString stringWithFormat:getStr, (_upLimitNum * .4f) / factor],
        [NSString stringWithFormat:getStr, (_upLimitNum * .2f) / factor],
        unitMinStr
    ] mutableCopy];

    // 计算纵坐标最大显示需要宽度
    __block CGFloat maxFloat = 0.0f;
    [_leftAxisArray enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        CGFloat strWidth = [obj sizeWithFont:[UIFont systemFontOfSize:10]].width;
        if (strWidth > maxFloat) {
            maxFloat = strWidth;
        }
    }];
    _originX = 5 + maxFloat + 5;
}

- (void)createRightAxisDataWithArray:(NSArray *)array {
    __block CGFloat maxPrice = .0f;
    [_priceArray enumerateObjectsUsingBlock:^(NSString *price, NSUInteger idx, BOOL *_Nonnull stop) {
        if (price.floatValue > maxPrice) {
            maxPrice = price.floatValue;
        }
    }];

    //右纵轴上限，范围0.00到299.99，考虑更多情况
    _upLimitPrice = maxPrice * 1.1f;

    [_rightAxisArray removeAllObjects];
    _rightAxisArray = [@[
        [NSString stringWithFormat:@"%.2f", _upLimitPrice],
        [NSString stringWithFormat:@"%.2f", _upLimitPrice * .8f],
        [NSString stringWithFormat:@"%.2f", _upLimitPrice * .6f],
        [NSString stringWithFormat:@"%.2f", _upLimitPrice * .4f],
        [NSString stringWithFormat:@"%.2f", _upLimitPrice * .2f],
        @"0.00"
    ] mutableCopy];
}

- (void)createHistogramAndRedLinePointsWithArray:(NSArray<NSString *> *)array {

    [_showNumbersArray removeAllObjects];
    //需要判断单位
    [array enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        CGFloat num = [obj doubleValue];
        NSString *numStr = [NSString stringWithFormat:@"%.0f", num];
        numStr = [numStr insertComma];
        [_showNumbersArray addObject:numStr];
    }];

    _widthSpace = (_dateArray.count > 1) ? (self.width - _originX - _originTailSpace) / _dateArray.count : 0;

    [_histogramPoints removeAllObjects];
    [_redLinePoints removeAllObjects];

    for (NSUInteger i = 0; i < _dateArray.count; i++) {
        //柱状线点数据
        CGFloat heightH = 150 * (array[i].integerValue / (CGFloat)_upLimitNum);
        [_histogramPoints addObject:[NSValue valueWithCGPoint:CGPointMake(_originX + _widthSpace / 2.f + _widthSpace * i, _originY + 150 - heightH)]];
        //红线假数据
        CGFloat heightR = (_upLimitPrice == 0) ? 0 : 150 * (CGFloat)(_priceArray[i].floatValue / _upLimitPrice);
        [_redLinePoints addObject:[NSValue valueWithCGPoint:CGPointMake(_originX + _widthSpace / 2.f + _widthSpace * i, _originY + 150 - heightR)]];
    }
}

@end
