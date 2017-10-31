//
//  LeiJiShouYiLvView.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "LeiJiShouYiLvView.h"
#import "UIViewExt.h"
#import "SHY_HttpRequest.h"

@implementation LeiJiShouYiLvView {
    NSString *_stockCode;
    NSString *_stockName;
    BOOL _isDataBind;

    CGFloat _originX;
    CGFloat _originY;
    CGFloat _originTailSpace;

    __weak IBOutlet UILabel *_limitUpLabel;
    __weak IBOutlet UILabel *_zeroLabel;
    __weak IBOutlet UILabel *_limitDownLabel;

    NSMutableArray<NSValue *> *_pointsRed;
    NSMutableArray<NSValue *> *_pointsBlue;

    __weak IBOutlet UILabel *bigTitleLabel;
    __weak IBOutlet UILabel *stockNameLabel;
    __weak IBOutlet UILabel *indexNameLabel;

    NSMutableArray *_dateArray;

    CGFloat _maxUpPercent;
}

- (void)layoutSubviews {
    self.width = 414;
    self.height = 200;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];

    _dateArray = [[NSMutableArray alloc] initWithCapacity:0];
    _pointsRed = [[NSMutableArray alloc] initWithCapacity:0];
    _pointsBlue = [[NSMutableArray alloc] initWithCapacity:0];

    _originX = 60;
    _originY = 62;
    _originTailSpace = 20;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code

    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(context, .5f);
    CGContextSetLineJoin(context, kCGLineJoinRound);

    // 1.灰色背景
    CGContextFillRect(context, CGRectMake(_originX, _originY, CGRectGetWidth(rect) - _originTailSpace - _originX, 80));

    // 2.三条横线
   [[UIColor grayColor] set];
    for (NSUInteger i = 0; i < 3; i++) {
        CGContextMoveToPoint(context, _originX, _originY + 40 * i);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect) - _originTailSpace, _originY + 40 * i);
        CGContextStrokePath(context);
    }

    //⚠️如果没有数据，只画出边框即可
    if (_dateArray.count == 0) {
        return;
    }

    // 3.最多12个月份斜45°
    NSDictionary *attrs = @{
        NSForegroundColorAttributeName: [UIColor blackColor],
        NSFontAttributeName: [UIFont systemFontOfSize:9],
    }; //在词典中加入文本的颜色 字体 大小
    //数字间距
    CGFloat numSpace = (_dateArray.count > 1) ? (414 - _originTailSpace - _originX) / (_dateArray.count - 1) : 0;

    for (NSUInteger i = 0; i < _dateArray.count; i++) {

        CGContextSaveGState(context);

        CGFloat xAdd = _originX + numSpace * i;
        CGFloat yAdd = _originY + 100 + 10;
        CGFloat xSub = -(_originX + numSpace * i);
        CGFloat ySub = -(_originY + 100 + 10);

        CGContextTranslateCTM(context, xAdd, yAdd);
        CGContextRotateCTM(context, -M_PI / 4);
        CGContextTranslateCTM(context, xSub, ySub);

        [_dateArray[i] drawInRect:CGRectMake(_originX - 30 + numSpace * i, _originY + 100, 60, 20) withAttributes:attrs];

        CGContextRestoreGState(context);
    }

    // 4.绘制红蓝线
    [[UIColor redColor] set];
    CGContextSetLineWidth(context, 2);
    CGContextSetLineCap(context, kCGLineCapRound);
    //注意数据为1个的时候
    for (NSUInteger i = 0; i < _pointsRed.count - 1; i++) {
        CGContextMoveToPoint(context, _pointsRed[i].CGPointValue.x, _pointsRed[i].CGPointValue.y);
        CGContextAddLineToPoint(context, _pointsRed[i + 1].CGPointValue.x, _pointsRed[i + 1].CGPointValue.y);
        CGContextStrokePath(context);
        CGContextSaveGState(context);
        [[UIColor blueColor] set];
        CGContextMoveToPoint(context, _pointsBlue[i].CGPointValue.x, _pointsBlue[i].CGPointValue.y);
        CGContextAddLineToPoint(context, _pointsBlue[i + 1].CGPointValue.x, _pointsBlue[i + 1].CGPointValue.y);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

#pragma mark - request
- (void)requestDataWithStockCode:(NSString *)stockCode stockName:(NSString *)stockName {
    _stockCode = stockCode;
    _stockName = stockName;
    if (stockCode == nil || _isDataBind) {
        return;
    }

    bigTitleLabel.text = [NSString stringWithFormat:@"%@累计收益率", _stockName];
    stockNameLabel.text = _stockName;

    [self requestData];
}

- (void)requestData {
    
    NSString *url = [NSString stringWithFormat:@"https://hqdata.jrj.com.cn/app/%@/zhengu/gains.js", _stockCode];
    
    [SHY_HttpRequest requestGetWithUrl:url parameters:nil success:^(id responseObject) {
        //
        [self bindDataWithDic:responseObject];
    } failure:^(NSError *error) {
        //
        NSLog(@"%@", error);
    }];
}

- (void)bindDataWithDic:(NSDictionary *)dic {

    indexNameLabel.text = dic[@"indexname"];
    NSArray *array = dic[@"data"];

    // 1.取日期，每30天取一次。 确定最大振幅
    __block CGFloat maxPercent = .0f;

    NSMutableArray *gainsArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *indexGainsArray = [[NSMutableArray alloc] initWithCapacity:0];

    [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *_Nonnull stop) {
        if (idx % 23 == 0 || (idx == array.count - 1)) {
            [_dateArray addObject:dic[@"enddate"]]; //从今天往前取
        }

        CGFloat gainsF = [dic[@"gains"] floatValue];
        CGFloat indexGainsF = [dic[@"indexGains"] floatValue];

        [gainsArray addObject:dic[@"gains"]];
        [indexGainsArray addObject:dic[@"indexGains"]];

        if (maxPercent < fabs(gainsF)) {
            maxPercent = fabs(gainsF);
        }

        if (maxPercent < fabs(indexGainsF)) {
            maxPercent = fabs(indexGainsF);
        }

    }];

    //上限
    _maxUpPercent = maxPercent * 1.1f;

    _limitUpLabel.text = [NSString stringWithFormat:@"%.2f%%", _maxUpPercent];
    _limitDownLabel.text = [NSString stringWithFormat:@"-%.2f%%", _maxUpPercent];

    // 2.生成数据
    CGFloat numSpace = (414 - _originTailSpace - _originX) / (array.count - 1);
    for (NSUInteger i = 0; i < array.count; i++) {
        [_pointsBlue addObject:[NSValue valueWithCGPoint:CGPointMake(_originX + numSpace * i, _originY + 40 - 40 * ([gainsArray[i] floatValue] / _maxUpPercent))]];
        [_pointsRed addObject:[NSValue valueWithCGPoint:CGPointMake(_originX + numSpace * i, _originY + 40 - 40 * ([indexGainsArray[i] floatValue] / _maxUpPercent))]];
    }

    [self setNeedsDisplay];
}

@end
