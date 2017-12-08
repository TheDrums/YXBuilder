//
//  NSString+SM.m
//  财企平台
//
//  Created by LiYuan on 16/7/20.
//  Copyright © 2016年 DCloud. All rights reserved.
//

#import "NSString+YX.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "ec.h"
#include "SM2.h"
#include "part4.h"
#include "sm3_.h"
#include "sm4.h"
#include "bn.h"
#include "rand.h"
#include "err.h"
#include "ecdsa.h"
#include "ecdh.h"

#include "part2.h"

#include "rsa.h"
#include "bio.h"
#include "pem.h"

#include "evp.h"
#include "conf.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#define MSG_LEN (128+1)
#define MD5_LEN 16
#define MD5_LEN_UPPER 32
#define KEY_LEN 32
#define CHUNK_SIZE 256
#define gIv @"01234567"

#pragma comment(lib,"libeay32.lib")

#define ABORT_ do { \
fflush(stdout); \
fprintf(stderr, "%s:%d: ABORT_\n", __FILE__, __LINE__); \
ERR_print_errors_fp(stderr); \
exit(1); \
} while (0)

#define AES_BITS 128
#define MSG_LEN 128
unsigned char *byteArrayToString(unsigned char *data, int dataLen);
unsigned char* base64Decode(const char* source, const int sourceLength);
unsigned char* base64Encode(const char* source, const int sourceLength);
RSA * GenerateRSAKey();
#define CBUFF_LEN 1024
static const char *kBase64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (YX)

/*从字符串的中间截取n个字符*/
unsigned char * mid(unsigned char *dst, const char *src, int n, int m) /*n为长度，m为位置*/
{
    const char *p = src;
    unsigned char *q = dst;
    int len = strlen(src);
    if (n > len)
    n = len - m; /*从第m个到最后*/
    if (m < 0)
    m = 0; /*从第一个开始*/
    if (m > len)
    return NULL;
    p += m;
    while (n--)
    *(q++) = *(p++);
    *(q++) = '\0'; /*有必要吗？很有必要*/
    return dst;
}

/*base64编码表   */
/*base64编码表   */
char base64Alphabet[] = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
    'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
    'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0',
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};

//查找编码表里对应的索引
int IndexInAlphabet(char c) {
    int i = 0;
    for (; i < 64; ++i)
    if (c == base64Alphabet[i])
    return i;
    
    return -1;
}
/**
 *
 * base64Decode: 对base64编码后的字符串解码
 *
 * @param source: base64编码后的字符串
 * @param sourceLength: base64编码后的字符串长度
 *
 * @return: 解码后的字符串，需要调用者malloc释放
 */
unsigned char* base64Decode(const char* source, const int sourceLength) {
    unsigned int resultLength = sourceLength / 4 * 3;
    unsigned int i = 0, j = 0;
    
    unsigned char* result = (unsigned char*) malloc(resultLength + 1);
    memset(result, 0, resultLength + 1);
    
    int counts = sourceLength / 4;
    /*每4个字节进行依次转换*/
    for (i = 0; i < counts; ++i) {
        int sourceIndex = i * 4;
        int resultIndex = i * 3;
        
        int buffer[4];
        int padding = 0;
        /*首先查找相对应的索引值存入buffer，接下来的位操作对象为buffer*/
        for (j = 0; j < 4; ++j) {
            buffer[j] = IndexInAlphabet(source[sourceIndex + j]);
        }
        /*如果到达最后4个字节，更新padding值,否则padding为0*/
        if (i == counts - 1) {
            for (j = 0; j < 4; ++j) {
                if (buffer[j] == 0x40)
                padding++;
            }
        }
        
        result[resultIndex] =
        ((buffer[0] & 0x3F) << 2 | (buffer[1] & 0x30) >> 4);
        if (padding == 2)
        break;
        result[resultIndex + 1] = ((buffer[1] & 0x0F) << 4
                                   | (buffer[2] & 0x3C) >> 2);
        if (padding == 1)
        break;
        result[resultIndex + 2] =
        ((buffer[2] & 0x03) << 6 | (buffer[3] & 0x3F));
    }
    return result;
}

/**
 * @author
 * @brief base64Encode :根据传入字符串返回base64编码后的值
 *
 * @param source: 原字符串
 * @param sourceLength： 原字符串长度
 *
 * @return: base64编码后的字符串
 */
unsigned char* base64Encode(const char* source, const int sourceLength) {
    /*命名为padding不准确，不过先不改了^_^*/
    unsigned int padding = sourceLength % 3;
    unsigned int resultLength =
    sourceLength % 3 ?
    ((sourceLength) / 3 + 1) * 4 : (sourceLength) / 3 * 4;
    unsigned int i = 0, j = 0;
    
    unsigned char* result = (unsigned char*) malloc(resultLength + 1);
    memset(result, 0, resultLength + 1);
    
    unsigned char temp = 0;
    for (i = 0, j = 0; i < sourceLength; i += 3, j += 4) {
        if (i + 2 >= sourceLength) {
            result[j] = (source[i] >> 2) & 0x3F;
            if (padding == 1) {
                //这里padding实际为2
                result[j + 1] = ((source[i] & 0x03) << 4) & 0x3F;
                result[j + 2] = 0x40;
                result[j + 3] = 0x40;
                break;
            } else if (padding == 2) {
                //这里padding实际为1
                result[j + 1] = (((source[i] & 0x03) << 4)
                                 | ((source[i + 1] >> 4) & 0x0F));
                result[j + 2] = ((source[i + 1] & 0x0f) << 2) & 0x3F;
                result[j + 3] = 0x40;
                break;
            }
        }
        
        result[j] = (source[i] >> 2) & 0x3F; //最高两位要变为0
        result[j + 1] = (((source[i] & 0x03) << 4)
                         | ((source[i + 1] >> 4) & 0x0F)); //0x03（只取最低两位,其余位为0） 0x0F(只取低四位，其余位为0)
        result[j + 2] = (((source[i + 1] & 0x0f) << 2)
                         | ((source[i + 2] >> 6) & 0x03));
        result[j + 3] = (source[i + 2] & 0x3F);
    }
    
    for (j = 0; j < resultLength; ++j) {
        result[j] = base64Alphabet[result[j]];
    }
    
    return result;
}

/**
 * 16进制转换成unsigned char*
 * */
