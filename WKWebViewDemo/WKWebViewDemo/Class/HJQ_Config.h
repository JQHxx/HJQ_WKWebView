//
//  HJQ_Config.h
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    None = 0,
    Activity,
    Progress,
} IndicatorType;

@interface HJQ_Config : NSObject

/**
 * 自定义的UA，默认为""
 */
@property (nonatomic, copy) NSString *userAgent;

/**
 * js
 */
@property (nonatomic, strong) NSArray *scriptMessageNames;

/**
* 相关请求
 * 添加请求头 [webRequest setValue:value forHTTPHeaderField:key];
*/
@property (nonatomic, strong) NSMutableURLRequest *request;

/**
 * 进度条样式
 */
@property (nonatomic, assign) IndicatorType indicatorType;

/**
 *  进度条的颜色
 */
@property (strong, nonatomic) UIColor *progressColor;

/**
 *  进度条的颜色
 */
@property (assign, nonatomic) BOOL isConfigMeta;

@end

NS_ASSUME_NONNULL_END
