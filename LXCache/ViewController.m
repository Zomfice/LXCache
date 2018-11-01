//
//  ViewController.m
//  LXCache
//
//  Created by 麻小亮 on 2018/11/1.
//  Copyright © 2018 xllpp. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#define Lock() pthread_mutex_lock(&_lock);
#define Unlock() pthread_mutex_unlock(&_lock);
@interface ViewController (){
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary * dict;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pthread_mutex_init(&_lock, NULL);
     self.dict = [NSMutableDictionary dictionary];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 102400; i++) {
            Lock()
            if (i % 2 == 0) {
                [self.dict setObject:@(i) forKey:@"key"];
            } else {
                [self.dict removeObjectForKey:@"key"];
            }
            Unlock()
        }
        
    });
    
    for (NSInteger i = 0; i < 102400; i++) {\
        
        
        
            NSLog(@"%@ %ld",_dict, _dict.count);
            Lock()
            NSArray * dict = [self.dict allKeys];
            Unlock()
        
//         NSDictionary * dict2 = [_dict copy];
    }
    // Do any additional setup after loading the view, typically from a nib.
}
- (NSMutableDictionary *)dict{
    
    if (!_dict) {
        _dict = [NSMutableDictionary dictionary];
    }
    
    return _dict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
