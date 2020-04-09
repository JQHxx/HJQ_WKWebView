//
//  HJQ_WKWebView.h
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "JQConfig.h"
#import "JQWKWebViewEX.h"

NS_ASSUME_NONNULL_BEGIN

// message.name，message.body
typedef void(^JQJSSendDataBlock)(NSString *name, id body);
typedef void(^JQTitleChangeBlock)(NSString *title);
typedef void(^JQContentHeightBlock)(double height);

@protocol JQWKWebViewDelegate <NSObject>

- (void)jqWebView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
- (void)jqWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)jqWebView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
- (void)jqWebView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
- (void)jqWebView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

@end

@interface JQWKWebView : UIView

@property (nonatomic, weak) id<JQWKWebViewDelegate> delegate;

@property (nonatomic, copy) JQJSSendDataBlock jsSendDataBlock;

@property (nonatomic, copy) JQTitleChangeBlock titleChangeBlock;

@property (nonatomic, copy) JQContentHeightBlock contentHeightBlock;

- (void)setConfig:(JQConfig *)config;

- (void)loadRequest:(NSURLRequest *) request;

- (void)reload;

- (BOOL)canGoBack;

- (void)goBack;

- (BOOL)canGoForward;

- (void)goForward;

- (void)pauseWebPlay;

- (WKWebView *)getWKWebView;

- (void)evaluateJavaScript:(NSString *) js;

@end

NS_ASSUME_NONNULL_END
