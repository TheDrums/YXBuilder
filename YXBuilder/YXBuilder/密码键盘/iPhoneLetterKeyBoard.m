//
//  iPhoneLetterKeyBoard.m
//  dlns
//
//  Created by 王保仲 on 14-10-15.
//
//

#import "iPhoneLetterKeyBoard.h"
#import "YCTextField.h"
#import "JZYHNumKeyBoard.h"
#import "HBuilderJZYHGlobal.h"
#define kFont [UIFont fontWithName:@"GurmukhiMN" size:22]

enum {
    PKNumberPadViewImageLeft = 0,
    PKNumberPadViewImageInner,
    PKNumberPadViewImageRight,
    PKNumberPadViewImageMax
};

@interface iPhoneLetterKeyBoard ()<JZYHNumKeyBoardDelegate>
{
    YCTextField *_textField;
}
//键盘上显示的字母数组
@property (nonatomic, strong) NSArray *lettersArray;
//键盘上显示的大写字母数组
@property (nonatomic, strong) NSMutableArray *upperArray;
//26个字母按键数组
@property (nonatomic, strong) NSMutableArray *btnsArray;

/**
 数字、字母切换按钮
 */
@property (strong, nonatomic) UIButton *shiftButton;

/**
 大写锁定按钮
 */
@property (strong, nonatomic) UIButton *altButton;

/**
 返回按钮
 */
@property (strong, nonatomic) UIButton *returnButton;

/**
 删除按钮
 */
@property (strong, nonatomic) UIButton *deleteButton;

/**
 空格键
 */
@property (strong, nonatomic) UIButton *spaceButton;

/**
 数字键盘
 */
@property (strong, nonatomic) JZYHNumKeyBoard *numKeyBoard;

/**
 整个键盘的底层界面
 */
@property (strong, nonatomic) UIView *lettersView;

/**
 判断是不是切换到大写字母
 */
@property (nonatomic, assign, getter=isShifted) BOOL shifted;

@end

@implementation iPhoneLetterKeyBoard

@synthesize textView = _textView;

- (NSArray *)lettersArray {
    if (!_lettersArray) {
        _lettersArray = [NSArray array];
    }
    return _lettersArray;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)init
{
    
    CGRect frame=CGRectMake(0, 0, SCREEN_WIDTH, 235);
    self=[super initWithFrame:frame];
    if (self) {
        self.lettersArray = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
        _shifted=NO;
        self.lettersView=[[UIView alloc]initWithFrame:frame];
        [self addSubview:_lettersView];
    }
    return self;
}
-(void)setTextView:(id<UITextInput>)textView {
    
	if ([textView isKindOfClass:[UITextView class]]) {
        [(UITextView *)textView setInputView:self];
    }
    else if ([textView isKindOfClass:[UITextField class]]) {
        [(UITextField *)textView setInputView:self];
    }
    
    _textView = textView;
    _textField = textView;
}