unsigned char* hextobyte_(const char *src) {
    unsigned char plaint_str[CBUFF_LEN];
    memset((char*) plaint_str, 0, sizeof(plaint_str));
    int cipher_len = strlen(src) / 2;
    
    //将加密后的字符串，16进制转换成unsigned char*
    char tempStr[(cipher_len + 1) * 2];
    memset(tempStr, 0x00, sizeof(tempStr));
    strcpy(tempStr, src);
    //LOGD("****tempStr=%s",tempStr);
    char data[cipher_len + 1];
    memset(data, 0x00, sizeof(data));
    
    int i = 0, j = 0;
    char tmph, tmpl;
    for (i = 0; i < sizeof(tempStr); i += 2) {
        tmph = ASCI_16_(tempStr[i]) << 4;
        tmpl = ASCI_16_(tempStr[i + 1]);
        //LOGD("**tmpstr=0x%x+0x%x",tmph,tmpl);
        data[j] = tmph + tmpl;
        //LOGD("****data=0x%x",data[j]);
        j++;
    }
    unsigned char *re = (unsigned char*) data;
    return re;
    
}

char ASCI_16_(char a) {
    char b;
    
    if (a >= 0x30 && a <= 0x39) {
        b = a - 0x30;
    } else if (a >= 0x41 && a <= 0x46) {
        b = a - 0x41 + 10;
    } else if (a >= 0x61 && a <= 0x66) {
        b = a - 0x61 + 10;
    }
    return b;
}

unsigned char *char2hex(unsigned char *data, int dataLen) {
    unsigned char *tmp = (unsigned char*) malloc(dataLen * 2 + 1);
    memset(tmp, 0, dataLen * 2 + 1);
    char *ptr = (char*) tmp;
    for (int i = 0; i < dataLen; i++) {
        sprintf(ptr, "%02X", data[i]);
        ptr += 2;
    }
    return tmp;
}

unsigned char *byteArrayToString(unsigned char *data, int dataLen) {
    char hex_char[] = "0123456789abcdef";
    
    unsigned char *output = (unsigned char*) malloc(dataLen * 2 + 1);
    bzero(output, dataLen * 2 + 1);
    unsigned char *ptr = output;
    for (int i = 0; i < dataLen; i++) {
        *ptr++ = hex_char[(data[i] & 0xf0) >> 4];
        *ptr++ = hex_char[(data[i] & 0x0f)];
    }
    return output;
}

//产生长度为length的随机字符串
char* genRandomString(int length) {
    int flag, i;
    char string[length];
    memset(string, 0x00, length);
    for (i = 0; i < length; i++) {
        flag = rand() % 3;
        switch (flag) {
            case 0:
            string[i] = 'A' + rand() % 25;
            
            case 1:
            string[i] = 'a' + rand() % 25;
            break;
            case 2:
            string[i] = '0' + rand() % 9;
            break;
            default:
            string[i] = 'a' + rand() % 25;
            break;
        }
    }
    
    return string;
}

- (instancetype)SM2EencryptWithX:(NSString *)X andY:(NSString *)Y {
    //    ec_param *ecp;
    //    //ecp的开辟空间p a b n
    //    ecp = ec_param_new();
    //    //ecp 给 pabn设置标准值
    //    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, 256);
    //
    //    //设置明文 这里输入一个字符串 如果输入char[]需要稍微改动
    //    message_st message_data;
    //    memset(&message_data, 0, sizeof(message_data));
    //    Byte *mingwen = (Byte *)[[self dataUsingEncoding:NSUTF8StringEncoding] bytes];
    ////    const char * mingwen = [self UTF8String];
    //    message_data.message = (BYTE *)mingwen;
    //    message_data.message_byte_length = (int)strlen((char *)message_data.message);
    //
    //    message_data.klen_bit = message_data.message_byte_length * 8;
    //
    //
    ////    int count=rand()%30+1;
    ////    char straeskeyMesg[count];
    ////    memset(straeskeyMesg,0x00,count);
    ////    memcpy(straeskeyMesg, straeskeyMsg, count);
    ////    char data[64];
    ////    for (int x=0;x<64;data[x++] = (char)('A' + (arc4random_uniform(26))));
    //    //生成随机字符串
    //    unsigned char *msg = byteArrayToString((unsigned char *)genRandomString(20), 20);
    //    //随机数 拷贝到message_data.k,实际使用时应该随机生成这个数 (BYTE *)sm2_param_k[ecp->type]
    //    sm2_hex2bin(msg, message_data.k, ecp->point_byte_length);
    //
    //    if ([X isEqualToString:[NSString publicKeyX]] && [Y isEqualToString:[NSString publicKeyY]]) {
    //
    //        sm2_ec_key *key_B;
    //        //给dp开辟空间
    //        key_B = sm2_ec_key_new(ecp);
    //        //设置私钥，把中间的值给key_b的b
    //        sm2_ec_key_init(key_B, sm2_param_d_B[ecp->type], ecp);
    //        //设置公钥
    //        BIGNUM *P_x;
    //        P_x = BN_new();
    //        Byte *publicKeyX = (Byte *)[[X dataUsingEncoding:NSUTF8StringEncoding] bytes];
    //        BN_hex2bn(&P_x, publicKeyX);
    //
    //        BIGNUM *P_y;
    //        P_x = BN_new();
    //        Byte *publicKeyY = (Byte *)[[Y dataUsingEncoding:NSUTF8StringEncoding] bytes];
    //        BN_hex2bn(&P_y, publicKeyY);
    //
    //        sm2_bn2bin(P_x, message_data.public_key.x, ecp->point_byte_length);
    //        sm2_bn2bin(P_y, message_data.public_key.y, ecp->point_byte_length);
    //    } else {
    //        return nil;
    //    }
    //
    //    //加密
    //    int length = sm2_encrypt(ecp, &message_data);
    //    ec_param_free(ecp);
    //
    //
    //
    //    NSData *cryptData = [[[NSData alloc] initWithBytes:message_data.C length:length] base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //
    //    return [[NSString alloc] initWithData:cryptData encoding:NSUTF8StringEncoding];
    
    if (X == NULL || Y == NULL || self == NULL) {
        return NULL;
    }
    
    BIGNUM *P_x;
    BIGNUM *P_y;
    int point_bit_length = 256;
    ec_param *ecp;
    sm2_ec_key *key_B;
    message_st message_data;
    
    P_x = BN_new();
    P_y = BN_new();
    //将需要加密的字符串转化为const char*类型
    const char* strpubkeyXMsg = [X UTF8String];
    const char* strpubkeyYMsg = [Y UTF8String];
    //密钥字符串转化成char*
    const char* plaintextMsg = [self UTF8String];
    ecp = ec_param_new();
    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, point_bit_length);
    key_B = sm2_ec_key_new(ecp);
    BN_hex2bn(&P_x, strpubkeyXMsg);
    BN_hex2bn(&P_y, strpubkeyYMsg);
    //用私钥和随机数导出一个公钥，实际应用时没有私钥，也就是没有这行代码，直接设置下面的公钥
    sm2_ec_key_init(key_B, sm2_param_d_B[ecp->type], ecp); //把中间的值给key_b的b
    memset(&message_data, 0, sizeof(message_data));
    //设置明文 这里输入一个字符串 如果输入char[]需要稍微改动
    message_data.message = (BYTE *) plaintextMsg;
    message_data.message_byte_length = (int) strlen(
                                                    (char *) message_data.message);
    message_data.klen_bit = message_data.message_byte_length * 8;
    //生成随机字符串
    unsigned char *  msg = byteArrayToString((unsigned char *)genRandomString(20), 20);
    sm2_hex2bin((BYTE *) (const char*)msg, message_data.k, ecp->point_byte_length);
    //设置公钥
    sm2_bn2bin(P_x, message_data.public_key.x, ecp->point_byte_length);
    sm2_bn2bin(P_y, message_data.public_key.y, ecp->point_byte_length);
    //加密
    int cncryptlength = sm2_encrypt(ecp, &message_data);
    char trueMiwen[cncryptlength];
    memset(trueMiwen, 0x00, cncryptlength);
    memcpy(trueMiwen, message_data.C, cncryptlength);
    memset(message_data.C, 0x00, 1024);
    sm2_ec_key_free(key_B);
    ec_param_free(ecp);
    
    NSData *cryptData = [[[NSData alloc] initWithBytes:trueMiwen length:cncryptlength] base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return [[NSString alloc] initWithData:cryptData encoding:NSUTF8StringEncoding];
}

