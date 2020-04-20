//
//  HJQ_WKWebView.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "JQWKWebView.h"
#import <objc/runtime.h>
#import "JQWeakScriptMessageDelegate.h"

@interface JQWKWebView() <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) CALayer *progresslayer;
@property (nonatomic, strong) WKWebViewConfiguration *wkConfig;
@property (nonatomic, strong) JQConfig *config;
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, strong) NSMutableArray *handlerNames;

@end

@implementation JQWKWebView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    @try {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.wkWebView removeObserver:self forKeyPath:@"scrollView.contentSize"];
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
        [self.wkConfig.userContentController removeAllUserScripts];
        self.wkWebView.navigationDelegate = nil;
        self.wkWebView.UIDelegate = nil;
        for (NSString *str in self.handlerNames) {
            [self removeHandler:str];
        }
        [self.handlerNames removeAllObjects];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.wkWebView.frame = self.bounds;
    if (self.config) {
        if (self.config.indicatorType == Progress) {
            self.progressView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 3);
        } else if(self.config.indicatorType == Activity) {
            self.loadingView.center = self.wkWebView.center;
        }
    }
}

#pragma mark - Public methods
- (void)pauseWebPlay {
    NSString *videoJS = @"var videos = document.getElementsByTagName('video');\
    for (var i=0;i < videos.length;i++){\
        videos[i].pause();\
    }";
    NSString *mediaJS = @"var audios = document.getElementsByTagName('media');\
    for (var i=0;i < audios.length;i++){\
        audios[i].pause();\
    }";
    [self.wkWebView evaluateJavaScript:videoJS completionHandler:nil];
    [self.wkWebView evaluateJavaScript:mediaJS completionHandler:nil];
}

- (void)setConfig:(JQConfig *)config {
    _config = config;
    [self.progressView removeFromSuperview];
    [self.loadingView removeFromSuperview];
    [self.refreshControl removeFromSuperview];
    if (self.config) {
        if (self.config.indicatorType == Progress) {
            [self addSubview:self.progressView];
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake(0, 0, 0, 3);
            layer.backgroundColor = config.progressColor.CGColor;
            [self.progressView.layer addSublayer:layer];
            self.progresslayer = layer;
            
        } else if(self.config.indicatorType == Activity) {
            [self addSubview:self.loadingView];
        }
    }
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    if (config.scriptMessageNames) {
        JQWeakScriptMessageDelegate *weakScriptMessageDelegate = [[JQWeakScriptMessageDelegate alloc]initWithDelegate:self];
        for (NSString *jsName in config.scriptMessageNames) {
             [userContentController addScriptMessageHandler:weakScriptMessageDelegate name:[NSString stringWithFormat:@"%@", jsName]];
         }
    }
    if (config.cookieSource) {
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:config.cookieSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
    }
    self.wkConfig.userContentController = userContentController;
    if (config.userAgent) {
        [self setUserAgent:config.userAgent];
    }
    if (config.isNeedPullDownRefresh) {
        [self.wkWebView.scrollView addSubview:self.refreshControl];
    }
}

- (void)loadRequest:(NSMutableURLRequest *) request {
    // 解决首次加载Cookie带不上问题
    [self.wkWebView loadRequest:[self fixRequest:request]];
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL {
    [self.wkWebView loadHTMLString:string baseURL:baseURL];
}

- (void)reload {
    [self.wkWebView reload];
}

- (void)reloadFromOrigin {
    [self.wkWebView reloadFromOrigin];
}

- (void)goBack {
    if ([self canGoBack]) {
        [self.wkWebView goBack];
    }
}

- (void)goForward {
    if ([self canGoForward]) {
        [self.wkWebView goForward];
    }
}

- (BOOL)canGoForward {
    return [self.wkWebView canGoForward];
}

- (BOOL)canGoBack {
    return [self.wkWebView canGoBack];
}

- (void)callJS:(NSString *)jsMethod handler:(void (^)(id response, NSError *error))handler {
    [self.wkWebView evaluateJavaScript:jsMethod completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response,error);
        }
    }];
}

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name {
    [self.wkConfig.userContentController removeScriptMessageHandlerForName:name];
}

 /** 清除所有缓存（cookie除外） */
- (void)clearWebCacheFinish:(void(^)(BOOL finish,NSError *error))block {
    [WKWebViewCacheTool clearWebCacheFinish:block];
}

- (void)setupBridge {
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.wkWebView];
    [_bridge setWebViewDelegate:self];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler _Nullable)handler {
    [_bridge registerHandler:handlerName handler:handler];
    if (handlerName && ![handlerName isKindOfClass:[NSNull class]] && ![self.handlerNames containsObject:handlerName]) {
        [self.handlerNames addObject:[NSString stringWithFormat:@"%@", handlerName]];
    }
}

