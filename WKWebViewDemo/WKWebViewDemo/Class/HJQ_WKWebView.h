//
//  HJQ_WKWebView.h
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HJQ_Config.h"

NS_ASSUME_NONNULL_BEGIN

@interface HJQ_WKWebView : UIView

// message.name，message.body
@property (nonatomic, copy) void(^jsActionBlock)(NSString *name, id body);

@property (nonatomic, copy) void(^finishLoadBlock)(void);

@property (nonatomic, copy) void(^titleBlock)(NSString *title);

@property (nonatomic, copy) void(^contentHeightBlock)(double height);

- (void) setConfig: (HJQ_Config*)config;

- (void) refresh;

- (BOOL) canGoBack;

- (void) goBack;

- (void) pauseWebPlay;

- (WKWebView *) getWKWebView;

- (void) evaluateJavaScript: (NSString *) js;

@end

NS_ASSUME_NONNULL_END
