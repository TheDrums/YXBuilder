//
//  PGMD5Plugin.m
//  YXBuilder
//
//  Created by LiYuan on 2017/11/9.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "PGMD5Plugin.h"
#import "JZYHDictionary.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
typedef void (^WVJBResponseCallback)(id responseData);
@implementation PGMD5Plugin

WVJBResponseCallback callBack;

- (instancetype)init {
    self = [super init];
    [self encrypt];
    
    return self;
}

#pragma mark - private method
- (void)encrypt
{
    // 注册的handler 是供JS调用Native 使用的
#warning todo 类和plugin的匹配/keepCallback
    [self.webViewBridge registerHandler:@"pluginMD5.encrypt" handler:^(id data, WVJBResponseCallback responseCallback) {
        // data 的类型与 JS中传的参数有关
        NSString *clearText = [(NSArray *)data firstObject];
        NSDictionary *resultDic = [NSDictionary dictionary];
        if (clearText.length > 0) {
            NSString *cipherText = [self md5EncryptUpper:clearText];
            
            resultDic = [JZYHDictionary jzyhDictionaryWithStatus:statusOK withResult:[NSDictionary dictionaryWithObject:cipherText forKey:@"cipherText"] withMessage:@"加密成功"];
        } else {
            
            resultDic = [JZYHDictionary jzyhDictionaryWithStatus:statusError withResult:nil withMessage:@"传输值为空"];
        }
        
        // 将结果返回给js
        responseCallback(resultDic);
//        callBack = responseCallback;
        
        // 通过代理回调仍走block
//        typedef void (^WVJBResponseCallback)(id responseData);
//        WVJBResponseCallback callBack;
//        callBack = responseCallback;
//        callBack(resultDic);
    }];
}

- (NSString *)md5EncryptUpper:(NSString *)text {
    
    if (self == NULL) {
        return NULL;
    }
    const char *cStr = [text UTF8String];
    unsigned char result[16];
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    CC_MD5( cStr,[num intValue], result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
}

@end
