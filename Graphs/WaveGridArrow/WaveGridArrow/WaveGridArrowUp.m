//
//  WaveGridArrowUp.m
//  WaveGridArrow
//
//  Created by Shenry on 2017/10/22.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "WaveGridArrowUp.h"

@implementation WaveGridArrowUp

- (void)setPercent:(CGFloat)percent {
    CGFloat height = _width * 17 + 16;
    
    if (percent > 1.f) {
        percent = 1.f;
    }
    _currentLinePointY = _originY + height * (1.f - percent);
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, .5f);
    
    // 1.上面的由方块组成的正三角型 11 * 6
    //   0  1  2  3  4  5  6  7  8  9 10
    //   11 12 13 14 15 16 17 18 19 20 21
    //   22 23 24 25 26 27 28 29 30 31 32
    //      ■
    //    ■ ■ ■
    //  ■ ■ ■ ■ ■
    // ...
    
    CGMutablePathRef pathBlock = CGPathCreateMutable();
    
    for (NSUInteger i = 0; i < 6 * 11; i++) {
        NSUInteger line = i / 11;                 //第几行,0 1 2...
        NSUInteger factor = 2 * line + 1;         //因数，1，3，5...计算5的倍数，用来确定中轴数
        NSUInteger middleNum = 5 * factor + line; //中轴数，5，16，27...
        //当前数减去中轴数的绝对值小于等于行数，即为需要画方块
        if (abs((int)(i - middleNum)) <= line) {
            CGPathAddRect(pathBlock, nil, CGRectMake(_originX + _widthAddOne * ((int)(i - middleNum) + 5), _originY + _widthAddOne * line, _width, _width));
        }
    }
    
    // 2.下面正方形 7 * 11
    for (NSUInteger i = 0; i < 11 * 7; i++) {
        NSUInteger line = i / 7;
        NSUInteger row = i % 7;
        CGPathAddRect(pathBlock, nil, CGRectMake(_originX + _widthAddOne * 2 + _widthAddOne * row, _originY + _widthAddOne * 6 + _widthAddOne * line, _width, _width));
    }
    
    CGContextAddPath(context, pathBlock);
    CGContextClip(context);
    CGContextFillRect(context, rect);
    CGPathRelease(pathBlock);
    
    // 3.sin曲线
    CGMutablePathRef pathSin = CGPathCreateMutable();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    float y = _currentLinePointY;
    
    CGPathMoveToPoint(pathSin, NULL, _originX, y);
    
    //水的波浪
    for (NSUInteger x = _originX; x <= _originX + _widthAddOne * 11; x++) {
        y = a * sin(x * 3 / 180.f * M_PI + 4 * b / M_PI) * _width + _currentLinePointY;
        CGPathAddLineToPoint(pathSin, nil, x, y);
    }
    
    //下面三根线做闭合
    CGPathAddLineToPoint(pathSin, nil, _originX + _widthAddOne * 11, _originY + _widthAddOne * 17); //右下角
    CGPathAddLineToPoint(pathSin, nil, _originX, _originY + _widthAddOne * 17);                     //左下角
    CGPathAddLineToPoint(pathSin, nil, _originX, _currentLinePointY);                               //左上角
    
    CGContextAddPath(context, pathSin);
    CGContextDrawPath(context, kCGPathFill);
    CGPathRelease(pathSin);
}


@end
