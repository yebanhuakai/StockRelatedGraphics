//
//  GudongViewController.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "GudongViewController.h"
#import "GuDongView.h"
#import "UIViewExt.h"

@interface GudongViewController ()
{
    GuDongView *_guDongView;
}

@end

@implementation GudongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _guDongView = [[[NSBundle mainBundle] loadNibNamed:@"GuDongView" owner:self options:nil] firstObject];
    [self.view addSubview:_guDongView];
    _guDongView.top = 100;
    
    [_guDongView requestDataWithStockCode:@"600519"];
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
