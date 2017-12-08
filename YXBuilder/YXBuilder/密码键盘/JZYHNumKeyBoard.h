//
//  JZYHNumKeyBoard.h
//  dlns
//
//  Created by 王保仲 on 14-10-27.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    OnlyIntegerType=0,
    ChangeType=8,
    
} NumberType;

extern NSString *const TITLESTR;

@protocol JZYHNumKeyBoardDelegate <NSObject>

@optional
-(void)textFieldDidChange;
@end

@interface JZYHNumKeyBoard : UIView

@property (nonatomic, assign) UITextField *textField;
@property (nonatomic,assign) BOOL isButtonPress;
@property (nonatomic,assign) int isRandomFlag;
@property (nonatomic,strong) NSString *inputregex;
@property (nonatomic,assign) int maxLength;
@property (nonatomic, assign) id<JZYHNumKeyBoardDelegate>numDelegate;
@property (nonatomic, assign) id superDelegate;
@property (nonatomic, assign) NumberType numberType;

-(id)initWithType:(NumberType)numType andisRandomFlag:(int)isRandomFlag andisButtonPress:(int)isButtonPress;

@end
