//
//  WKWebViewCacheTool.h
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/11.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewCacheTool : NSObject

/** 清除webView缓存 */
+ (void)clearWebCacheFinish:(void(^)(BOOL finish,NSError *error))block;

/** 清理缓存的方法，这个方法会清除缓存类型为HTML类型的文件*/
+ (void)clearHTMLCache;

@end

NS_ASSUME_NONNULL_END
