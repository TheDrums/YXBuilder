//
//  ViewController.m
//  test
//
//  Created by LiYuan on 2017/11/9.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "PGPlugin.h"

#define messageDic [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Pandora/www/yuconfig.json"]] options:NSJSONReadingMutableLeaves error:nil]

@interface ViewController () <WKUIDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initWKWebView];
}

- (NSString *)releaseToPath {
    
    // 移动www路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *basePath = [documentsDirectory stringByAppendingPathComponent:@"www"];
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"Pandora/www" ofType:@""];
    
    [fileManager removeItemAtPath:basePath error:nil];
    [fileManager copyItemAtPath:resourcePath toPath:basePath error:&error];
    
    return basePath;
}

- (void)initWKWebView {
    NSString *basePath = [self releaseToPath];
    
    NSString *launch_path = [messageDic objectForKey:@"launch_path"];
    NSString *htmlString = [NSString stringWithContentsOfFile:[basePath stringByAppendingPathComponent:launch_path] encoding:NSUTF8StringEncoding error:NULL];
    
    // 加载www文件
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    
    configuration.preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    configuration.preferences.minimumFontSize = 30;
    //是否支持JavaScript
    configuration.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20) configuration:configuration];
    [webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:basePath isDirectory:YES]];
    webView.UIDelegate = self;
    
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:webView];
    
    // 注册插件类
    [self initwebViewBridge:webView];
}

- (void)initwebViewBridge:(WKWebView *)webView {
    [PGPlugin setWebView:webView rootViewController:self];
    [PGPlugin registPlugin];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

