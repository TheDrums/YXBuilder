//
//  HBuilderJZYHGlobal.h
//  HBuilder-Hello
//
//  Created by Lu_jh on 15/8/24.
//  Copyright (c) 2015年 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
// 只有定义了DEBUG宏的情况下才输出日志
#ifdef DEBUG

#   define YYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#   define YYLog(...)

#endif

#define YY_LIBRARYPATH [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define IOS7  [[[UIDevice currentDevice] systemVersion] floatValue]
#define SYSTEMURL @"http://172.20.38.104:7001/mobileServer/"
#define REFRESH @"/refresh"
#define TIME_OUT_SEC 10

@interface HBuilderJZYHGlobal : NSObject

@end

