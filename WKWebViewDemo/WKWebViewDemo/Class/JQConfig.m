//
//  HJQ_Config.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/8.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "JQConfig.h"

@implementation JQConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.progressColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:.8];;
    }
    return self;
}

@end
