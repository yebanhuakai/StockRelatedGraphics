//
//  WaveGridArrowViewController.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "WaveGridArrowViewController.h"
#import "WaveGridArrowUp.h"
#import "WaveGridArrowDown.h"

@interface WaveGridArrowViewController ()

@end

@implementation WaveGridArrowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    WaveGridArrowUp *arrowUp = [[WaveGridArrowUp alloc] initWithFrame:CGRectMake(157, 100, 100, 200)];
    [arrowUp setPercent:.7]; //control the wave high, 0.0~1.0
    [self.view addSubview:arrowUp];
    
    WaveGridArrowDown *arrowDown = [[WaveGridArrowDown alloc] initWithFrame:CGRectMake(157, 400, 100, 200)];
    [arrowDown setPercent:.7]; //control the wave high, 0.0~1.0
    [self.view addSubview:arrowDown];
}

- (NSString *)title
{
    return @"波浪箭头动画";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