- (void)removeHandler:(NSString*)handlerName {
    [_bridge removeHandler:handlerName];
    if (handlerName && ![handlerName isKindOfClass:[NSNull class]] && ![self.handlerNames containsObject:handlerName]) {
        [self.handlerNames removeObject:[NSString stringWithFormat:@"%@", handlerName]];
    }
}

- (void)reset {
    [_bridge reset];
}

- (void)callHandler:(NSString*)handlerName data:(id _Nullable)data responseCallback:(WVJBResponseCallback _Nullable)responseCallback {
    [_bridge callHandler:handlerName data:data responseCallback:responseCallback];
}

/*!
 *  更新webView的cookie 解决后续Ajax请求Cookie丢失问题
 */
- (void)updateWebViewCookie {
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:[self cookieString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    // 添加Cookie
    [self.wkConfig.userContentController addUserScript:cookieScript];
}

- (WKWebView *)getWKWebView {
    return self.wkWebView;
}

#pragma mark - Private methods
- (void)setupUI {
    if (@available(iOS 11.0, *)) {
        self.wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        if ([self findViewController]) {
            [self findViewController].automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    [self addSubview:self.wkWebView];
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (UIViewController *)findViewController {
    id target=self;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]])
            break;
    }
    return target;
}

- (void)startLoading {
    if (_loadingView) {
        [_loadingView startAnimating];
        _loadingView.hidden = NO;
    }
}

- (void)stopLoding {
    if (_loadingView) {
        [_loadingView stopAnimating];
        _loadingView.hidden = YES;
    }
}

/**
 修复打开链接Cookie丢失问题

 @param request 请求
 @return 一个fixedRequest
 */
- (NSURLRequest *)fixRequest:(NSURLRequest *)request {
    NSMutableURLRequest *fixedRequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        fixedRequest = (NSMutableURLRequest *)request;
    } else {
        fixedRequest = request.mutableCopy;
    }
    //防止Cookie丢失
    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    if (dict.count) {
        NSMutableDictionary *mDict = request.allHTTPHeaderFields.mutableCopy;
        [mDict setValuesForKeysWithDictionary:dict];
        fixedRequest.allHTTPHeaderFields = mDict;
    }
    return fixedRequest;
}

- (NSString *)cookieString {
    NSMutableString *script = [NSMutableString string];
    [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        // Create a line that appends this cookie to the web view's document's cookies
        [script appendFormat:@"if (cookieNames.indexOf('%@') == -1) { document.cookie='%@'; };\n", cookie.name, cookie.da_javascriptString];
    }
    return script;
}

