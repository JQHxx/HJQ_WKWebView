//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "ViewController.h"
#import "TestWebViewVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TestWebViewVC *webVC = [[TestWebViewVC alloc]init];
    webVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:webVC animated:YES completion:nil];
}

@end
