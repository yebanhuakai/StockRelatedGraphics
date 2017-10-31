//
//  GuPiaoPeiZhiDrawView.m
//  JRJInvestAdviser
//
//  Created by Yuemeng on 16/9/8.
//  Copyright © 2016年 jrj. All rights reserved.
//

#import "GuPiaoPeiZhiDrawView.h"

@implementation GuPiaoPeiZhiDrawView {
    CGFloat _originX;
    CGFloat _originY;

    CGFloat _centerX;
    CGFloat _centerY;
    CGFloat _radii;

    CGFloat _verticalSpace;
    CGFloat _originTailSpace;

    CGFloat _aniTime;

    NSMutableArray<NSString *> *_radians; //最多6个
    NSMutableArray<NSNumber *> *_times;   //最多6个

    NSMutableArray<CAShapeLayer *> *_layers;

    NSArray<UIColor *> *_colors;
    
    NSInteger _maxIndex;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _originX = 165;
    _originY = 30;

    _centerX = 98;
    _centerY = 108;
    _radii = 55;
    _verticalSpace = 25;
    _originTailSpace = 60;

    _aniTime = 1.f;
    _maxIndex = 0;

    _layers = [[NSMutableArray alloc] initWithCapacity:0];
    _radians = [[NSMutableArray alloc] initWithCapacity:0];
    _layers = [[NSMutableArray alloc] initWithCapacity:0];

    _colors = @[
        [UIColor redColor],
        [UIColor yellowColor],
        [UIColor orangeColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor purpleColor]
    ];
}

- (void)drawRect:(CGRect)rect {

    if (_radians.count == 0) {
        return;
    }

    [_layers removeAllObjects];

    _originX = (CGRectGetWidth(rect) - 80) / 2.f + CGRectGetWidth(rect) / 2.f;
    _centerX = CGRectGetWidth(rect) / 2.f;

    CABasicAnimation *animation;
    animation = [CABasicAnimation animation];
    [animation setDuration:_aniTime];
    [self.layer addAnimation:animation forKey:@"contents"];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, .5f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 5, [UIColor colorWithWhite:0 alpha:.2].CGColor);

    // 1.背景
    [[UIColor whiteColor] set];
    CGContextFillRect(context, rect);

    // 2.画弧度
    for (NSUInteger i = 0; i < _radians.count - 1; i++) {

        [_colors[i] setStroke];
        UIBezierPath *circlePath = [UIBezierPath bezierPath];

        circlePath.lineWidth = i == _maxIndex ? 20 : 10;//取最多的
        [circlePath addArcWithCenter:CGPointMake(_centerX, _centerY)
                              radius:_radii
                          startAngle:[_radians[i] floatValue] * M_PI / 180
                            endAngle:[_radians[i + 1] floatValue] * M_PI / 180
                           clockwise:YES];
        [circlePath stroke];
    }

    // 3.逆向白弧
    UIBezierPath *coverPath = [UIBezierPath bezierPath];
    [coverPath addArcWithCenter:CGPointMake(_centerX, _centerY) radius:_radii startAngle:-90 * M_PI / 180.f endAngle:270.1f * M_PI / 180.f clockwise:NO];

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = coverPath.CGPath;
    layer.strokeColor = [[UIColor whiteColor] CGColor];
    layer.fillColor = [[UIColor clearColor] CGColor];
    layer.lineWidth = 36;
    layer.frame = self.bounds;

    [self.layer addSublayer:layer];

    CABasicAnimation *curveAni = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    curveAni.duration = _aniTime;
    curveAni.fromValue = @1;
    curveAni.toValue = @0;
    curveAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    curveAni.removedOnCompletion = NO;
    curveAni.fillMode = kCAFillModeForwards;
    [layer addAnimation:curveAni forKey:@"strokeEnd"];

    CABasicAnimation *alphaAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAni.beginTime = CACurrentMediaTime() + _aniTime;
    alphaAni.fromValue = @1;
    alphaAni.toValue = @0;
    alphaAni.removedOnCompletion = NO;
    alphaAni.fillMode = kCAFillModeForwards;
    [layer addAnimation:alphaAni forKey:@"opacity"];
    [_layers addObject:layer];
}

- (void)bindDataWithAngles:(NSArray<NSString *> *)angles maxIndex:(NSInteger)maxIndex
{
    [_radians removeAllObjects];
    [_radians addObjectsFromArray:angles];
    _maxIndex = maxIndex;
}

- (void)startAnimation {
    [self setNeedsDisplay];
}

- (void)clearLayers {
    for (CAShapeLayer *layer in _layers) {
        [layer removeFromSuperlayer];
    }
    [_layers removeAllObjects];
}

@end