- (instancetype)SM2DecryptWithLength:(int)length andKey:(NSString *)key {
    
    ec_param *ecp;
    //ecp的开辟空间p a b n
    ecp = ec_param_new();
    //ecp 给 pabn设置标准值
    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, 256);
    
    message_st message_data;
    memset(&message_data, 0, sizeof(message_data));
    //明文的长度，这个长度应该根据密文计算
    NSLog(@"%d", length);
    message_data.message_byte_length = length;
    //k的比特长度是明文长度*8
    message_data.klen_bit = message_data.message_byte_length * 8;
    
    if ([key isEqualToString:[NSString secureKey]]) {
        
        sm2_ec_key *key_B;
        //给dp开辟空间
        key_B = sm2_ec_key_new(ecp);
        //设置私钥，把中间的值给key_b的b
        sm2_ec_key_init(key_B, sm2_param_d_B[ecp->type], ecp);
        //设置私钥,解密和公钥和随机数无关
        sm2_bn2bin(key_B->d, message_data.private_key, ecp->point_byte_length);
    } else {
        return nil;
    }
    
    //给解密后的明文开辟空间
    message_data.decrypt = (BYTE *)OPENSSL_malloc(message_data.message_byte_length + 1);
    memset(message_data.decrypt, 0, message_data.message_byte_length+1);//置为0
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    Byte *miwen = (Byte *)[decodedData bytes];
    //设置密文
    for (int i = 0; i < 256; i++)
    {
        message_data.C[i] =  miwen[i];
    }
    
    sm2_decrypt(ecp, &message_data);
    
    NSString *decrypt = [NSString stringWithUTF8String:message_data.decrypt];
    
    OPENSSL_free(message_data.decrypt);
    ec_param_free(ecp);
    
    return decrypt;
}

+ (instancetype)publicKeyX {
    
    sm2_ec_key *key_B;
    ec_param *ecp;
    //ecp的开辟空间p a b n
    ecp = ec_param_new();
    //ecp 给 pabn设置标准值
    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, 256);
    //给dp开辟空间
    key_B = sm2_ec_key_new(ecp);
    //设置私钥，把中间的值给key_b的b
    sm2_ec_key_init(key_B, sm2_param_d_B[ecp->type], ecp);
    
    char *to = BN_bn2hex(key_B->P->x);
    int len1 = strlen(to);
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int j = 0; j < len1; j = j + 2)
    {
        [string appendString:[NSString stringWithFormat:@"%c", to[j]]];
        [string appendString:[NSString stringWithFormat:@"%c", to[j+1]]];
    }
    
    OPENSSL_free(to);
    
    return string;
    
}

+ (instancetype)publicKeyY {
    
    sm2_ec_key *key_B;
    ec_param *ecp;
    //ecp的开辟空间p a b n
    ecp = ec_param_new();
    //ecp 给 pabn设置标准值
    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, 256);
    //给dp开辟空间
    key_B = sm2_ec_key_new(ecp);
    //设置私钥，把中间的值给key_b的b
    sm2_ec_key_init(key_B, sm2_param_d_B[ecp->type], ecp);
    
    char *to = BN_bn2hex(key_B->P->y);
    int len1 = strlen(to);
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int j = 0; j < len1; j = j + 2)
    {
        [string appendString:[NSString stringWithFormat:@"%c", to[j]]];
        [string appendString:[NSString stringWithFormat:@"%c", to[j+1]]];
    }
    OPENSSL_free(to);
    
    return string;
    
}

+ (instancetype)secureKey {
    
    sm2_ec_key *key_B;
    ec_param *ecp;
    //ecp的开辟空间p a b n
    ecp = ec_param_new();
    //ecp 给 pabn设置标准值
    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, 256);
    //给dp开辟空间
    key_B = sm2_ec_key_new(ecp);
    //设置私钥，把中间的值给key_b的b
    sm2_ec_key_init(key_B, sm2_param_d_B[ecp->type], ecp);
    
    char *to = BN_bn2hex(key_B->d);
    int len1 = strlen(to);
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int j = 0; j < len1; j = j + 2)
    {
        [string appendString:[NSString stringWithFormat:@"%c", to[j]]];
        [string appendString:[NSString stringWithFormat:@"%c", to[j+1]]];
    }
    
    OPENSSL_free(to);
    
    return string;
}

- (instancetype)SM3Encrypt {
    if (self == NULL) {
        return NULL;
    }
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *input = (Byte *)[data bytes];
    int ilen = strlen(input);
    unsigned char output[32];
    
    sm3((unsigned char *)input, ilen, output);
    NSMutableString *sm3String = [[NSMutableString alloc] init];
    for(int i = 0; i < 32; i++)
    {
        [sm3String appendString:[NSString stringWithFormat:@"%x", output[i]]];
    }
    return sm3String;
}

