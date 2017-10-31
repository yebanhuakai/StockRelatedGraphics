//
//  GuPiaoPeiZhiViewController.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "GuPiaoPeiZhiViewController.h"
#import "JRJStockGuPiaoPeiZhiView.h"

@interface GuPiaoPeiZhiViewController ()
@property (weak, nonatomic) IBOutlet JRJStockGuPiaoPeiZhiView *guPiaoPeiZhiView;

@end

@implementation GuPiaoPeiZhiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_guPiaoPeiZhiView requestZuHePeiZhiWithGroupID:@"0" userID:@"0"];
    
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
