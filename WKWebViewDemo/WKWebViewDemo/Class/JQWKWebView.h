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
#import "WKWebViewCacheTool.h"

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
- (void)jqwebViewWebContentProcessDidTerminate:(WKWebView *)webView;

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

- (void)loadRequest:(NSMutableURLRequest *) request;

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

- (void)reload;

/** 重新加载网页,忽略缓存 */
- (void)reloadFromOrigin;

- (BOOL)canGoBack;

- (void)goBack;

- (BOOL)canGoForward;

- (void)goForward;

- (void)pauseWebPlay;

- (WKWebView *)getWKWebView;

- (void)callJS:(NSString *)jsMethod handler:(void (^)(id response, NSError *error))handler;

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name;

 /** 清除所有缓存（cookie除外） */
- (void)clearWebCacheFinish:(void(^)(BOOL finish,NSError *error))block;

// WebViewJavascriptBridge
- (void)setupBridge;

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler;

- (void)removeHandler:(NSString*)handlerName;

- (void)reset;

- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;

@end

NS_ASSUME_NONNULL_END
