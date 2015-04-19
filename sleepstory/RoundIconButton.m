//
//  RoundIconButton.m
//  sleepstory
//
//  Created by tianqi on 15/4/5.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "RoundIconButton.h"

@implementation RoundIconButton
{
    UIImageView *icon;
    UILabel *text;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)drawIcon:(UIImage *)_icon text:(NSString *)_text{
    icon = [[UIImageView alloc] init];
    icon.image = _icon;
    icon.frame = CGRectMake(3, 3, 20, 20);
    
    [self addSubview:icon];
    
    text = [[UILabel alloc] init];
    text.text = _text;
    text.textColor = [SYUtil colorWithHex:@"aaaaaa"];
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    text.font = font;
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [_text sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    text.frame = CGRectMake(25,1, labelsize.width, 25);
    [self addSubview:text];
//    CGRect frame = self.frame;
//    frame.size.width = labelsize.width + 32;
    self.width.constant =labelsize.width + 32;
//    self.frame = frame;
    self.layer.borderWidth =1;
    self.layer.borderColor = [SYUtil colorWithHex:@"aaaaaa"].CGColor;
    self.layer.cornerRadius = 5;
}
@end
