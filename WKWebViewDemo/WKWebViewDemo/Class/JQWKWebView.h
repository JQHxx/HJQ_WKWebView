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
#import "WKWebViewJavascriptBridge.h"

NS_ASSUME_NONNULL_BEGIN

// message.name，message.body
typedef void(^JQJSSendDataBlock)(NSString *name, id body);
typedef void(^JQTitleChangeBlock)(NSString *title);
typedef void(^JQContentHeightBlock)(double height);
typedef void(^JQResponseCallback)(NSDictionary *data, WVJBResponseCallback responseCallback);

@protocol JQWKWebViewNavigationDelegate <NSObject>

- (void)jqWebView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
- (void)jqWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)jqWebView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
- (void)jqwebView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
- (void)jqWebView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
- (void)jqWebView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

@end

@protocol JQWKWebViewUIDelegate <NSObject>

- (void)jqwebView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
- (void)jqwebView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler;
- (void)jqwebView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler;

@end

@interface JQWKWebView : UIView

@property (nonatomic, weak) id<JQWKWebViewNavigationDelegate> navigationDelegate;

@property (nonatomic, weak) id<JQWKWebViewUIDelegate> UIDelegate;

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

// WebViewJavascriptBridge
- (void)setupBridge;

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;

- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;

@end

NS_ASSUME_NONNULL_END
