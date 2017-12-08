//
//  JZYHDictionary.m
//  HBuilder-Hello
//
//  Created by Lu_jh on 15/8/28.
//  Copyright (c) 2015年 DCloud. All rights reserved.
//

#import "JZYHDictionary.h"

@implementation JZYHDictionary
+(NSDictionary *)jzyhDictionaryWithStatus:(JSCallbackStatus)status withResult:(NSDictionary *)stResult withMessage:(NSString *)stMessage
{
    if(nil == stResult)
    {
        stResult = nil;
    }
    if(nil == stMessage)
    {
        stMessage = @"";
    }
    NSDictionary *dictonary = [NSDictionary dictionaryWithObjectsAndKeys:statusOK == status?@"true":@"false",@"status",stMessage,@"message",stResult,@"payload", nil];
    return dictonary;
}

+(NSDictionary *)jzyhStringWithStatus:(JSCallbackStatus)status withResult:(NSString *)stResult withMessage:(NSString *)stMessage
{
    if(nil == stResult)
    {
        stResult = @"";
    }
    if(nil == stMessage)
    {
        stMessage = @"";
    }
    NSDictionary *dictonary = [NSDictionary dictionaryWithObjectsAndKeys:statusOK == status?@"true":@"false",@"status",stMessage,@"message",stResult,@"payload", nil];
    return dictonary;
}

@end
