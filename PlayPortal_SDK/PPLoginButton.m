//
//  PPLoginButton.m
//  HelloWorld
//
//  Created by JettBlack on 3/7/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "PPLoginButton.h"
#import "PPManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation PPLoginButton

-(id)init {
    CGRect rect = CGRectMake(0, 0, 257, 52);
    self = [super initWithFrame:rect];
    if (self) {
        [self addImage];
        [self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
        self.layer.cornerRadius = 26;
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