- (NSMutableDictionary *)SM3EncryptAndSM2SignatureWithPrivateKey:(NSString *)priKey {
    
    unsigned char *input = [self UTF8String];
    int ilen = (int)self.length;
    unsigned char output[32];
    sm3(input, ilen, output);
    
    NSMutableString *sm3String = [[NSMutableString alloc] init];
    for(int i = 0; i < 32; i++)
    {
        [sm3String appendString:[NSString stringWithFormat:@"%x", output[i]]];
    }
    NSData *nsdata = [sm3String dataUsingEncoding:NSUTF8StringEncoding];
    Byte *dgst = (Byte *)[nsdata bytes];
    
    
    CRYPTO_set_mem_debug_functions(0, 0, 0, 0, 0);//debug
    CRYPTO_mem_ctrl(CRYPTO_MEM_CHECK_ON);//open_debug
    ERR_load_crypto_strings();//printf_debug
    
    static const char rnd_seed[] = "string to make the random number generator think it has entropy";
    RAND_seed(rnd_seed, sizeof rnd_seed);
    unsigned char *signature;
    BN_CTX *ctx = NULL;
    BIGNUM *p, *a, *b;
    EC_GROUP *group;
    EC_POINT *P, *Q, *R;
    BIGNUM *x, *y, *z;
    EC_KEY	*eckey = NULL;
    int	sig_len;
    BIGNUM *kinv, *rp,*order;
    ECDSA_SIG *ecsig = ECDSA_SIG_new();
    EC_POINT * DHPoint = NULL;
    
    CRYPTO_set_mem_debug_functions(0, 0, 0, 0, 0);
    CRYPTO_mem_ctrl(CRYPTO_MEM_CHECK_ON);
    ERR_load_crypto_strings();
    RAND_seed(rnd_seed, sizeof rnd_seed); /* or BN_generate_prime may fail */
    
    ctx = BN_CTX_new();
    if (!ctx) ABORT_;
    
    /* Curve SM2 (Chinese National Algorithm) */
    //http://www.oscca.gov.cn/News/201012/News_1197.htm
    p = BN_new();
    a = BN_new();
    b = BN_new();
    if (!p || !a || !b) ABORT_;
    group = EC_GROUP_new(EC_GFp_mont_method()); /* applications should use EC_GROUP_new_curve_GFp
                                                 * so that the library gets to choose the EC_METHOD */
    if (!group) ABORT_;
    
    //    m2 testing P256 Vetor(sm2_param_recommand)
    static const char *group_p ="FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF";
    static const char *group_a ="FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC";
    static const char *group_b ="28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93";
    static const char *group_Gx ="32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7";
    static const char *group_Gy ="BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0";
    static const char *group_n = "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123";
    
    if (!BN_hex2bn(&p, group_p)) ABORT_;
    if (1 != BN_is_prime_ex(p, BN_prime_checks, ctx, NULL)) ABORT_;
    if (!BN_hex2bn(&a, group_a)) ABORT_;
    if (!BN_hex2bn(&b, group_b)) ABORT_;
    if (!EC_GROUP_set_curve_GFp(group, p, a, b, ctx)) ABORT_;
    
    P = EC_POINT_new(group);
    Q = EC_POINT_new(group);
    R = EC_POINT_new(group);
    if (!P || !Q || !R) ABORT_;
    
    x = BN_new();
    y = BN_new();
    z = BN_new();
    if (!x || !y || !z) ABORT_;
    
    if (!BN_hex2bn(&x, group_Gx)) ABORT_;
    if (!EC_POINT_set_compressed_coordinates_GFp(group, P, x, 0, ctx)) ABORT_;
    if (!EC_POINT_is_on_curve(group, P, ctx)) ABORT_;
    if (!BN_hex2bn(&z, group_n)) ABORT_;
    if (!EC_GROUP_set_generator(group, P, z, BN_value_one())) ABORT_;
    
    if (!EC_POINT_get_affine_coordinates_GFp(group, P, x, y, ctx)) ABORT_;
    /* G_y value taken from the standard: */
    if (!BN_hex2bn(&z, group_Gy)) ABORT_;
    if (0 != BN_cmp(y, z)) ABORT_;
    
    if (EC_GROUP_get_degree(group) != 256) ABORT_;
    
    fflush(stdout);
    if (!EC_GROUP_get_order(group, z, ctx)) ABORT_;
    if (!EC_GROUP_precompute_mult(group, ctx)) ABORT_;
    if (!EC_POINT_mul(group, Q, z, NULL, NULL, ctx)) ABORT_;
    if (!EC_POINT_is_at_infinity(group, Q)) ABORT_;
    fflush(stdout);
    
    //testing ECDSA for SM2
    /* create new ecdsa key */
    if ((eckey = EC_KEY_new()) == NULL)
    return NULL;
    if (EC_KEY_set_group(eckey, group) == 0)
    {
        return NULL;
    }
    
    /* create key */
    NSData *data = [priKey dataUsingEncoding: NSUTF8StringEncoding];
    Byte *key = (Byte *)[data bytes];
    
    if (!BN_hex2bn(&z, key)) ABORT_;
    if (!EC_POINT_mul(group,P, z, NULL, NULL, ctx)) ABORT_;
    if (!EC_POINT_get_affine_coordinates_GFp(group,P, x, y, ctx)) ABORT_;
    
    //    if ([priKey isEqualToString:[NSString secureKey]]) {
    EC_KEY_set_private_key(eckey,z);
    EC_KEY_set_public_key(eckey, P);
    //    }
    
    /* check key */
    if (!EC_KEY_check_key(eckey))
    {
        return NULL;
    }
    
    /* create signature */
    sig_len = ECDSA_size(eckey);
    if ((signature = OPENSSL_malloc(sig_len)) == NULL)
    return NULL;
    
    rp    = BN_new();
    kinv  = BN_new();
    order = BN_new();
    
    char randomData[64];
    for (int x=0;x<64;randomData[x++] = (char)('0' + (arc4random_uniform(10))));
    
    if (!BN_hex2bn(&z, randomData)) ABORT_;//设置随机数
    if (!EC_POINT_mul(group, Q, z, NULL, NULL, ctx))
    {
        return NULL;
    }
    if (!EC_POINT_get_affine_coordinates_GFp(group,Q, x, y, ctx))
    {
        return NULL;
    }
    
    EC_GROUP_get_order(group, order, ctx);
    if (!BN_nnmod(rp, x, order, ctx))
    {
        return NULL;
    }
    if (!BN_copy(kinv, z ))
    {
        return NULL;
    }
    
    if (!SM2_sign_ex(1, dgst, 32, signature, &sig_len, kinv, rp, eckey))
    {
        return NULL;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSData *cryptData = [[[NSData alloc] initWithBytes:signature length:sig_len] base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *signatureString = [[NSString alloc] initWithData:cryptData encoding:NSUTF8StringEncoding];
    [dic setObject:signatureString forKey:@"signature"];
    [dic setObject:sm3String forKey:@"sm3String"];
    
    d2i_ECDSA_SIG(&ecsig, &signature, sig_len);
    CRYPTO_cleanup_all_ex_data();//clean_debug
    ERR_free_strings();//free_debug
    ERR_remove_state(0);//remove_debug
    CRYPTO_mem_leaks_fp(stderr);//mem_leaks_debug
    
builtin_err:
    //    OPENSSL_free(signature);
    signature = NULL;
    EC_POINT_free(P);
    EC_POINT_free(Q);
    EC_POINT_free(R);
    EC_POINT_free(DHPoint);
    EC_KEY_free(eckey);
    eckey = NULL;
    EC_GROUP_free(group);
    BN_CTX_free(ctx);
    
    return dic;
}

- (instancetype)SM2CheckSignature:(NSString *)sig WithPublicKeyX:(NSString *)pubKeyX andPublicKeyY:(NSString *)pubKeyY; {
    
    CRYPTO_set_mem_debug_functions(0, 0, 0, 0, 0);//debug
    CRYPTO_mem_ctrl(CRYPTO_MEM_CHECK_ON);//open_debug
    ERR_load_crypto_strings();//printf_debug
    
    static const char rnd_seed[] = "string to make the random number generator think it has entropy";
    
    RAND_seed(rnd_seed, sizeof rnd_seed);
    BN_CTX *ctx = NULL;
    BIGNUM *p, *a, *b;
    EC_GROUP *group;
    EC_POINT *P, *Q, *R;
    BIGNUM *x, *y, *z;
    EC_KEY	*eckey = NULL;
    int	sig_len;
    ECDSA_SIG *ecsig = ECDSA_SIG_new();
    EC_POINT * DHPoint = NULL;
    
    CRYPTO_set_mem_debug_functions(0, 0, 0, 0, 0);
    CRYPTO_mem_ctrl(CRYPTO_MEM_CHECK_ON);
    ERR_load_crypto_strings();
    RAND_seed(rnd_seed, sizeof rnd_seed); /* or BN_generate_prime may fail */
    
    ctx = BN_CTX_new();
    if (!ctx) ABORT_;
    
    /* Curve SM2 (Chinese National Algorithm) */
    //http://www.oscca.gov.cn/News/201012/News_1197.htm
    p = BN_new();
    a = BN_new();
    b = BN_new();
    if (!p || !a || !b) ABORT_;
    group = EC_GROUP_new(EC_GFp_mont_method()); /* applications should use EC_GROUP_new_curve_GFp
                                                 * so that the library gets to choose the EC_METHOD */
    if (!group) ABORT_;
    
    //    m2 testing P256 Vetor(sm2_param_recommand)
    static const char *group_p ="FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF";
    static const char *group_a ="FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC";
    static const char *group_b ="28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93";
    static const char *group_Gx ="32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7";
    static const char *group_Gy ="BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0";
    static const char *group_n = "FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123";
    
    if (!BN_hex2bn(&p, group_p)) ABORT_;
    if (1 != BN_is_prime_ex(p, BN_prime_checks, ctx, NULL)) ABORT_;
    if (!BN_hex2bn(&a, group_a)) ABORT_;
    if (!BN_hex2bn(&b, group_b)) ABORT_;
    if (!EC_GROUP_set_curve_GFp(group, p, a, b, ctx)) ABORT_;
    
    P = EC_POINT_new(group);
    Q = EC_POINT_new(group);
    R = EC_POINT_new(group);
    if (!P || !Q || !R) ABORT_;
    
    x = BN_new();
    y = BN_new();
    z = BN_new();
    if (!x || !y || !z) ABORT_;
    
    if (!BN_hex2bn(&x, group_Gx)) ABORT_;
    if (!EC_POINT_set_compressed_coordinates_GFp(group, P, x, 0, ctx)) ABORT_;
    if (!EC_POINT_is_on_curve(group, P, ctx)) ABORT_;
    if (!BN_hex2bn(&z, group_n)) ABORT_;
    if (!EC_GROUP_set_generator(group, P, z, BN_value_one())) ABORT_;
    
    if (!EC_POINT_get_affine_coordinates_GFp(group, P, x, y, ctx)) ABORT_;
    /* G_y value taken from the standard: */
    if (!BN_hex2bn(&z, group_Gy)) ABORT_;
    if (0 != BN_cmp(y, z)) ABORT_;
    
    if (EC_GROUP_get_degree(group) != 256) ABORT_;
    
    fflush(stdout);
    if (!EC_GROUP_get_order(group, z, ctx)) ABORT_;
    if (!EC_GROUP_precompute_mult(group, ctx)) ABORT_;
    if (!EC_POINT_mul(group, Q, z, NULL, NULL, ctx)) ABORT_;
    if (!EC_POINT_is_at_infinity(group, Q)) ABORT_;
    fflush(stdout);
    
    //testing ECDSA for SM2
    /* create new ecdsa key */
    if ((eckey = EC_KEY_new()) == NULL)
    return NULL;
    if (EC_KEY_set_group(eckey, group) == 0)
    {
        return NULL;
    }
    
    /* create key */
    NSData *data = [[NSString secureKey] dataUsingEncoding: NSUTF8StringEncoding];
    Byte *key = (Byte *)[data bytes];
    
    if (!BN_hex2bn(&z, key)) ABORT_;
    if (!EC_POINT_mul(group,P, z, NULL, NULL, ctx)) ABORT_;
    if (!EC_POINT_get_affine_coordinates_GFp(group,P, x, y, ctx)) ABORT_;
    
    if ([pubKeyX isEqualToString:[NSString publicKeyX]] && [pubKeyY isEqualToString: [NSString publicKeyY]]) {
        EC_KEY_set_public_key(eckey, P);
    } else {
        return nil;
    }
    
    /* check key */
    if (!EC_KEY_check_key(eckey))
    {
        return NULL;
    }
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:sig options:0];
    const unsigned char *signature = (Byte *)[decodedData bytes];
    
    //    NSData *nsdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    //    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    //    NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64Encoded options:0];
    //    Byte *dgst = (Byte *)[nsdataFromBase64String bytes];
    
    NSData *nsdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *dgst = (Byte *)[nsdata bytes];
    
    //    /* verify signature */
    //    if (SM2_verify(1, dgst, 32, signature, sig_len, eckey) != 1)
    //    {
    //        return NULL;
    //    }
    
    if (!BN_hex2bn(&z, "6FCBA2EF9AE0AB902BC3BDE3FF915D44BA4CC78F88E2F8E7F8996D3B8CCEEDEE")) ABORT;
    if (!EC_POINT_mul(group,P, z, NULL, NULL, ctx)) ABORT;
    if (!EC_POINT_get_affine_coordinates_GFp(group,P, x, y, ctx)) ABORT;
    EC_KEY_set_private_key(eckey,z);
    EC_KEY_set_public_key(eckey, P);
    
    if (!BN_hex2bn(&z, "5E35D7D3F3C54DBAC72E61819E730B019A84208CA3A35E4C2E353DFCCB2A3B53")) ABORT;
    if (!EC_POINT_mul(group,Q, z, NULL, NULL, ctx)) ABORT;
    if (!EC_POINT_get_affine_coordinates_GFp(group,Q, x, y, ctx)) ABORT;
    //    EC_KEY_set_private_key(eckey,z);
    //    EC_KEY_set_public_key(eckey, P);
    
    if (!BN_hex2bn(&z, "33FE21940342161C55619C4A0C060293D543C80AF19748CE176D83477DE71C80")) ABORT;
    if (!EC_POINT_mul(group,P, z, NULL, NULL, ctx)) ABORT;
    if (!EC_POINT_get_affine_coordinates_GFp(group,P, x, y, ctx)) ABORT;
    
    if (!BN_hex2bn(&z, "83A2C9C8B96E5AF70BD480B472409A9A327257F1EBB73F5B073354B248668563")) ABORT;
    if (!EC_POINT_mul(group,R, z, NULL, NULL, ctx)) ABORT;
    if (!EC_POINT_get_affine_coordinates_GFp(group,R, x, y, ctx)) ABORT;
    
    unsigned char outkey[256];
    size_t keylen = 256;
    size_t outlen = 256;
    SM2_DH_key(group,P, Q, z,eckey,outkey,keylen);
    
    for(int i=0; i<outlen; i++)
    printf("%02X",outkey[i]);
    printf("\n");
    
    
    d2i_ECDSA_SIG(&ecsig, &signature, sig_len);
    CRYPTO_cleanup_all_ex_data();//clean_debug
    ERR_free_strings();//free_debug
    ERR_remove_state(0);//remove_debug
    CRYPTO_mem_leaks_fp(stderr);//mem_leaks_debug
    
builtin_err:
    signature = NULL;
    EC_POINT_free(P);
    EC_POINT_free(Q);
    EC_POINT_free(R);
    EC_POINT_free(DHPoint);
    EC_KEY_free(eckey);
    eckey = NULL;
    EC_GROUP_free(group);
    BN_CTX_free(ctx);
    
    return self;
}

/**
 * SM2签名
 */

- (instancetype)SM2SignatureWithPublicKeyX:(NSString *)pubKeyX andPublicKeyY:(NSString *)pubKeyY {
    if (self == NULL || pubKeyX == NULL || pubKeyY == NULL) {
        return NULL;
    }
    BIGNUM *P_x;
    BIGNUM *P_y;
    BIGNUM *P_d;
    //私钥
    const char* privateKeyMsg = "00A3C424237F520C43AA09AB0C095DC4133C9A02416894202CD732EC8E02442C99";
    int point_bit_length=256;
    ec_param *ecp;
    sm2_sign_st sign;
    const char* publicXKeyMsg = [pubKeyX UTF8String];
    const char* publicYKeyMsg = [pubKeyY UTF8String];
    const char* contentMsg = [self UTF8String];
    
    P_x = BN_new();
    P_y = BN_new();
    P_d = BN_new();
    BN_hex2bn(&P_x, publicXKeyMsg);
    BN_hex2bn(&P_y, publicYKeyMsg);
    BN_hex2bn(&P_d, privateKeyMsg);
    ecp = ec_param_new();
    ec_param_init(ecp, sm2_param_recommand, TYPE_GFp, point_bit_length);
    
    memset(&sign, 0, sizeof(sign));
    sign.message = (BYTE *)contentMsg;
    sign.message_byte_length = strlen(contentMsg);
    sign.ID = (BYTE *)ID_A;
    sign.ENTL = strlen(ID_A);
    //生成随机字符串
    unsigned char *msg = byteArrayToString((unsigned char *)genRandomString(20), 20);
    sm2_hex2bin((BYTE *)msg, sign.k, ecp->point_byte_length);
    sm2_bn2bin(P_d, sign.private_key, ecp->point_byte_length);
    sm2_bn2bin(P_x, sign.public_key.x, ecp->point_byte_length);
    sm2_bn2bin(P_y, sign.public_key.y, ecp->point_byte_length);
    BYTE *data = sm2_sign(ecp, &sign);
    
    memset(sign.private_key, 0, sizeof(sign.private_key));
    //    sm2_verify(ecp, &sign);
    ec_param_free(ecp);
    return [NSString stringWithFormat:@"%s", byteArrayToString(data, 64)];
    
}

- (instancetype)SM4EncryptWithKey:(NSString *)aKey {
    if (self == NULL || aKey == NULL) {
        return NULL;
    }
    
    sm4_context ctx;
    //    ctx.sk;//可设置为定值
    
    NSData *data = [aKey dataUsingEncoding: NSUTF8StringEncoding];
    Byte *key = (Byte *)[data bytes];
    
    NSData *data2 = [self dataUsingEncoding: NSUTF8StringEncoding];
    Byte *mingwen = (Byte *)[data2 bytes];
    
    int pwd_length = strlen(mingwen) >= 16 ? (strlen(mingwen)/16+1)*16 : 16;
    
    unsigned char tmp[pwd_length];
    memset(tmp, 0x00,pwd_length);
    memcpy(tmp, mingwen, strlen(mingwen));
    
    unsigned char output[pwd_length];
    
    //encrypt standard testing vector
    sm4_setkey_enc(&ctx,key);
    sm4_crypt_ecb(&ctx,1,pwd_length,tmp,output);
    
    NSData *cryptData = [[[NSData alloc] initWithBytes:output length:pwd_length] base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return [[NSString alloc] initWithData:cryptData encoding:NSUTF8StringEncoding];
}

- (instancetype)SM4DecryptWithLength:(int)length andKey:(NSString *)aKey {
    
    sm4_context ctx;
    
    NSData *data = [aKey dataUsingEncoding: NSUTF8StringEncoding];
    Byte *key = (Byte *)[data bytes];
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    Byte *miwen = (Byte *)[decodedData bytes];
    
    int pwd_length = strlen(miwen)>=16?(strlen(miwen)/16+1)*16:16;
    
    unsigned char input[pwd_length];
    //设置密文
    for (int i = 0; i < pwd_length; i++)
    {
        input[i] =  miwen[i];
    }
    
    unsigned char output[pwd_length];
    
    //decrypt testing
    sm4_setkey_dec(&ctx,key);
    sm4_crypt_ecb(&ctx,0,pwd_length,input,output);
    
    NSMutableString *sm4String = [NSMutableString string];
    for(int i = 0;i < pwd_length;i++) {
        [sm4String appendString:[NSString stringWithFormat:@"%c", output[i]]];
    }
    NSString *string = [sm4String substringWithRange:NSMakeRange(0, length)];
    
    return sm4String;
}

- (instancetype)AESEncryptWithKeyString:(NSString *)keyString {
    if (self == NULL || keyString == NULL) {
        return NULL;
    }
    
    //将需要加密的字符串转化为const char*类型
    const char* str = [self UTF8String];
    
    //密钥字符串转化成char*
    const char* key = [keyString UTF8String];
    unsigned char deb_key[KEY_LEN + 1] = "";
    generateKey((unsigned char*) key, deb_key);
    //LOGD("****deb_key=%s",deb_key);
    
    unsigned char dst[CBUFF_LEN];
    //memset((char*) source, 0, CBUFF_LEN);
    memset((char*) dst, 0, sizeof(dst));
    
    int ciphertext_len;
    
    //LOGD("LIB plaintext:%s:len=%d\n",plaintext, strlen((char *)plaintext));
    //LOGD("LIB key:%s[0x%x,0x%x,0x%x,0x%x]\n",key,key[0],key[1],key[2],key[3]);
    
    unsigned char iv[32]={'1','2','3','4','5','6','7','8','9','0','1','2','3','4','5','6'};
    //unsigned char *iv = (unsigned char*)"01234567890123456";
    
    /* Initialise the library */
    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
    OPENSSL_config(NULL);
    
    /* Encrypt the plaintext */
    ciphertext_len = encrypt2(str, strlen((char *)str), key, iv,
                              dst);
    
    /* Do something useful with the ciphertext here */
    //printf("Ciphertext is:\n");
    //BIO_dump_fp(stdout, (char *)ciphertext, ciphertext_len);
    //LOGD("#### %x%x%x%x",ciphertext[0],ciphertext[1],ciphertext[2],ciphertext[3]);
    
    /* Clean up */
    EVP_cleanup();
    ERR_free_strings();
    
    //    cipher_len = aesencrypt((unsigned char*) str, deb_key, dst);
    
    char *hexData = (char*)byteArrayToString(dst,ciphertext_len);
    
    
    return [NSString stringWithFormat:@"%s", hexData];
    
}

int encrypt2(unsigned char *plaintext, int plaintext_len, unsigned char *key,
             unsigned char *iv, unsigned char *ciphertext)
{
    EVP_CIPHER_CTX *ctx;
    
    int len;
    
    int ciphertext_len;
    
    /* Create and initialise the context */
    if(!(ctx = EVP_CIPHER_CTX_new())){
        //handleErrors();
    }
    
    /* Initialise the encryption operation. IMPORTANT - ensure you use a key
     * and IV size appropriate for your cipher
     * In this example we are using 256 bit AES (i.e. a 256 bit key). The
     * IV size for *most* modes is the same as the block size. For AES this
     * is 128 bits */
    //  if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_ecb(), NULL, key, iv)){
    if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, iv)){
        //handleErrors();
    }
    
    /* Provide the message to be encrypted, and obtain the encrypted output.
     * EVP_EncryptUpdate can be called multiple times if necessary
     */
    if(1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len)){
        //handleErrors();
    }
    ciphertext_len = len;
    
    /* Finalise the encryption. Further ciphertext bytes may be written at
     * this stage.
     */
    if(1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len)){
        //handleErrors();
    }
    ciphertext_len += len;
    
    /* Clean up */
    EVP_CIPHER_CTX_free(ctx);
    
    return ciphertext_len;
}

