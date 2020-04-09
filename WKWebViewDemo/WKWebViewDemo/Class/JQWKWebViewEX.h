//
//  NSObject+JQWKWebViewEX.h
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/9.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JQWKWebViewEX)

// 拼接内容格式
- (NSString *)splicingHTML;

// 变成转义字符
- (NSString *)escapeHTML;

// 去除转义符，变成普通的标签<>
- (NSString *) unescapeHTML;


@end

NS_ASSUME_NONNULL_END