-(id<UITextInput>)textView {
	return (YCTextField *)_textView;
}
- (BOOL) enableInputClicksWhenVisible {
    return YES;
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    self.lettersView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 235);
    
    UILabel *titleLable = [self viewWithTag:10086];
    titleLable.frame = CGRectMake(0, 0, SCREEN_WIDTH, 32);
    
    float startX=6;
    float startY=36;
    float space=2;
    float upDown=8;
    float width= (SCREEN_WIDTH - 9 * space - 2 * startX) * 0.1;
    float height=44;
    
    for (int i=0;i<26;i++) {
        UIButton *btn = [self viewWithTag:i + 1000];
        if (i<10) {
            [btn setFrame:CGRectMake(startX+i*(space+width), startY, width, height)];
        }
        else if(9<i&&i<19)
        {
            [btn setFrame:CGRectMake(startX + (i - 9)*(space+width) - space - width * 0.5, startY+height+upDown, width, height)];
        }
        else
        {
            [btn setFrame:CGRectMake(startX+(i-18)*(space+width) + 0.5 * width, startY+height+height+upDown*2, width, height)];
        }
    }
    
    UIButton *shiftBtn = [self viewWithTag:10085];
    [shiftBtn setFrame:CGRectMake(startX,startY+height+height+2*upDown,width * 1.5,44)];
    
    
    UIButton *deleteBtn = [self viewWithTag:10087];
    [deleteBtn setFrame:CGRectMake(startX + width * 8.5 + 8 * space, startY+height+height+2*upDown, SCREEN_WIDTH - (startX + width * 8 + 8 * space) - startX - 0.5 * width, 44)];

    UIButton *changeBtn= [self viewWithTag:10088];
    [changeBtn setFrame:CGRectMake(startX, startY+(height+upDown)*3,74,40)];

    UIButton *spaceBtn=[self viewWithTag:10089];
    [spaceBtn setFrame:CGRectMake(startX+74+space,startY+(height+upDown)*3,SCREEN_WIDTH - (74 + space + startX)* 2,40)];

    UIButton *doneBtn=[self viewWithTag:10090];
    [doneBtn setFrame:CGRectMake(SCREEN_WIDTH-74-startX, startY+(height+upDown)*3,74,40)];
}

-(void)initKeyBoard
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    //是否进行乱序
    if (self.isRandomFlag != 0) {
        self.lettersArray = [self.lettersArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
            return (arc4random() %2);
        }];
    }
    
    self.numKeyBoard=[[JZYHNumKeyBoard alloc]initWithType:ChangeType andisRandomFlag:self.isRandomFlag andisButtonPress:self.isButtonPress];
    _numKeyBoard.numDelegate=self;
    _numKeyBoard.superDelegate=self;
    
    UILabel *titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    titleLable.tag = 10086;
    titleLable.text = TITLESTR;
    titleLable.textColor = [UIColor blackColor];
    titleLable.backgroundColor=[UIColor colorWithRed:0.82 green:0.83 blue:0.85 alpha:1.0];
    titleLable.textAlignment = NSTextAlignmentCenter;
    
    [_lettersView addSubview:titleLable];
    
    [_lettersView setBackgroundColor:[UIColor colorWithRed:0.82 green:0.83 blue:0.85 alpha:1.0]];
    
    float startX=6;
    float startY=36;
    float space=2;
    float upDown=8;
    float width= (SCREEN_WIDTH - 9 * space - 2 * startX) * 0.1;
    float height=44;

    
    _btnsArray=[[NSMutableArray alloc]initWithCapacity:26];
    UIColor *colorImage=[UIColor whiteColor];
    for (int i=0;i<26;i++) {
        UIButton *btn;
        if (i<10) {
            btn=[UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(startX+i*(space+width), startY, width, height)];
        }
        else if(9<i&&i<19)
        {
            btn=[UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(startX + (i - 9)*(space+width) - space - width * 0.5, startY+height+upDown, width, height)];
        }
        else
        {
            btn=[UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(startX+(i-18)*(space+width) + 0.5 * width, startY+height+height+upDown*2, width, height)];
        }
//        btn.layer.masksToBounds = YES;
//        btn.layer.cornerRadius = 4;
        [btn setTitle:[_lettersArray objectAtIndex:i] forState:UIControlStateNormal];
        
        btn.tag = i + 1000;
        
        [btn setBackgroundColor:colorImage];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.userInteractionEnabled=NO;
        [_btnsArray addObject:btn];
        [_lettersView addSubview:btn];
    }
    
    //shiift
    UIButton *shiftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.shiftButton = shiftBtn;
    shiftBtn.tag = 10085;
    
