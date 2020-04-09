//
//  TestWebViewVC.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "TestWebViewVC.h"
#import "JQWKWebView.h"

@interface TestWebViewVC ()

@property (nonatomic, strong) JQWKWebView *webView;
@end

@implementation TestWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[JQWKWebView alloc]init];
    _webView.frame = self.view.bounds;
    JQConfig *config = [[JQConfig alloc]init];
    config.indicatorType = Activity;
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [_webView setConfig:config];
    [_webView loadRequest:request];
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
}


@end
