//
//  RankViewController.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "RankViewController.h"
#import "RankHistogramView.h"
#import "UIViewExt.h"

@interface RankViewController ()
{
    //排名
    RankHistogramView *_rankHistogramView;
    RankHistogramView *_industryRankHistogramView;
}

@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _rankHistogramView = [[[NSBundle mainBundle] loadNibNamed:@"RankHistogramView" owner:self options:nil] firstObject];
    _industryRankHistogramView = [[[NSBundle mainBundle] loadNibNamed:@"RankHistogramView" owner:self options:nil] firstObject];
    
    _rankHistogramView.top = 100;
    [self.view addSubview:_rankHistogramView];
    _industryRankHistogramView.top = _rankHistogramView.bottom + 10;
    [self.view addSubview:_industryRankHistogramView];
    
    [_rankHistogramView requestDataWithStockCode:@"600519" isGeGu:YES];
    [_industryRankHistogramView requestDataWithStockCode:@"600519" isGeGu:NO];
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