void generateKey(unsigned char *salt1, unsigned char *dstKey) {
    int salt1_len = strlen((char *) salt1);
    
    strcpy((char *) dstKey, (char *) salt1);
    
}


//- (instancetype)AESDecryptWithKeyString:(NSString *)keyString iv:(NSString *)ivString {
//    if (self == NULL || keyString == NULL || ivString == NULL) {
//        return NULL;
//    }
//
//    CocoaSecurityResult *result = [CocoaSecurity aesDecryptWithBase64:self key:[keyString dataUsingEncoding:NSUTF8StringEncoding] iv:[ivString dataUsingEncoding:NSUTF8StringEncoding]];
//    return result.utf8String;
//}

- (instancetype)RSAEencryptWithKey_e:(NSString *)key_e andKey_n:(NSString *)key_n {
    if (self == NULL || key_e == NULL || key_n == NULL) {
        return NULL;
    }// 加密数据长度 = key_n - 11 = 117
    
    //密钥字符串转化成char*
    const char* public_key_e = [key_e UTF8String];
    const char* public_key_n = [key_n UTF8String];
    
    int count = self.length / 117;
    
    NSMutableString *RSAEncryptString = [[NSMutableString alloc] init];
    
    for (int i = 0; i <= count; i ++) {
        //将需要加密的字符串转化为const char*类型
        const char* msg;
        if (i == count) {
            NSRange range = NSMakeRange(117 * i, self.length - 117 * i);
            NSString *string = [self substringWithRange:range];
            msg = [string UTF8String];
        } else {
            NSRange range = NSMakeRange(117 * i, 117);
            NSString *string = [self substringWithRange:range];
            msg = [string UTF8String];
        }
        unsigned char *ptr_en = my_encrypt(((unsigned char*) msg), public_key_n,
                                           public_key_e);
        NSString *RSAString = [NSString stringWithFormat:@"%s", ptr_en];
        
        [RSAEncryptString appendString:RSAString];
    }
    
    return RSAEncryptString;
    
    
}