#pragma mark - Event refresh
- (void) refresh {
    [self reload];
    [self.refreshControl endRefreshing];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        self.progresslayer.opacity = 1;
        //不要让进度条倒着走...有时候goback会出现这种情况
        if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) {
            return;
        }
        self.progresslayer.frame = CGRectMake(0, 0, self.bounds.size.width * [change[@"new"] floatValue], 3);
        if ([change[@"new"] floatValue] == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progresslayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progresslayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    } else if(object == self.wkWebView && [keyPath isEqual:@"scrollView.contentSize"]) {
        UIScrollView *scrollView = self.wkWebView.scrollView;
        if (self.contentHeightBlock && !self.wkWebView.isLoading) {
            self.contentHeightBlock(scrollView.contentSize.height);
        }
    } else if (object == self.wkWebView && [keyPath isEqualToString:@"title"]) {
       if (self.titleChangeBlock) {
            self.titleChangeBlock(self.wkWebView.title);
        }
    } else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(jqwebView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.UIDelegate jqwebView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              completionHandler();
                                                          }]];
        [[self findViewController] presentViewController:alertController animated:YES completion:^{}];
    }

}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(jqwebView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.UIDelegate jqwebView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                  message:nil
                                                                           preferredStyle:UIAlertControllerStyleAlert];
         [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               completionHandler(YES);
                                                           }]];
         [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction *action){
                                                               completionHandler(NO);
                                                           }]];
         [[self findViewController] presentViewController:alertController animated:YES completion:^{}];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(jqwebView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
        [self.UIDelegate jqwebView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = defaultText;
        }];
        [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(alertController.textFields.count > 0) {
                completionHandler(alertController.textFields[0].text?:@"");
            } else {
                completionHandler(@"");
            }
        }])];
        [[self findViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(jqwebView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)]) {
        return [self.UIDelegate jqwebView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    } else {
        // 会拦截到window.open()事件
        if (!navigationAction.targetFrame.isMainFrame) {
            // 这里不打开新窗口
            [webView loadRequest:[self fixRequest:navigationAction.request]];
        }
        return nil;
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self startLoading];
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqWebView:didStartProvisionalNavigation:)]) {
        [self.navigationDelegate jqWebView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self stopLoding];
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqwebView:didCommitNavigation:)]) {
        [self.navigationDelegate jqwebView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{

    if (self.config.isShowLog) {
        NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    }
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqWebView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.navigationDelegate jqWebView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.config.isShowLog) {
        NSLog(@"%@",navigationAction.request.URL.absoluteString);
    }
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [[URL scheme] lowercaseString];
    UIApplication *app = [UIApplication sharedApplication];

    //解决Cookie丢失问题
    NSURLRequest *originalRequest = navigationAction.request;
    [self fixRequest:originalRequest];
    //如果originalRequest就是NSMutableURLRequest, originalRequest中已添加必要的Cookie，可以跳转
    
#pragma clang diagnostic pop
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqWebView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.navigationDelegate jqWebView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        // tel sms mailto
        if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"sms"] || [scheme isEqualToString:@"mailto"]) {
            if ([app canOpenURL:URL]) {
                [app openURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }

        // appstore
        if ([URL.absoluteString containsString:@"itunes.apple.com"]) {
          if ([app canOpenURL:URL]) {
             [app openURL:URL];
             decisionHandler(WKNavigationActionPolicyCancel);
             return;
          }
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self stopLoding];
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqWebView:didFailProvisionalNavigation:withError:)]) {
        [self.navigationDelegate jqWebView:webView didFailProvisionalNavigation:navigation withError:error];
    }
    /*
     if(error.code == NSURLErrorCancelled)  {
         return;
     }
     if (error.code == NSURLErrorUnsupportedURL) {
         return;
     }
     */
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
     [self stopLoding];
    if ([webView.URL.absoluteString.lowercaseString isEqualToString:@"about:blank"]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [webView.backForwardList performSelector:NSSelectorFromString(@"_removeAllItems")];
#pragma clang diagnostic pop

    }
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // [result doubleValue]
        if (self.contentHeightBlock) {
            self.contentHeightBlock([result doubleValue]);
        }
    }];
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqWebView:didFinishNavigation:)]) {
        [self.navigationDelegate jqWebView:webView didFinishNavigation:navigation];
    }
}

// //web内存过大，进程终止，重新加载webView
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqwebViewWebContentProcessDidTerminate:)]) {
        [self.navigationDelegate jqwebViewWebContentProcessDidTerminate:webView];
    } else {
        [self.wkWebView reload];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {

    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(jqwebView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.navigationDelegate jqwebView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, card);
        }
    }
}
 
#pragma mark - js send data
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.jsSendDataBlock) {
         self.jsSendDataBlock(message.name, message.body);
     }
}

#pragma mark - Setter & Getter
- (void)setUserAgent:(NSString *)userAgent {
    if (@available(iOS 12.0, *)){
        NSString *baseAgent = [_wkWebView valueForKey:@"applicationNameForUserAgent"];
        NSString *tuserAgent = [NSString stringWithFormat:@"%@ %@",baseAgent,userAgent];
        [self.wkWebView setValue:tuserAgent forKey:@"applicationNameForUserAgent"];
    }
    [self.wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *newUA = [NSString stringWithFormat:@"%@ %@",result,userAgent];
        self->_wkWebView.customUserAgent = newUA;
    }];
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero];
        _wkWebView.opaque = NO;
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
    }
    return _wkWebView;
}

- (WKWebViewConfiguration *)wkConfig {
    if (!_wkConfig) {
        _wkConfig = [[WKWebViewConfiguration alloc]init];
        _wkConfig.allowsInlineMediaPlayback = YES;
        //_wkConfig.preferences.minimumFontSize = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _wkConfig.mediaPlaybackRequiresUserAction = NO;
#pragma clang diagnostic pop
        _wkConfig.preferences.javaScriptEnabled = YES;
        _wkConfig.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        _wkConfig.suppressesIncrementalRendering = YES; // 是否支持记忆读取
        [_wkConfig.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        if (@available(iOS 10.0, *)) {
          [_wkConfig setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
        }
        
    }
    return _wkConfig;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        if (@available(iOS 13.0, *)) {
            _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
    return _loadingView;;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc]init];
        _progressView.backgroundColor = [UIColor clearColor];
    }
    return _progressView;
}

- (NSMutableArray *)handlerNames {
    if (!_handlerNames) {
        _handlerNames = [NSMutableArray array];
    }
    return _handlerNames;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        _refreshControl = refreshControl;
    }
    return _refreshControl;
}

@end
