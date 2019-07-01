//
//  ViewController.m
//  FloatViewDome
//
//  Created by zcy on 2017/11/14.
//  Copyright © 2017年 CY. All rights reserved.
//

#import "ViewController.h"
#import "FloatView.h"

@interface ViewController ()<UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FloatView *floatView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
//    self = [[FloatView alloc] initWithImage:[UIImage imageNamed:@"float_view"]];

    self.floatView = [[FloatView alloc] initWithFrame:CGRectMake(100, 100, 75, 75)];
    [self.floatView setImageWithName:@"give_me_money"];
    self.floatView.stayMode = STAYMODE_LEFTANDRIGHT;
    [self.floatView setTapActionWithBlock:^{
        NSLog(@"跳转到发红包界面");
    }];
    [self.view addSubview:self.floatView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.floatView moveToHalfInScreenWhenScrolling];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.floatView setCurrentAlpha:0.5];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.floatView setCurrentAlpha:1];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
