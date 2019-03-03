//
//  ViewController.m
//  GWNetWorking
//
//  Created by gw on 2018/3/26.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "ViewController.h"
#import "GWNetWorking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *paramDict = @{
                                @"username":@"520it",
                                @"pwd":@"520it",
                                @"type":@"JSON"
                                };
    [GWNetWorking request:@"http://120.25.226.186:32812/login" WithParam:paramDict withMethod:GET_GW success:^(id result, NSURLResponse *response) {
        NSLog(@"---%@",result);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
