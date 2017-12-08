//
//  NSString+SM.h
//  财企平台
//
//  Created by LiYuan on 16/7/20.
//  Copyright © 2016年 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YX)

- (instancetype)md5Encrypt;// 通用16位 小写
- (instancetype)md5EncryptUpper;// 32位 大写
+ (instancetype)fileMD5:(NSString*)path;
- (instancetype)DES3EncryptWithKeyString:(NSString *)keyString;
- (instancetype)AESEncryptWithKeyString:(NSString *)keyString;
- (instancetype)RSAEencryptWithKey_e:(NSString *)key_e andKey_n:(NSString *)key_n;
- (instancetype)SM2EencryptWithX:(NSString *)X andY:(NSString *)Y;
- (instancetype)SM3Encrypt;
- (instancetype)SM4EncryptWithKey:(NSString *)aKey;
- (instancetype)SM2SignatureWithPublicKeyX:(NSString *)pubKeyX andPublicKeyY:(NSString *)pubKeyY;




- (instancetype)DES3DecryptWithKeyString:(NSString *)keyString;
- (NSMutableDictionary *)SM3EncryptAndSM2SignatureWithPrivateKey:(NSString *)priKey;
+ (instancetype)publicKeyX;
+ (instancetype)publicKeyY;
+ (instancetype)secureKey;
- (instancetype)SM2DecryptWithLength:(int)length andKey:(NSString *)key;
- (instancetype)SM4DecryptWithLength:(int)length andKey:(NSString *)aKey;
- (instancetype)SM2CheckSignature:(NSString *)sig WithPublicKeyX:(NSString *)pubKeyX andPublicKeyY:(NSString *)pubKeyY;
- (instancetype)AESDecryptWithKeyString:(NSString *)keyString iv:(NSString *)iv;
- (instancetype)RSADencrypt;
- (instancetype)checkJsonStringOfProjectLicense:(NSString *)licenseName;

@end
