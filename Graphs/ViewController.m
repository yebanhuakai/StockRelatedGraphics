//
//  ViewController.m
//  Graphs
//
//  Created by Shenry on 2017/10/31.
//  Copyright © 2017年 Shenry. All rights reserved.
//

#import "ViewController.h"
#import "WaveGridArrowViewController.h"
#import "LeijishouyiViewController.h"
#import "RankViewController.h"
#import "GudongViewController.h"
#import "GuPiaoPeiZhiViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *_titles;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _titles = @[@"波浪箭头动画", @"累计收益曲线", @"个股排行矩形", @"股东人数动画", @"饼状图动画"];
}

- (NSString *)title
{
    return @"股票相关图形";
}

#pragma mark - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CELLID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = _titles[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            WaveGridArrowViewController *wgaVC = [[WaveGridArrowViewController alloc] init];
            [self.navigationController pushViewController:wgaVC animated:YES];
        }
            break;
        case 1:
        {
            LeijishouyiViewController *wgaVC = [[LeijishouyiViewController alloc] init];
            [self.navigationController pushViewController:wgaVC animated:YES];
        }
            break;
        case 2:
        {
            RankViewController *wgaVC = [[RankViewController alloc] init];
            [self.navigationController pushViewController:wgaVC animated:YES];
        }
            break;
        case 3:
        {
            GudongViewController *wgaVC = [[GudongViewController alloc] init];
            [self.navigationController pushViewController:wgaVC animated:YES];
        }
            break;
        case 4:
        {
            GuPiaoPeiZhiViewController *wgaVC = [[GuPiaoPeiZhiViewController alloc] initWithNibName:@"GuPiaoPeiZhiViewController" bundle:nil];
            [self.navigationController pushViewController:wgaVC animated:YES];
        }
            break;
            
        default:
            break;
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
