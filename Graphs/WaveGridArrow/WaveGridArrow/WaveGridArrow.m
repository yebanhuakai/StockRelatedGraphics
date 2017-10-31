//
//  WaveGridArrow.m
//  WaveGridArrow
//
//  Created by Shenry on 2017/10/22.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "WaveGridArrow.h"

@implementation WaveGridArrow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createVaribles];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createVaribles];
}

- (void)createVaribles {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _width = (self.frame.size.width - 10) / 11.f;
    _originX = 0;
    _originY = (self.frame.size.height - _width * 17 - 16) / 2.f;
    _widthAddOne = _width + 1;
    
    //
    a = 1.5;
    b = 0;
    jia = NO;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}

- (void)setPercent:(CGFloat)percent {
    //必须子类实现
}

- (void)animateWave {
    if (jia) {
        a += 0.01;
    } else {
        a -= 0.01;
    }
    
    if (a <= 1) {
        jia = YES;
    }
    
    if (a >= 1.5) {
        jia = NO;
    }
    
    b += 0.1;
    
    [self setNeedsDisplay];
}

- (void)stopTimer {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
