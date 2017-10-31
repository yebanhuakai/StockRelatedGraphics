//
//  LeijishouyiViewController.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "LeijishouyiViewController.h"
#import "LeiJiShouYiLvView.h"
#import "UIViewExt.h"

@interface LeijishouyiViewController ()
{
    LeiJiShouYiLvView *_leiJiShouYiLvView;
}

@end

@implementation LeijishouyiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _leiJiShouYiLvView = [[[NSBundle mainBundle] loadNibNamed:@"LeiJiShouYiLvView" owner:self options:nil] firstObject];
    _leiJiShouYiLvView.top = 100;
    [self.view addSubview:_leiJiShouYiLvView];
    
    [_leiJiShouYiLvView requestDataWithStockCode:@"600519" stockName:@"贵州茅台"];
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
