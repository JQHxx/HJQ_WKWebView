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

@interface JQConfig : NSObject

/**
 * custom userAgent default ""
 */
@property (nonatomic, copy) NSString *userAgent;

/**
 * js
 */
@property (nonatomic, strong) NSArray *scriptMessageNames;

/**
 * Indicator style
 */
@property (nonatomic, assign) IndicatorType indicatorType;

/**
 *  progressColor
 */
@property (strong, nonatomic) UIColor *progressColor;

/**
*  ajax  set cookie
*/
@property (nonatomic, copy) NSString *cookieSource;

@end

NS_ASSUME_NONNULL_END
