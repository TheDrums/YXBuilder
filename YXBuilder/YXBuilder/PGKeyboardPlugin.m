//
//  PGKeyboardPlugin.m
//  YXBuilder
//
//  Created by LiYuan on 2017/11/9.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "PGKeyboardPlugin.h"
#import "iPhoneLetterKeyBoard.h"
#import "JZYHNumKeyBoard.h"
#import "YCTextField.h"
#import "NSString+YX.h"
#import "JZYHDictionary.h"

typedef void (^Block)(NSString *jsonStr);

@interface PGKeyboardPlugin () <UITextFieldDelegate,LettersChangesDelegate,JZYHNumKeyBoardDelegate>

@property (nonatomic, strong) YCTextField *passWordField;
@property (copy, nonatomic) NSString *encryptType;
@property (copy, nonatomic) NSString *passwordHidden;
@property (nonatomic,assign) int maxLength;
//密码设置的正则表达式
@property (nonatomic,copy) NSString *regex;
//设置键盘输入正则规则
@property (nonatomic,copy) NSString *inputregex;
//随机因子
@property (nonatomic,copy) NSString *random;
//RSA的公钥
@property (nonatomic,copy) NSString *publicKey;
//SM2国密key
@property (nonatomic,copy) NSString *eccKey;


@end

typedef void (^WVJBResponseCallback)(id responseData);
@implementation PGKeyboardPlugin

WVJBResponseCallback callBack;

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (NSString *)encryptType {
    if (!_encryptType) {
        _encryptType = [NSString string];
    }
    return _encryptType;
}

- (NSString *)passwordHidden {
    if (!_passwordHidden) {
        _passwordHidden = [NSString string];
    }
    return _passwordHidden;
}

- (void)registerHandler:(NSString *)Handler
{
    [self.webViewBridge registerHandler:Handler handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@", data);
        //是否仅使用数字键盘；true为仅使用数字键盘，false为使用字母和数字全键盘（默认）
        BOOL isNumber = NO;
        //设置键盘是否乱序
        int confuse = 1;
        //设置键盘可输入的最大长度 toChange
        self.maxLength = 8;
        //键盘按下效果
        BOOL buttonPress = YES;
        //密码设置的正则表达式
        self.regex = @"";
        //设置键盘输入正则规则
        self.inputregex = @"";
        self.encryptType = @"md5";
        _passWordField = [[YCTextField alloc]init];
        _passWordField.delegate=self;
        if(isNumber){
            JZYHNumKeyBoard *numKeyBoard=[[JZYHNumKeyBoard alloc]initWithType:OnlyIntegerType andisRandomFlag:confuse andisButtonPress:buttonPress];
            numKeyBoard.isButtonPress = buttonPress;
            numKeyBoard.inputregex = self.inputregex;
            numKeyBoard.maxLength = self.maxLength;
            _passWordField.inputView = numKeyBoard;
            numKeyBoard.numDelegate=self;
            numKeyBoard.superDelegate=self;
            numKeyBoard.textField = _passWordField;
        }
        else{
            iPhoneLetterKeyBoard *lettersKeyBoard=[[iPhoneLetterKeyBoard alloc]init];
            lettersKeyBoard.isRandomFlag = confuse;
            lettersKeyBoard.isButtonPress = buttonPress;
            lettersKeyBoard.inputregex = self.inputregex;
            lettersKeyBoard.maxLength = self.maxLength;
            [lettersKeyBoard initKeyBoard];
            _passWordField.inputView=lettersKeyBoard;
            lettersKeyBoard.textView=_passWordField;
            lettersKeyBoard.letterDelegate = self;
        }
        [self.webView addSubview:_passWordField];
        
        [_passWordField becomeFirstResponder];
        
        callBack = responseCallback;
        
    }];
}

/**
 检测是否符合正则
 
 @param commends commends参数
 @return 检测结果
 */
- (void)checkMatch
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:_passWordField.secretStr options:0 range:NSMakeRange(0, [_passWordField.secretStr length])];
    if (result) {
    } else {
    }
}

/**
 清除密码键盘
 
 @param commends commends参数
 @return 清除是否成功
 */
#pragma mark ===== 清除密码键盘
-(void)clearKeyboard {
    [self.passWordField resignFirstResponder];
    [self.passWordField removeFromSuperview];
    if (self.passWordField.isFirstResponder) {
        
    }
    else{
        
    }
}

/**
 隐藏密码键盘
 
 @param commends commends参数
 @return 隐藏键盘是否成功
 */
#pragma mark ===== 隐藏密码键盘
-(void)hideKeyboard {
    [self.passWordField resignFirstResponder];
    [self.passWordField removeFromSuperview];
}


#pragma mark ===== 密码键盘输出字符改变时回调
-(void)lettersChange
{
    NSString *password = [[NSString alloc]init];
    password=_passWordField.secretStr;
    
    if ([self.encryptType isEqualToString:@"md5"]) {
        self.passwordHidden = [password md5EncryptUpper];
        NSLog(@"self.MD5 == %@",self.passwordHidden);
    }
    if([self.encryptType isEqualToString:@"aes"])
    {
        self.passwordHidden = [password AESEncryptWithKeyString:self.random];
        NSLog(@"self.AES == %@",self.passwordHidden);
    }
    if ([self.encryptType isEqualToString:@"rsaaes"]) {
        self.passwordHidden = [password RSAEencryptWithKey_e:@"010001" andKey_n:self.publicKey];
        NSLog(@"self.RSA == %@",self.passwordHidden);
    }
    if ([self.encryptType isEqualToString:@"sm2"]) {
        NSArray *array = [self.eccKey componentsSeparatedByString:@"|"];
        self.passwordHidden = [password SM2EencryptWithX:[array objectAtIndex:0] andY:[array objectAtIndex:1]];
        NSLog(@"self.SM2 == %@",self.passwordHidden);
    }
    if ([self.encryptType isEqualToString:@"sm4"]) {
        self.passwordHidden = [password SM4EncryptWithKey:self.random];
        NSLog(@"self.SM4 == %@",self.passwordHidden);
    }
    NSLog(@"输出：%@",self.passwordHidden);
    
    NSString *payload = [NSString stringWithFormat:@"{\"cipherText\":\"%@\",\"text\":\"%@\"}", self.passwordHidden, _passWordField.text];
    
    NSString *jsonStr = @"{\"height\":\"\",\"tag\":\"\"}";
    
    NSDictionary *dictionary = [NSDictionary dictionary];
    if (jsonStr) {
        dictionary = [JZYHDictionary jzyhStringWithStatus:statusOK withResult:payload withMessage:jsonStr];
    } else {
        dictionary = [JZYHDictionary jzyhStringWithStatus:statusError withResult:nil withMessage:@"数据存储失败"];
    }
    
    callBack(dictionary);
    
}

#pragma mark ===== 数字键盘代理
-(void)textFieldDidChange
{
    [self lettersChange];
}

#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSDictionary *dictionary = [NSDictionary dictionary];
    NSString *payload = @"{\"cipherText\":\"\",\"text\":\"\"}";
    
    NSString *jsonStr = @"{\"height\":\"235\",\"tag\":\"done\"}";
    dictionary = [JZYHDictionary jzyhStringWithStatus:statusOK withResult:payload withMessage:jsonStr];
    
//    callBack(dictionary);
    
    [textField removeFromSuperview];
}

@end