- (instancetype)checkJsonStringOfProjectLicense:(NSString *)licenseName {
    if (self == NULL) {
        return NULL;
    }
    
    NSDictionary *rsaDictionary = [[self RSADencryptWith:licenseName] jsonStringToDictionary];
    NSLog(@"%@", rsaDictionary);
    NSString *returnString = [[NSString alloc] init];
    if (rsaDictionary) {
        
        //        if ([[rsaDictionary objectForKey:@"model"]isEqualToString:@"test"]) {
        
        if ([[rsaDictionary objectForKey:@"appid"]isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            
            returnString = @"检验成功";
        }
        else{
            returnString = @"bundleId检验失败";
        }
        //        }
        //        else if([[rsaDictionary objectForKey:@"model"]isEqualToString:@"profession"]){
        //            returnString = @"检验成功";
        //        }
    }
    else{
        returnString = @"验签没有通过";
    }
    return returnString;
}

- (instancetype)RSADencryptWith:(NSString *)licenseName {
    if (self == NULL) {
        return NULL;
    }
    //通过读取lsc文件，得到加密的data
    NSString *encryptPath = [[NSBundle mainBundle]pathForResource:licenseName ofType:@"lsc"];
    NSData *encryptData = [NSData dataWithContentsOfFile:encryptPath];
    NSString *encryptString = [[NSString alloc]initWithData:encryptData encoding:NSUTF8StringEncoding];
    
    const char* msg = [encryptString UTF8String];
    unsigned char *ptr_en = my_encrypt_pri_(((unsigned char*) msg));
    
    return [NSString stringWithFormat:@"%s", ptr_en];
}

- (NSDictionary *)jsonStringToDictionary {
    if (self == nil) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 * 生成rsa的秘钥
 * */
RSA * GenerateRSAKey() {
    RSA *p_rsa;
    int iBits = 1024; // key length
    BIGNUM *bne; // store elibpassguard_jni.so
    unsigned long e = RSA_F4;
    int ret = 0;
    bne = BN_new();
    ret = BN_set_word(bne, e);
    p_rsa = RSA_new();
    ret = RSA_generate_key_ex(p_rsa, iBits, bne, NULL);
    
    if (ret != 1) {
        return NULL;
    }
    return p_rsa;
}

unsigned char *my_encrypt(unsigned char *str, const char *n_b,
                          const char *e_b) {
    RSA *p_rsa;
    int flen, rsa_len;
    
    const char *d_b = "998D6E24E1F91209CECEAE03A5AF105C21CD3A78C6FE272999B5E6E28788CC479D2E0E7181775AEBF0085D4709712ABE6C724DF5045E7F5BB7329F952CA3426E6FF7B1C001940A435B805A0974DACD717742F5247C7E02298465ACFBC10A5DC93A99230ED43425EF6F8DA5FA787D32B8DC67A8D40238B391B2167E48FE15B581";
    RSA *rsa = GenerateRSAKey();
    p_rsa = RSA_new();
    BN_hex2bn(&(p_rsa->n), n_b);
    BN_hex2bn(&(p_rsa->e), e_b);
    BN_hex2bn(&(p_rsa->d), d_b);
    flen = strlen((char*) str);
    rsa_len = flen>117?117:flen;
    unsigned char p_en[128];
    int iret = RSA_public_encrypt(flen, str, p_en, p_rsa, RSA_PKCS1_PADDING);
    if (iret < 0) {
        return NULL;
    }
    char *hexData = (char*) byteArrayToString(p_en, 128);
    
    RSA_free(p_rsa);
    
    return hexData;
}

unsigned char *my_encrypt_pri_(unsigned char *hex) {
    RSA *p_rsa;
    int flen;
    const char *n_b = "93250935917582447259479044866736013799559593599958328158827366498480653178587908832475470112036013274226705084521683324008382176533595423438607845134739346439675446813243951776445562480814087352804177461832860365632315854662636205693268569882474111711423038136012062713832729785106555797467399317870762005071";
    const char *e_b = "65537";
    
    p_rsa = RSA_new();
    BN_dec2bn(&(p_rsa->n), n_b);
    BN_dec2bn(&(p_rsa->e), e_b);
    int src_len = strlen(hex);
    int count = src_len/256;
    unsigned char p_de[1024 * count];
    memset( p_de, 0, 1024 * count*sizeof(char) );
    for(int i=0;i<count;i++){
        int start = i*256;
        unsigned char d_tmp[1024];
        memset(d_tmp,0,1024);
        unsigned char p_tmp[256] = { 0 };
        mid(p_tmp,hex,256,start);
        int iret = RSA_public_decrypt(128,hextobyte_(((const char*)p_tmp)),d_tmp,p_rsa,RSA_PKCS1_PADDING);
        strcat(((char*)p_de),((char*)d_tmp));
    }
    RSA_free(p_rsa);
    
    return p_de;
}

- (instancetype)md5Encrypt {
    
    if (self == NULL) {
        return NULL;
    }
    //将需要加密的字符串转化为const char*类型
    const char* str = [self UTF8String];
    unsigned char dst[MD5_LEN];
    
    char *input = malloc(sizeof(char[strlen(str)])) ;//new c++
    strcpy(input, str);
    char *p;
    EVP_Digest(&(input[0]), strlen(input), dst, NULL, EVP_md5(), NULL);
    p = pt(dst, MD5_LEN);
    
    return [NSString stringWithFormat:@"%s", p];
}

- (instancetype)md5EncryptUpper {
    
    if (self == NULL) {
        return NULL;
    }
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    CC_MD5( cStr,[num intValue], result );
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] uppercaseString];
    
}

