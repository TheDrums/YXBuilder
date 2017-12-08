//
//  PGPlugin.m
//  YXBuilder
//
//  Created by LiYuan on 2017/11/9.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "PGPlugin.h"

static WKWebView *staticWKWebView;
static UIViewController *staticRootViewController;
static WKWebViewJavascriptBridge *staticWebViewBridge;

#define messageDic [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Pandora/www/yuconfig.json"]] options:NSJSONReadingMutableLeaves error:nil]

@implementation PGPlugin

+ (void)setWebView:(WKWebView *)webView rootViewController:(UIViewController *)rootViewController {
    staticWKWebView = webView;
    staticRootViewController = rootViewController;
}

+ (void)registPlugin {
//    [WKWebViewJavascriptBridge enableLogging];
    staticWebViewBridge = [WKWebViewJavascriptBridge bridgeForWebView:staticWKWebView];
    [staticWebViewBridge setWebViewDelegate:self];
    
    NSDictionary *permission = [messageDic objectForKey:@"permissions"];
    for (NSString *plugin in [permission allKeys]) {
        Class cls = NSClassFromString(plugin);
        SEL sel = NSSelectorFromString(@"new");
        id subPlugin = [(id)cls performSelector:sel];
        
        SEL registerHandler = NSSelectorFromString(@"registerHandler:");
        [subPlugin performSelector:registerHandler withObject:[permission objectForKey:plugin]];
    }
}

- (WKWebView *)webView {
    return staticWKWebView;
}

- (UIViewController *)rootViewController {
    return staticRootViewController;
}

- (WKWebViewJavascriptBridge *)webViewBridge {
    return staticWebViewBridge;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlstring = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];// 解码
    NSLog(@"url = >%@",urlstring);
    if (urlstring) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
}

@end
