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
    config.isNeedPullDownRefresh = YES;
    NSURL *url = [NSURL URLWithString:@"https://ph.6632888.com/ph2.html"];
    //[[NSBundle mainBundle] URLForResource:@"demo.html" withExtension:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setValue:@"name" forHTTPHeaderField:@"token"];
    [_webView setConfig:config];
    [_webView loadRequest:request];
    _webView.backgroundColor = [UIColor whiteColor];
    [_webView setupBridge];
    [_webView registerHandler:@"getShare" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@", data);
    }];
    [_webView callHandler:@"getShare" data:nil responseCallback:^(id responseData) {
        
    }];
    [self.view addSubview:_webView];
}


@end
