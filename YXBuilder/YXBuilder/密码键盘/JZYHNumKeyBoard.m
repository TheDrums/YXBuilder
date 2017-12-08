//
//  JZYHNumKeyBoard.m
//  dlns
//
//  Created by 王保仲 on 14-10-27.
//
//

#import "JZYHNumKeyBoard.h"
#import "YCTextField.h"
#import "iPhoneLetterKeyBoard.h"
#import "HBuilderJZYHGlobal.h"
NSString *const TITLESTR = @"安 全 输 入";

@interface JZYHNumKeyBoard ()

{
    YCTextField *_textField;
}

@property (nonatomic,assign) id<UITextInput>delegate;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation JZYHNumKeyBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithType:(NumberType)numType andisRandomFlag:(int)isRandomFlag andisButtonPress:(int)isButtonPress
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    CGRect frame=CGRectMake(0, 0,SCREEN_WIDTH,235);
    self=[super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=YES;
        NSArray *array=@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
        
        if (isRandomFlag != 0) {
            _dataArray=[array sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                return (arc4random() %2);
            }];
        }
        else
        {
            _dataArray=array;
        }
        _numberType=numType;
        self.isRandomFlag = isRandomFlag;
        [self initKeyBoardWithisButtonPress:isButtonPress];
        
    }
    return self;
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    UIImageView *bgImageView = [self viewWithTag:10091];
    bgImageView.frame = CGRectMake(0,0, SCREEN_WIDTH, 235);
    
    
    UILabel *titleLable = [self viewWithTag:10092];
    titleLable.frame = CGRectMake(0, 0, SCREEN_WIDTH, 32);
    
    for (int i=1;i<=10; i++)
    {
        UIButton *btn = [self viewWithTag:i];
        [btn setFrame:CGRectMake(0 + (SCREEN_WIDTH / 3 + 1) *((i-1)%3), 33+51*((i-1)/3), SCREEN_WIDTH / 3, 50)];
    }
    
    UIButton *zeroBtn = [self viewWithTag:110];
    [zeroBtn setFrame:CGRectMake(0 + (SCREEN_WIDTH / 3 + 1) *((11 - 1)%3), 33+51*((11 - 1)/3), SCREEN_WIDTH / 3, 50)];
    
    UIButton *deleteBtn = [self viewWithTag:11];
    [deleteBtn setFrame:CGRectMake(0 + (SCREEN_WIDTH / 3 + 1) *((12 - 1)%3), 33+51*((12 - 1)/3), SCREEN_WIDTH / 3, 50)];
}


- (void)initKeyBoardWithisButtonPress:(int)isButtonPress
{
    //键盘背景图
    UIImageView *bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 235)];
    bgImageView.tag = 10091;
    bgImageView.image=[UIImage imageNamed:@"数字背景.png"];
    bgImageView.backgroundColor=[UIColor whiteColor];
    [self addSubview:bgImageView];
    
    //顶部视图
    UILabel *titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    titleLable.tag = 10092;
    titleLable.text = TITLESTR;
    titleLable.textColor = [UIColor blackColor];
    titleLable.backgroundColor=[UIColor colorWithRed:0.82 green:0.83 blue:0.85 alpha:1.0];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLable];
    
    for (int i=1;i<=12; i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0 + (SCREEN_WIDTH / 3 + 1) *((i-1)%3), 33+51*((i-1)/3), SCREEN_WIDTH / 3, 50)];
        [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        switch (i) {
            case 10:
            {
                btn.tag=10;
                [btn setBackgroundImage:[UIImage imageNamed:@"下方按钮.png"] forState:UIControlStateNormal];
                if (isButtonPress) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"gaoliang-下方按钮.png"] forState:UIControlStateHighlighted];
                } else {
                    btn.adjustsImageWhenHighlighted = NO;
                }
                if (_numberType==OnlyIntegerType) {
                    [btn setTitle:@"完成" forState:UIControlStateNormal];
                }
                else
                {
                    [btn setTitle:@"ABC" forState:UIControlStateNormal];
                }
                
            }
                break;
            case 11:
            {
                btn.tag=110;
                [btn setBackgroundImage:[UIImage imageNamed:@"中.png"] forState:UIControlStateNormal];
                if (isButtonPress) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"gaoliang-中.png"] forState:UIControlStateHighlighted];
                } else {
                    btn.adjustsImageWhenHighlighted = NO;
                }
                [btn setTitle:[_dataArray lastObject] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
            }
                break;
            case 12:
            {
                btn.tag=11;
                [btn setBackgroundImage:[UIImage imageNamed:@"下方按钮.png"] forState:UIControlStateNormal];
                if (isButtonPress) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"gaoliang-下方按钮.png"] forState:UIControlStateHighlighted];
                } else {
                    btn.adjustsImageWhenHighlighted = NO;
                }
                [btn setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
                //[btn setImageEdgeInsets:UIEdgeInsetsMake(12, 24, 12, 24)];
                
            }
                break;
            default:
            {
                btn.tag=i;
                NSString *norImage;
                NSString *heightImage = nil;
                int k=i%3;
                switch (k) {
                    case 0:
                    {
                        norImage=@"右.png";
                        heightImage=@"gaoliang-右.png";
                    }
                        break;
                    case 1:
                    {
                        norImage=@"左.png";
                        heightImage=@"gaoliang-左.png";
                    }
                        break;
                    case 2:
                    {
                        norImage=@"中.png";
                        heightImage=@"gaoliang-中.png";
                    }
                        break;
                    default:
                        break;
                }
                [btn setBackgroundImage:[UIImage imageNamed:norImage] forState:UIControlStateNormal];
                if (isButtonPress) {
                    [btn setBackgroundImage:[UIImage imageNamed:heightImage] forState:UIControlStateHighlighted];
                } else {
                    btn.adjustsImageWhenHighlighted = NO;
                }
                [btn setTitle:[_dataArray objectAtIndex:i-1] forState:UIControlStateNormal];
                
                
            }
                break;
        }
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:btn];
    }
}