//    shiftBtn.layer.masksToBounds = YES;
//    shiftBtn.layer.cornerRadius = 4;
    [shiftBtn setFrame:CGRectMake(startX,startY+height+height+2*upDown,width * 1.5,44)];
    [shiftBtn setBackgroundColor:colorImage];
    [shiftBtn setTitle:@"↑" forState:UIControlStateNormal];
    [shiftBtn addTarget:self action:@selector(shiftPressed:) forControlEvents:UIControlEventTouchDown];
    [shiftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shiftBtn addTarget:self action:@selector(unShift) forControlEvents:UIControlEventTouchUpInside];
    [_lettersView addSubview:shiftBtn];
    
    //delete
    UIButton *deleteBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.tag = 10087;
    [deleteBtn setFrame:CGRectMake(startX + width * 8.5 + 8 * space, startY+height+height+2*upDown, SCREEN_WIDTH - (startX + width * 8 + 8 * space) - startX - 0.5 * width, 44)];
    [deleteBtn setBackgroundColor:colorImage];
    [deleteBtn setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    deleteBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [deleteBtn addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    deleteBtn.layer.masksToBounds = YES;
//    deleteBtn.layer.cornerRadius = 4;
    [_lettersView addSubview:deleteBtn];
    
    //切换
    UIButton *changeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.tag = 10088;
    [changeBtn setFrame:CGRectMake(startX, startY+(height+upDown)*3,74,40)];
    [changeBtn setBackgroundColor:colorImage];
    [changeBtn setTitle:@"123" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(keyboardChange) forControlEvents:UIControlEventTouchUpInside];
//    changeBtn.layer.masksToBounds = YES;
//    changeBtn.layer.cornerRadius = 4;
    [_lettersView addSubview:changeBtn];
    
    UIButton *spaceBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.tag = 10089;
    [spaceBtn setFrame:CGRectMake(startX+74+space,startY+(height+upDown)*3,SCREEN_WIDTH - (74 + space + startX)* 2,40)];
    [spaceBtn setBackgroundColor:colorImage];
    [spaceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [spaceBtn setTitle:@"Space" forState:UIControlStateNormal];
    [spaceBtn addTarget:self action:@selector(spacePressed:) forControlEvents:UIControlEventTouchUpInside];
//    spaceBtn.layer.masksToBounds = YES;
//    spaceBtn.layer.cornerRadius = 4;
    [_lettersView addSubview:spaceBtn];
    
    UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.tag = 10090;
    [doneBtn setFrame:CGRectMake(SCREEN_WIDTH-74-startX, startY+(height+upDown)*3,74,40)];
    [doneBtn setBackgroundColor:colorImage];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(returnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    doneBtn.layer.masksToBounds = YES;
//    doneBtn.layer.cornerRadius = 4;
    [_lettersView addSubview:doneBtn];
}

- (void)touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event {
    if (_isButtonPress) {
        CGPoint location = [[touches anyObject] locationInView:_lettersView];
        for (UIButton *b in self.btnsArray) {
            if ([b subviews].count > 1) {
                [[[b subviews] objectAtIndex:1] removeFromSuperview];
            }
            if(CGRectContainsPoint(b.frame, location))
            {
                [self addPopupToButton:b];
                [[UIDevice currentDevice] playInputClick];
            }
        }
    }
}

-(void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event {
    
    if (_isButtonPress) {
        CGPoint location = [[touches anyObject] locationInView:_lettersView];
        
        for (UIButton *b in self.btnsArray) {
            if ([b subviews].count > 1) {
                [[[b subviews] objectAtIndex:1] removeFromSuperview];
            }
            if(CGRectContainsPoint(b.frame, location))
            {
                [self addPopupToButton:b];
            }
        }
    }
}


-(void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event{
    
        CGPoint location = [[touches anyObject] locationInView:_lettersView];
        
        for (UIButton *b in self.btnsArray) {
            if ([b subviews].count > 1) {
                [[[b subviews] objectAtIndex:1] removeFromSuperview];
            }
            if(CGRectContainsPoint(b.frame, location))
            {
                [self characterPressed:b];
            }
        }
}

- (void)addPopupToButton:(UIButton *)b {
    UIImageView *keyPop = nil;
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 52, 60)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (b == [self.btnsArray objectAtIndex:0] || b == [self.btnsArray objectAtIndex:10]) {
            keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:PKNumberPadViewImageRight]];
            keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        else if (b == [self.btnsArray objectAtIndex:9] || b == [self.btnsArray objectAtIndex:18]) {
            keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:PKNumberPadViewImageLeft]];
            keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        else {
            keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:PKNumberPadViewImageInner]];
            keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        
    }
    else {
        if (b == [self.btnsArray objectAtIndex:0] || b == [self.btnsArray objectAtIndex:11]) {
            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageRight]];
            keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        else if (b == [self.btnsArray objectAtIndex:10] || b == [self.btnsArray objectAtIndex:21]) {
            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageLeft]];
            keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        else {
            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageInner]];
            keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        
    }
    
