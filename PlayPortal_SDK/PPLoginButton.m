//
//  PPLoginButton.m
//  HelloWorld
//
//  Created by JettBlack on 3/7/18.
//  Copyright © 2018 blackCloud. All rights reserved.
//

#import "PPLoginButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation PPLoginButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self makeButtonShiny:self withBackgroundColor:[UIColor redColor]];
        [self addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)makeButtonShiny:(PPLoginButton*)button withBackgroundColor:(UIColor*)backgroundColor
{
    // Get the button layer and give it rounded corners with a semi-transparant button
    CALayer *layer = button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 2.0f;
    layer.borderColor = [UIColor colorWithWhite:0.4f alpha:0.2f].CGColor;
    
    // Create a shiny layer that goes on top of the button
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = button.layer.bounds;
    // Set the gradient colors
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    // Set the relative positions of the gradien stops
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    // Add the layer to the button
    [button.layer addSublayer:shineLayer];
    
    [button setBackgroundColor:backgroundColor];
}

- (void)didTouchButton {
    NSLog(@"BUTTON TOUCHED!");
}

@end
