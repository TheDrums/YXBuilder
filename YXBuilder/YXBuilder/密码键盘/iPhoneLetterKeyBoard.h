//
//  iPhoneLetterKeyBoard.h
//  dlns
//
//  Created by 王保仲 on 14-10-15.
//
//

#import <UIKit/UIKit.h>


@protocol LettersChangesDelegate <NSObject>

-(void)lettersChange;

@end

@interface iPhoneLetterKeyBoard : UIView

@property (assign,nonatomic) id<UITextInput>  textView;

/**
 是否进行乱序
 */
@property (nonatomic, assign) int isRandomFlag;
@property (nonatomic,assign) BOOL isNumKeyboard;
@property (nonatomic,assign) BOOL isButtonPress;
@property (nonatomic,strong) NSString *inputregex;
@property (nonatomic,assign) int maxLength;
@property (nonatomic, assign) id<LettersChangesDelegate> letterDelegate;

-(void)changeKeyBoard;
-(void)initKeyBoard;

@end
