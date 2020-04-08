//
//  HJQ_WKWebView.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "HJQ_WKWebView.h"
#import <objc/runtime.h>
#import "HJQ_WeakScriptMessageDelegate.h"

@interface HJQ_WKWebView() <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) CALayer *progresslayer;
@property (nonatomic, strong) WKWebViewConfiguration *wkConfig;
@property (nonatomic, strong) HJQ_Config *config;

@end

@implementation HJQ_WKWebView

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
// 暂停浏览器播放
- (void) pauseWebPlay {
    NSString *videoJS = @"var videos = document.getElementsByTagName('video');\
    for (var i=0;i < videos.length;i++){\
        videos[i].pause();\
    }";
    NSString *mediaJS = @"var audios = document.getElementsByTagName('media');\
    for (var i=0;i < audios.length;i++){\
        audios[i].pause();\
    }";
    [self.wkWebView evaluateJavaScript:videoJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
    
    [self.wkWebView evaluateJavaScript:mediaJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
}

- (void) setConfig: (HJQ_Config*)config {
    _config = config;
    if (self.config) {
        if (self.config.indicatorType == Progress) {
            [self.progressView removeFromSuperview];
            [self addSubview:self.progressView];
            CALayer *layer = [CALayer layer];
            layer.frame = CGRectMake(0, 0, 0, 3);
            layer.backgroundColor = config.progressColor.CGColor;
            [self.progressView.layer addSublayer:layer];
            self.progresslayer = layer;
            
        } else if(self.config.indicatorType == Activity) {
            [self.loadingView removeFromSuperview];
            [self addSubview:self.loadingView];
        }
    }

    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    if (config.isConfigMeta) {
         [userContentController addUserScript:wkUScript];
    }
    if (config.scriptMessageNames) {
        for (NSString *jsName in config.scriptMessageNames) {
             [userContentController addScriptMessageHandler:[[HJQ_WeakScriptMessageDelegate alloc]initWithDelegate:self] name:[NSString stringWithFormat:@"%@", jsName]];
         }
    }
    self.wkConfig.userContentController = userContentController;
    [self setUserAgent:config.userAgent?:@""];
    if (config.request) {
        [self.wkWebView loadRequest:config.request];
    }
}

- (void) refresh {
    if (self.config.request) {
        [self.wkWebView loadRequest:self.config.request];
    }
}

- (void) goBack {
    [self.wkWebView goBack];
}

- (BOOL) canGoBack {
    return [self.wkWebView canGoBack];
}

- (void) evaluateJavaScript: (NSString *) js {
    [self.wkWebView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
}

- (WKWebView *)getWKWebView {
    return self.wkWebView;
}

#pragma mark - Private methods
- (void) setupUI {
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
        if (self.contentHeightBlock) {
            self.contentHeightBlock(scrollView.contentSize.height);
        }
    } else if (object == self.wkWebView && [keyPath isEqualToString:@"title"]) {
       if (self.titleBlock) {
            self.titleBlock(self.wkWebView.title);
        }
    } else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // js 里面的alert实现，如果不实现，网页的alert函数无效
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

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
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

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
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

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self startLoading];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self stopLoding];
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{

    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
     NSURL *URL = navigationAction.request.URL;
        NSString *scheme = [URL scheme];
        UIApplication *app = [UIApplication sharedApplication];
        // 打电话
        if ([scheme isEqualToString:@"tel"]) {
            if ([app canOpenURL:URL]) {
                [app openURL:URL];
                // 一定要加上这句,否则会打开新页面
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
       // 打开appstore
       if ([navigationAction.request.URL.absoluteString containsString:@"itunes.apple.com"]) {
          if ([app canOpenURL:navigationAction.request.URL]) {
             [app openURL:navigationAction.request.URL];
             decisionHandler(WKNavigationActionPolicyCancel);
              return;
          }
       }
#pragma clang diagnostic pop
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self stopLoding];
     if(error.code == NSURLErrorCancelled)  {
         return;
     }
     if (error.code == NSURLErrorUnsupportedURL) {
         return;
     }
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self stopLoding];
    if (self.finishLoadBlock) {
        self.finishLoadBlock();
    }
    // 计算WKWebView高度
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // [result doubleValue]
        if (self.contentHeightBlock) {
            self.contentHeightBlock([result doubleValue]);
        }
    }];
}

#pragma mark - 加载JS处理
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (_jsActionBlock) {
         _jsActionBlock(message.name, message.body);
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
        // 支持在线音频视频播放
        _wkConfig.allowsInlineMediaPlayback = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 允许自动播放
        _wkConfig.mediaPlaybackRequiresUserAction = NO;
#pragma clang diagnostic pop
        
    }
    return _wkConfig;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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

@end