char *pt(unsigned char *md, int len) {
    int i;
    static char buf[80];
    
    for (i = 0; i < len; i++)
    sprintf(&(buf[i * 2]), "%02x", md[i]);
    return (buf);
}

+ (instancetype)fileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: CHUNK_SIZE ];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}


- (instancetype)DES3EncryptWithKeyString:(NSString *)keyString {
    
    if (self == NULL && keyString == NULL) {
        return NULL;
    }
    keyString = [self stringToBase64:keyString];
    NSString *ivStr = [self stringToBase64:gIv];
    
    
    NSString * encoded = [self doSKCipher:self enc:kCCEncrypt key:keyString iv:ivStr];
    
    return encoded;
}

- (instancetype)DES3DecryptWithKeyString:(NSString *)keyString {
    keyString = [self stringToBase64:keyString];
    NSString *ivStr = [self stringToBase64:gIv];
    NSString * decoded = [self doSKCipher:self enc:kCCDecrypt key:keyString iv:ivStr];
    
    return decoded;
}

- (instancetype)stringToBase64:(NSString *)string {
    NSData *nsdata = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    return base64Encoded;
}

- (NSString*)doSKCipher:(NSString*)plainText enc:(CCOperation)encryptOrDecrypt key:(NSString *)keyInput iv:(NSString *)ivInput {
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    //变成nsdata
    NSData *decodedKey = [[NSData alloc] initWithBase64EncodedString:keyInput options:0];
    NSData *decodedIv = [[NSData alloc] initWithBase64EncodedString:ivInput options:0];
    
    if (encryptOrDecrypt == kCCDecrypt) {
        NSData *EncryptData = [[NSData alloc] initWithBase64EncodedString:plainText options:0];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    } else {
        plainTextBufferSize = [plainText length];
        vplainText = (const void *) [plainText UTF8String];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    //  uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    
    unsigned char result1[24];
    memcpy(result1, decodedKey.bytes, decodedKey.length);
    unsigned char IV3[8];
    memcpy(IV3, decodedIv.bytes, decodedIv.length);
    
    uint8_t iv[kCCBlockSize3DES];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       result1, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       IV3 ,  //iv,
                       vplainText,  //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else*/ if (ccStatus == kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt) {
        result = [ [NSString alloc] initWithData: [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSASCIIStringEncoding];
    } else {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [myData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
    }
    return result;
}


@end
