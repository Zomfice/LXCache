//
//  ViewController.m
//  LXCache
//
//  Created by 麻小亮 on 2018/11/1.
//  Copyright © 2018 xllpp. All rights reserved.
//

#import "ViewController.h"
#import "LXCache.h"
#import "SubViewController.h"
#import <objc/runtime.h>
#import "NSObject+LXCategory.h"
#import <time.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self performSelectorWithArguments:@selector(asdkf::),@"aa",4];
//    [self performSelectorWithArguments:@selector(a)];
//    [[LXCache defaultCache] containsObjectForKey:@"11112341234234"];
    __block  NSDate *timeNow = [NSDate date];
    __block int count = 0;
    for (int i = 0; i < 10000; i++) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [LXCache defaultCache].identity(@"11");
            count++;
            NSLog(@"耗时：：：：：%f  次数：：：：：%d",[[NSDate date] timeIntervalSinceDate:timeNow],count);
//        });
    }
    

}

- (void)asdkf:(NSString *)adf :(CGFloat)asdf{
    NSLog(@"1");
}

- (void)a{
    NSLog(@"2");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self presentViewController:[SubViewController new] animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
