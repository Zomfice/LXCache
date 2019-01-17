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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL showRequiredMethods = NO;
    BOOL showInstanceMethods = YES;

    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(@protocol(LXaaSeparateCacheProtocol) , showRequiredMethods, showInstanceMethods, &methodCount);

    NSLog(@"%d required instance methods found:", methodCount);

    for (int i = 0; i < methodCount; i++)
    {
        struct objc_method_description methodDescription = methods[i];
        NSLog(@"Method #%d: %@", i, NSStringFromSelector(methodDescription.name));
    }

    free(methods);
    [[LXCache defaultCache] removeSeparaAllCacheWithBlock:^(BOOL success) {
        
    }];
    [[LXCache defaultCache].identity(@"default") removeSeparaAllCacheWithBlock:^(BOOL success) {
        
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self presentViewController:[SubViewController new] animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
