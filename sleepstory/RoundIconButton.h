//
//  RoundIconButton.h
//  sleepstory
//
//  Created by tianqi on 15/4/5.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundIconButton : UIView
@property IBOutlet NSLayoutConstraint *width;
-(void)drawIcon:(UIImage *)icon text:(NSString *)text;
@end
