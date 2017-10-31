//
//  WaveGridArrow.h
//  WaveGridArrow
//
//  Created by Shenry on 2017/10/22.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  大箭头公共类
 */
@interface WaveGridArrow : UIView {
    CGFloat _originX;
    CGFloat _originY;
    CGFloat _width;
    CGFloat _widthAddOne;
    
    float a;
    float b;
    BOOL jia;
    float _currentLinePointY;
    
    NSTimer *_timer;
}

/**
 *  传入百分比参数，不需要×100
 *
 *  @param percent 百分比参数，如：0.09
 */
- (void)setPercent:(CGFloat)percent;

- (void)stopTimer;

@end