- (id<UITextInput>)delegate {
    return _textField;
}

- (UITextField *)textField {
    return _textField;
}

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
    //_textField.inputView = self;
}

- (void)clicked:(UIButton *)sender {
    switch (sender.tag) {
        case 10:
        {
            if (_numberType==OnlyIntegerType) {
                [self done:nil];
            }
            else
            {
                [(iPhoneLetterKeyBoard *)_superDelegate changeKeyBoard];
            }
                
        }
            break;
        case 11:
        {
            UITextPosition* beginning = _textField.beginningOfDocument;
            UITextRange *rang=_textField.selectedTextRange;
                NSInteger location = [_textField offsetFromPosition:beginning toPosition:rang.start];
            if (location>0) {
                    [_textField.secretStr deleteCharactersInRange:NSMakeRange(location-1,1)];
                }
            
            
            [self.delegate deleteBackward];
            [[UIDevice currentDevice] playInputClick];
            [_numDelegate textFieldDidChange];

        }
            
            break;
        default:
            // max 2 decimals
        {
            
            // 二次乱序
            if (self.isRandomFlag == 2) {
                NSArray *array=@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
                
                array = [array sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                        return (arc4random() %2);
                    }];
                
                for (int i = 1;i <= 9;i++) {
                    
                        UIButton *btn = (UIButton *)[self viewWithTag:i];
                        
                        [btn setTitle:[array objectAtIndex:i - 1] forState:UIControlStateNormal];
                }
                
                UIButton *btn = (UIButton *)[self viewWithTag:110];
                
                [btn setTitle:[array lastObject] forState:UIControlStateNormal];
                
            }
            
            
            
            if (self.inputregex.length>0) {
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.inputregex options:NSRegularExpressionCaseInsensitive error:&error];
                NSTextCheckingResult *result = [regex firstMatchInString:sender.titleLabel.text options:0 range:NSMakeRange(0, [sender.titleLabel.text length])];
                if (result) {
                    if (_textField.secretStr.length < self.maxLength) {
                        [self.delegate insertText:[NSString stringWithFormat:@"%@",@"*"]];
                        [_textField.secretStr appendString:sender.titleLabel.text];
                    }
                }
            }
            else{
                if (_textField.secretStr.length < self.maxLength) {
                    [self.delegate insertText:[NSString stringWithFormat:@"%@",@"*"]];
                    [_textField.secretStr appendString:sender.titleLabel.text];
                }
            }
            [[UIDevice currentDevice] playInputClick];
            [_numDelegate textFieldDidChange];
        }
            break;
    }
}

- (void)done:(UIButton *)sender {
    // we are done with the field, let's dismiss the keyboard
    [_textField resignFirstResponder];
    if ([[(UITextField *)self.textField delegate] respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        [[(UITextField *)self.textField delegate] textFieldShouldReturn:(UITextField *)self.textField];
    }
}

#pragma mark - UIInputViewAudioFeedback delegate

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

-(void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
