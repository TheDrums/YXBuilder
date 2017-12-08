//
//  PGPlugin.h
//  YXBuilder
//
//  Created by LiYuan on 2017/11/9.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWebViewJavascriptBridge.h"

@interface PGPlugin : NSObject

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) UIViewController *rootViewController;

@property (strong, nonatomic) WKWebViewJavascriptBridge *webViewBridge;

+ (void)setWebView:(WKWebView *)webView rootViewController:(UIViewController *)rootViewController;

+ (void)registPlugin;

@end
