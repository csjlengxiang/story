//
//  FavStoryCell.m
//  sleepstory
//
//  Created by yutou on 15/4/25.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "FavStoryCell.h"

@implementation FavStoryCell
{
    StoryModel *story;
    IBOutlet UIImageView *cover;
    IBOutlet UILabel *title;
    IBOutlet UILabel *desc;
}
- (void)awakeFromNib {
    // Initialization code
    
}
-(void)setStory:(StoryModel *)_story
{
    story = _story;
    NSString *encodeURI = [story.cover stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
    [cover sd_setImageWithURL:[NSURL URLWithString:encodeURI]];
    
    [title setText:[NSString stringWithFormat:@"[第%d期] %@",story.num,story.title]];
    [desc setText:[NSString stringWithFormat:@"收听次数：%d",story.visit_count]];
    cover.clipsToBounds =  YES;
    cover.layer.borderColor = [SYUtil colorWithHex:@"dddddd"].CGColor;
    cover.layer.borderWidth = 1;
    [cover.layer setCornerRadius:5];
    [cover.layer setShadowOpacity:0.5];
    [cover.layer setShadowRadius:5];
    [cover.layer setShadowOffset:CGSizeMake(1, 1)];
    [cover.layer setShadowColor:[UIColor blackColor].CGColor];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
