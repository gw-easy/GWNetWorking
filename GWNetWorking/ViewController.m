//
//  ViewController.m
//  GWNetWorking
//
//  Created by gw on 2018/3/26.
//  Copyright © 2018年 gw. All rights reserved.
//

#import "ViewController.h"
#import "GWNetWorking.h"
#define HTTP_BaseURL      @"http://ispeakuat.suntrayoa.com/front"
#define  MemberLoginURL   (HTTP_BaseURL@"/toLogin.do")
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary * dic=[[NSMutableDictionary alloc] init];
    [dic setObject:@"13000010001" forKey:@"username"];
    [dic setObject:@"qwe123" forKey:@"password"];
    [dic setObject:@"service" forKey:@"service"];
    [dic setObject:[[NSUUID UUID] UUIDString] forKey:@"machine_code"];
    
    [GWNetWorking request:MemberLoginURL WithParam:dic withMethod:POST_GW uploadFileProgress:^(NSProgress *uploadProgress) {
        
    } success:^(id result) {
        
        NSLog(@"---result=%@",result);
    } failure:^(NSError *erro) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
