//
//  NSObject+JQWKWebViewEX.m
//  WKWebViewDemo
//
//  Created by OFweek01 on 2020/4/9.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "JQWKWebViewEX.h"

@implementation NSString (JQWKWebViewEX)

- (NSString *)splicingHTML {
    
    NSMutableString *string = [[NSMutableString alloc]init];
    [string appendString:@"<html>"];
    [string appendString:@"<head>"];
    [string appendString:@"<meta charset='utf-8' />"];
    [string appendString:@"<meta name='apple-mobile-web-app-capable' content='yes'>"];
    [string appendString:@"<meta name='apple-mobile-web-app-status-bar-style' content='black'>"];
    [string appendString:@"<meta name='viewport' content='width=device-width,initial-scale=1, minimum-scale=1.0, maximum-scale=1, user-scalable=no'>"];
    [string appendString:@"</head>"];
    [string appendString:@"<body id='cont' >"];
    [string appendFormat:@"%@", self];
    [string appendString:@"</body>"];
    [string appendString:@"</html>"];
    
    [string appendString:@"<script type='text/javascript'>"];
    [string appendString:@"window.onload=function(){"];
    [string appendString:@"var src=document.getElementsByTagName('img');"];
    [string appendString:@"var width = document.body.clientWidth;"];
    [string appendString:@"for (var i=0; i<src.length; i++) {"];
    [string appendString:@"var imageh = src[i].naturalHeight;"];
    [string appendString:@"if(src[i].naturalWidth > width){"];
    [string appendString:@"src[i].setAttribute('width','100%');"];
    [string appendString:@"var imagew = src[i].naturalWidth;"];
    [string appendString:@"var contentH = width * imageh / imagew;"];
    [string appendString:@"src[i].setAttribute('height',contentH + 'px');"];
    [string appendString:@"}"];
    [string appendString:@"src[i].setAttribute('style','margin-top:0px;');}}"];
    [string appendString:@"</script>"];

    return string;
}

- (NSString *) escapeHTML {
    NSMutableString *s = [NSMutableString string];
    
    NSUInteger start = 0;
    NSUInteger len = [self length];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
    
    while (start < len) {
        NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
        if (r.location == NSNotFound) {
            [s appendString:[self substringFromIndex:start]];
            break;
        }
        
        if (start < r.location) {
            [s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
        }
        
        switch ([self characterAtIndex:r.location]) {
            case '<':
                [s appendString:@"&lt;"];
                break;
            case '>':
                [s appendString:@"&gt;"];
                break;
            case '"':
                [s appendString:@"&quot;"];
                break;
            case '&':
                [s appendString:@"&amp;"];
                break;
        }
        
        start = r.location + 1;
    }
    
    return s;
}


- (NSString *) unescapeHTML {
    NSMutableString *s = [[NSMutableString alloc] init];
    NSMutableString *target = [self mutableCopy];
    NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    
    while ([target length] > 0) {
        NSRange r = [target rangeOfCharacterFromSet:chs];
        if (r.location == NSNotFound) {
            [s appendString:target];
            break;
        }
        
        if (r.location > 0) {
            [s appendString:[target substringToIndex:r.location]];
            [target deleteCharactersInRange:NSMakeRange(0, r.location)];
        }
        
        if ([target hasPrefix:@"&lt;"]) {
            [s appendString:@"<"];
            [target deleteCharactersInRange:NSMakeRange(0, 4)];
        } else if ([target hasPrefix:@"&gt;"]) {
            [s appendString:@">"];
            [target deleteCharactersInRange:NSMakeRange(0, 4)];
        } else if ([target hasPrefix:@"&quot;"]) {
            [s appendString:@"\""];
            [target deleteCharactersInRange:NSMakeRange(0, 6)];
        } else if ([target hasPrefix:@"&#39;"]) {
            [s appendString:@"'"];
            [target deleteCharactersInRange:NSMakeRange(0, 5)];
        }else if ([target hasPrefix:@"&#039;"]) {
            [s appendString:@"'"];
            [target deleteCharactersInRange:NSMakeRange(0, 6)];
        } else if ([target hasPrefix:@"&amp;"]) {
            [s appendString:@"&"];
            [target deleteCharactersInRange:NSMakeRange(0, 5)];
        } else if ([target hasPrefix:@"&hellip;"]) {
            [s appendString:@"…"];
            [target deleteCharactersInRange:NSMakeRange(0, 8)];
        } else {
            [s appendString:@"&"];
            [target deleteCharactersInRange:NSMakeRange(0, 1)];
        }
    }
    
    return s;
}

@end
