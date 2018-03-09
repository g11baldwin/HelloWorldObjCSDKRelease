//
//  PPLoginButton.m
//  HelloWorld
//
//  Created by JettBlack on 3/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import "PPLoginButton.h"
#import "PPManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation PPLoginButton

-(id)init {
    
    //Ratio is 279w / 55h
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width * 0.7;
    if (buttonWidth > 300) {
        buttonWidth = 300;
    }
    CGFloat buttonHeight = buttonWidth * 55 / 279;
    CGRect rect = CGRectMake(0, 0, buttonWidth, buttonHeight);
    self = [super initWithFrame:rect];
    if (self) {
        [self addImage];
        [self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
        self.layer.cornerRadius = buttonHeight / 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)addImage
{
    UIImageView *ssoButtonImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SSOButtonImage"]];
    ssoButtonImage.frame = self.bounds;
    ssoButtonImage.contentMode=UIViewContentModeScaleAspectFit;
    [self addSubview:ssoButtonImage];
    [self sendSubviewToBack:ssoButtonImage];
}

- (void)didTouchButton {
    [[PPManager sharedInstance].PPusersvc login];
}

@end