//    if ([b.titleLabel.text characterAtIndex:0] < 128 && ![[b.titleLabel.text substringToIndex:1] isEqualToString:@"◌"])
//        [text setFont:[UIFont systemFontOfSize:44]];
//    else
//        [text setFont:[UIFont fontWithName:kFont.fontName size:44]];
    
    [text setFont:[UIFont fontWithName:kFont.fontName size:44]];
    [text setTextAlignment:NSTextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setAdjustsFontSizeToFitWidth:YES];
    [text setText:b.titleLabel.text];
    
    keyPop.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    keyPop.layer.shadowOffset = CGSizeMake(0, 2.0);
    keyPop.layer.shadowOpacity = 0.30;
    keyPop.layer.shadowRadius = 3.0;
    keyPop.clipsToBounds = NO;
    
    [keyPop addSubview:text];
    [b addSubview:keyPop];
}

- (void)returnPressed:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
    
	if ([self.textView isKindOfClass:[UITextView class]])
    {
        [self.textView insertText:@"\n"];
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self.textView];
    }
	else if ([self.textView isKindOfClass:[UITextField class]])
    {
        [(UITextField *)self.textView resignFirstResponder];
        if ([[(UITextField *)self.textView delegate] respondsToSelector:@selector(textFieldShouldReturn:)])
        {
            [[(UITextField *)self.textView delegate] textFieldShouldReturn:(UITextField *)self.textView];
        }
    }
}

- (void)shiftPressed:(id)sender {
	[[UIDevice currentDevice] playInputClick];
	if (!self.isShifted) {
//		[self.shiftButton setBackgroundImage:[UIImage imageNamed:@"glow.png"] forState:UIControlStateNormal];
//        [self.shiftButton setBackgroundColor:[UIColor blackColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//            [self.shiftButton setBackgroundImage:[UIImage imageNamed:@"shift.png"] forState:UIControlStateNormal];
        }
	}
}

