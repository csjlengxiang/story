//
//  RoundLabel.m
//  sleepstory
//
//  Created by tianqi on 15/4/5.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "RoundLabel.h"

@implementation RoundLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    self.layer.borderColor = [SYUtil colorWithHex:@"cccccc"].CGColor;
    self.layer.borderWidth  = 1;
    self.layer.cornerRadius = 4;

    self.textColor = [SYUtil colorWithHex:@"cccccc"];
    self.font = [UIFont fontWithName:@"arial" size:12];
}


@end
