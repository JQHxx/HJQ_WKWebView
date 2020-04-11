//
//  NSObject+JQWKWebViewEX.h
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/9.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JQImageBlock)(id data);

@interface NSString (JQWKWebViewEX)

// 拼接内容格式
- (NSString *)splicingHTML;

// 变成转义字符
- (NSString *)escapeHTML;

// 去除转义符，变成普通的标签<>
- (NSString *)unescapeHTML;

@end

@interface WKWebView (Images)

@property (nonatomic, copy) JQImageBlock imageBlock;

- (void) addTapImageGesture:(JQImageBlock) imageBlock;

- (void) addLongTapImageGesture:(JQImageBlock) imageBlock;

- (void) addTapImagesGesture:(JQImageBlock) imageBlock;

@end

NS_ASSUME_NONNULL_END