- (void)unShift {
	if (self.isShifted) {
         [self.shiftButton setBackgroundColor:[UIColor whiteColor]];
	}
    if (!self.isShifted) {
        self.shifted = YES;
        
        self.upperArray = [NSMutableArray array];
        
        if (self.isRandomFlag == 2) {
            for (int i = 0 ; i < 26; i ++) {
                [self.upperArray addObject:[self.lettersArray[i] uppercaseString]];
            }
            self.upperArray = [self.upperArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                return (arc4random() %2);
            }];
        } else {
            for (int i = 0 ; i < 26; i ++) {
                [self.upperArray addObject:[self.lettersArray[i] uppercaseString]];
            }
        }
        
        
        for (int i=0;i<26;i++) {
            
            UIButton *btn = (UIButton *)[_lettersView viewWithTag:i + 1000];
            
            [btn setTitle:[self.upperArray objectAtIndex:i] forState:UIControlStateNormal];
        }
        
        [self.shiftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        self.shifted = NO;
        
        if (self.isRandomFlag == 2){
            self.lettersArray=[self.lettersArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                return (arc4random() %2);
            }];
        }

        
        for (int i=0;i<26;i++) {
            UIButton *btn = (UIButton *)[_lettersView viewWithTag:i + 1000];
            
            [btn setTitle:[self.lettersArray objectAtIndex:i] forState:UIControlStateNormal];
        }
        [self.shiftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)spacePressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSString *character = [NSString stringWithString:button.titleLabel.text];
    character=[NSString stringWithFormat:@"%@", @" "];
    if (self.inputregex.length>0) {// 输入字符检测
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.inputregex options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *result = [regex firstMatchInString:character options:0 range:NSMakeRange(0, [character length])];
        if (result) {
            if (_textField.secretStr.length < self.maxLength) {
                [_textField insertText:[NSString stringWithFormat:@"%@",@"*"]];
                [_textField.secretStr appendString:character];
            }
        }
    } else{
        if (_textField.secretStr.length < self.maxLength) {
            [_textField insertText:[NSString stringWithFormat:@"%@",@"*"]];
            [_textField.secretStr appendString:character];
        }
    }
    
    [[UIDevice currentDevice] playInputClick];
    [_letterDelegate lettersChange];
    
    [[UIDevice currentDevice] playInputClick];
    [_letterDelegate lettersChange];
}

- (void)altPressed:(id)sender {
    [[UIDevice currentDevice] playInputClick];
	[self.shiftButton setBackgroundImage:nil forState:UIControlStateNormal];
	self.shifted = NO;
    
	UIButton *button = (UIButton *)sender;
	
//	if ([button.titleLabel.text isEqualToString:kAltLabel]) {
//		[self loadCharactersWithArray:kChar_alt];
//        [self.altButton setTitle:[kChar objectAtIndex:18] forState:UIControlStateNormal];
//	}
//	else {
//		[self loadCharactersWithArray:kChar];
//        [self.altButton setTitle:kAltLabel forState:UIControlStateNormal];
//	}
}

-(void)keyboardChange
{
    //在点击了切换数字按钮时给数字键盘赋正则表达式
    self.numKeyBoard.inputregex = self.inputregex;
    //在点击了切换数字按钮时给数字键盘设置最大输入数
    self.numKeyBoard.maxLength = self.maxLength;
    [self changeKeyBoard];
}

-(void)changeKeyBoard
{
    if (_lettersView.alpha != 0) {
        _lettersView.alpha = 0;
//        [_lettersView removeFromSuperview];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 235);
        [self addSubview:_numKeyBoard];
        _numKeyBoard.textField=(YCTextField *) _textView;
    }
    else
    {
        [_numKeyBoard removeFromSuperview];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 235);
        _lettersView.alpha = 1;
        [self addSubview:self.lettersView];
        self.textView = (YCTextField *)_textView;
    }
    [self layoutIfNeeded];
}


/**
 删除键点击事件
 @param sender button参数
 */
- (void)deletePressed:(id)sender {
    
    UITextPosition* beginning = _textField.beginningOfDocument;
    UITextRange *rang=_textField.selectedTextRange;
    NSInteger location = [_textField offsetFromPosition:beginning toPosition:rang.start];
    if (location>0) {
        [_textField.secretStr deleteCharactersInRange:NSMakeRange(location-1,1)];
    }
    [_textField deleteBackward];
    [[UIDevice currentDevice] playInputClick];
    [_letterDelegate lettersChange];
}

/**
 字母按钮点击事件

 @param sender 字母button
 */
