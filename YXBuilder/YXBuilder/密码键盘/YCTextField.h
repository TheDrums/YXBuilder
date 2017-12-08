//
//  YCTextField.h
//  dlns
//
//  Created by 王保仲 on 14-10-16.
//
//

#import <UIKit/UIKit.h>

#import "iPhoneLetterKeyBoard.h"

@interface YCTextField : UITextField

@property (nonatomic, strong) iPhoneLetterKeyBoard *lettersKeyBoard;
@property (nonatomic, strong) NSMutableString *secretStr;

@end
