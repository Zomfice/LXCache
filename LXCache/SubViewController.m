//
//  SubViewController.m
//  LXCache
//
//  Created by 麻小亮 on 2018/11/9.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import "SubViewController.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define HeaderHeight 300
#define titleViewHeight 100
#define imageViewHeight (HeaderHeight - titleViewHeight)
@interface SubViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * imageView;
@property (nonatomic, strong) UIView * titleView;
@property (nonatomic, strong) UIView * headerView;
@end

@implementation SubViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [self.scrollView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.scrollView removeGestureRecognizer:obj];
    }];
    [self.tableView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.scrollView addGestureRecognizer:obj];
    }];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self headerView];
    [self imageView];
    [self titleView];
    // Do any additional setup after loading the view.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    CGFloat originY = self.tableView.contentOffset.y;
    if (originY > imageViewHeight) {
        CGRect frame = self.headerView.frame;
        frame.origin.y = - imageViewHeight;
        self.headerView.frame = frame;
    }else if (originY > 0) {
        CGRect frame = self.headerView.frame;
        frame.origin.y = - originY;
        self.headerView.frame = frame;
    }else{
        CGRect frame = self.headerView.frame;
        frame.origin.y = 0;
        self.headerView.frame = frame;
    }
//    NSLog(@"%f", -originY);
}

- (void)loadView{
    self.view = self.scrollView;
}
- (void)dealloc{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}
#pragma mark - UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"这是顺序：：：：：%ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(0, 0, WIDTH, HeaderHeight / 2);
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        label.text = [@"销量" stringByAppendingFormat:@"%ld",section];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}
#pragma mark - 懒加载 -
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleViewHeight, WIDTH, HEIGHT - titleViewHeight) style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, imageViewHeight)];
        [self.scrollView addSubview:_tableView];
    }
    return _tableView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.contentSize = CGSizeMake(WIDTH, HEIGHT);
    }
    return _scrollView;
}

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, imageViewHeight, WIDTH, titleViewHeight)];
        _titleView.backgroundColor = [UIColor cyanColor];
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(0, 0, WIDTH, titleViewHeight);
        [_titleView addSubview:label];
        label.text = @"titleView";
        label.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:_titleView];
    }
    return _titleView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.frame = CGRectMake(0, 0, WIDTH, HeaderHeight);
        
        _headerView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_headerView];
    }
    return _headerView;
}

- (UIView *)imageView{
    if (!_imageView) {
        _imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, imageViewHeight)];
        _imageView.backgroundColor = [UIColor purpleColor];
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(0, 0, WIDTH, imageViewHeight);
        label.textAlignment = NSTextAlignmentCenter;
        [_imageView addSubview:label];
        label.text = @"imageVIew";
        [self.headerView addSubview:_imageView];
    }
    return _imageView;
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