- (void)characterPressed:(id)sender {

	UIButton *button = (UIButton *)sender;
	NSString *character = [NSString stringWithString:button.titleLabel.text];
    if (self.inputregex.length>0) {// 输入字符检测
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.inputregex options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *result = [regex firstMatchInString:character options:0 range:NSMakeRange(0, [character length])];
        if (result) {
            if (_textField.secretStr.length < self.maxLength) {
                [_textField insertText:[NSString stringWithFormat:@"%@",@"*"]];
                [_textField.secretStr appendString:character];
            }
        }
    } else{
        if (_textField.secretStr.length < self.maxLength) {
            [_textField insertText:[NSString stringWithFormat:@"%@",@"*"]];
            [_textField.secretStr appendString:character];
        }
    }
    
    // 二次乱序
    if (self.isRandomFlag == 2) {
        self.lettersArray = [[NSArray alloc] init];
        self.lettersArray = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
        
        self.lettersArray=[self.lettersArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
            return (arc4random() %2);
        }];
        
        
        for (int i=0;i<26;i++) {
            UIButton *btn = (UIButton *)[_lettersView viewWithTag:i + 1000];
            
            [btn setTitle:[self.lettersArray objectAtIndex:i] forState:UIControlStateNormal];
        }
    }

    if (self.isShifted)
    {
        [self unShift];
    }

//    if (_isRandomFlag == 2) {
//        _lettersArray=[_lettersArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
//            return (arc4random() %2);
//        }];
//    }
    [[UIDevice currentDevice] playInputClick];
    [_letterDelegate lettersChange];
}

#pragma NumberKeyBoardDelegate

-(void)textFieldDidChange
{
    [_letterDelegate lettersChange];
}


#define _UPPER_WIDTH   (52.0 * [[UIScreen mainScreen] scale])
#define _LOWER_WIDTH   (32.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])
#define _PAN_LOWER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPDER_WIDTH   (_UPPER_WIDTH-_PAN_UPPER_RADIUS*2)
#define _PAN_UPPER_HEIGHT    (61.0 * [[UIScreen mainScreen] scale])

#define _PAN_LOWER_WIDTH     (_LOWER_WIDTH-_PAN_LOWER_RADIUS*2)
#define _PAN_LOWER_HEIGHT    (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UL_WIDTH        ((_UPPER_WIDTH-_LOWER_WIDTH)/2)

#define _PAN_MIDDLE_HEIGHT    (11.0 * [[UIScreen mainScreen] scale])

#define _PAN_CURVE_SIZE      (7.0 * [[UIScreen mainScreen] scale])

#define _PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define _PADDING_Y     (10 * [[UIScreen mainScreen] scale])
#define _WIDTH   (_UPPER_WIDTH + _PADDING_X*2)
#define _HEIGHT   (_PAN_UPPER_HEIGHT + _PAN_MIDDLE_HEIGHT + _PAN_LOWER_HEIGHT + _PADDING_Y*2)


#define _OFFSET_X    -25 * [[UIScreen mainScreen] scale])
#define _OFFSET_Y    59 * [[UIScreen mainScreen] scale])


- (UIImage *)createKeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(_PADDING_X, _PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += _PAN_UPPER_RADIUS;
    p.y += _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    switch (kind) {
        case PKNumberPadViewImageLeft:
            p.x -= _PAN_UL_WIDTH*2;
            break;
            
        case PKNumberPadViewImageInner:
            p.x -= _PAN_UL_WIDTH;
            break;
            
        case PKNumberPadViewImageRight:
            break;
    }
    
    p.y += _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += _PAN_LOWER_HEIGHT - _PAN_CURVE_SIZE - _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= _PAN_LOWER_WIDTH;
    p.y += _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= _PAN_LOWER_RADIUS;
    p.y -= _PAN_LOWER_HEIGHT - _PAN_LOWER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    
    switch (kind) {
        case PKNumberPadViewImageLeft:
            break;
            
        case PKNumberPadViewImageInner:
            p.x -= _PAN_UL_WIDTH;
            break;
            
        case PKNumberPadViewImageRight:
            p.x -= _PAN_UL_WIDTH*2;
            break;
    }
    
    p.y -= _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(_WIDTH,
                                           _HEIGHT));
    context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, _HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----
    
    // draw gradient
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGFloat components[] = {
        0.95f, 1.0f,
        0.85f, 1.0f,
        0.675f, 1.0f,
        0.8f, 1.0f};
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 2);
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    
    CFRelease(path);
    
    return image;
}

