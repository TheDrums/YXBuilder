//
//  JZYHDictionary.h
//  HBuilder-Hello
//
//  Created by Lu_jh on 15/8/28.
//  Copyright (c) 2015年 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  enum JZYHStatus
{
    statusOK,
    statusError
}JSCallbackStatus;
@interface JZYHDictionary : NSDictionary
/*
 *创建晋中银行插件返回js的结果类
 *params
 * status :状态
 stResult: 结果
 stMessage:错误信息
 **/
+(NSDictionary *)jzyhDictionaryWithStatus:(JSCallbackStatus)status withResult:(NSDictionary *)stResult withMessage:(NSString *)stMessage;
+(NSDictionary *)jzyhStringWithStatus:(JSCallbackStatus)status withResult:(NSString *)stResult withMessage:(NSString *)stMessage;
@end
