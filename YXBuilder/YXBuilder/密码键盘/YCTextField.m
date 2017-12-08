//
//  YCTextField.m
//  dlns
//
//  Created by 王保仲 on 14-10-16.
//
//

#import "YCTextField.h"

@implementation YCTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _secretStr=[[NSMutableString alloc]init];
    }
    return self;
}

@end