#define __UPPER_WIDTH   (52.0 * [[UIScreen mainScreen] scale])
#define __LOWER_WIDTH   (24.0 * [[UIScreen mainScreen] scale])

#define __PAN_UPPER_RADIUS  (10.0 * [[UIScreen mainScreen] scale])
#define __PAN_LOWER_RADIUS  (5.0 * [[UIScreen mainScreen] scale])

#define __PAN_UPPDER_WIDTH   (__UPPER_WIDTH-__PAN_UPPER_RADIUS*2)
#define __PAN_UPPER_HEIGHT    (52.0 * [[UIScreen mainScreen] scale])

#define __PAN_LOWER_WIDTH     (__LOWER_WIDTH-__PAN_LOWER_RADIUS*2)
#define __PAN_LOWER_HEIGHT    (47.0 * [[UIScreen mainScreen] scale])

#define __PAN_UL_WIDTH        ((__UPPER_WIDTH-__LOWER_WIDTH)/2)

#define __PAN_MIDDLE_HEIGHT    (2.0 * [[UIScreen mainScreen] scale])

#define __PAN_CURVE_SIZE      (10.0 * [[UIScreen mainScreen] scale])

#define __PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define __PADDING_Y     (10 * [[UIScreen mainScreen] scale])
#define __WIDTH   (__UPPER_WIDTH + __PADDING_X*2)
#define __HEIGHT   (__PAN_UPPER_HEIGHT + __PAN_MIDDLE_HEIGHT + __PAN_LOWER_HEIGHT + __PADDING_Y*2)


#define __OFFSET_X    -25 * [[UIScreen mainScreen] scale])
#define __OFFSET_Y    59 * [[UIScreen mainScreen] scale])


- (UIImage *)createiOS7KeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(__PADDING_X, __PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += __PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += __PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += __PAN_UPPER_RADIUS;
    p.y += __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    switch (kind) {
        case PKNumberPadViewImageLeft:
            p.x -= __PAN_UL_WIDTH*2;
            break;
            
        case PKNumberPadViewImageInner:
            p.x -= __PAN_UL_WIDTH;
            break;
            
        case PKNumberPadViewImageRight:
            break;
    }
    
    p.y += __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += __PAN_LOWER_HEIGHT - __PAN_CURVE_SIZE - __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= __PAN_LOWER_WIDTH;
    p.y += __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= __PAN_LOWER_RADIUS;
    p.y -= __PAN_LOWER_HEIGHT - __PAN_LOWER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    
    switch (kind) {
        case PKNumberPadViewImageLeft:
            break;
            
        case PKNumberPadViewImageInner:
            p.x -= __PAN_UL_WIDTH;
            break;
            
        case PKNumberPadViewImageRight:
            p.x -= __PAN_UL_WIDTH*2;
            break;
    }
    
    p.y -= __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(__WIDTH,
                                           __HEIGHT));
    context = UIGraphicsGetCurrentContext();
    
    switch (kind) {
        case PKNumberPadViewImageLeft:
            CGContextTranslateCTM(context, 6.0, __HEIGHT);
            break;
            
        case PKNumberPadViewImageInner:
            CGContextTranslateCTM(context, 0.0, __HEIGHT);
            break;
            
        case PKNumberPadViewImageRight:
            CGContextTranslateCTM(context, -6.0, __HEIGHT);
            break;
    }
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----
    //[[UIColor colorWithRed:0.973 green:0.976 blue:0.976 alpha:1.000] CGColor]
    CGRect frame = CGPathGetBoundingBox(path);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, frame);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    CFRelease(path);
    
    return image;
}


-(void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
