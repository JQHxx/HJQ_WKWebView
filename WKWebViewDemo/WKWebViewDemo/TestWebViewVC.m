//
//  TestWebViewVC.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "TestWebViewVC.h"
#import "HJQ_WKWebView.h"

@interface TestWebViewVC ()

@property (nonatomic, strong) HJQ_WKWebView *webView;
@end

@implementation TestWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[HJQ_WKWebView alloc]init];
    _webView.frame = self.view.bounds;
    HJQ_Config *config = [[HJQ_Config alloc]init];
    config.indicatorType = Activity;
    config.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [_webView setConfig:config];
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
}


@end
