//
//  OORotableView.m
//  ViulibSample
//
//  Created by Jon Goenetxea on 21/11/14.
//  Copyright (c) 2014 VictorTech. All rights reserved.
//

#import "OOAutoRotableButton.h"

@implementation OOAutoRotableButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithCoder:(NSCoder*)coder
{
    if((self = [super initWithCoder:coder]))
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rotationChanged:)
                                                     name:@"UIDeviceOrientationDidChangeNotification"
                                                   object:nil];    }
    
    return self;
}



-(void)rotationChanged:(NSNotification *)notification{
    NSInteger orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            
            [self setTransform:CGAffineTransformMakeRotation (0)];
            //[self setFrame:CGRectMake(0, 0, 320, 480)];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
            
            [UIView commitAnimations];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            
            [self setTransform:CGAffineTransformMakeRotation (M_PI)];
            //[self setFrame:CGRectMake(0, 0, 320, 480)];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
            
            [UIView commitAnimations];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            
            [self setTransform:CGAffineTransformMakeRotation (M_PI / 2)];
            //[self setFrame:CGRectMake(0, 0, 320, 480)];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            
            [UIView commitAnimations];
            break;
        case UIDeviceOrientationLandscapeRight:
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            
            [self setTransform:CGAffineTransformMakeRotation (- M_PI / 2)];
            //[self setFrame:CGRectMake(0, 0, 320, 480)];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            
            [UIView commitAnimations];
            break;
        default:
            break;
    }
}

@end
