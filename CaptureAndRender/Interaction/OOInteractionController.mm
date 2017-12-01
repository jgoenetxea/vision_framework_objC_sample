//
//  OOInteractionController.m
//  TrackingSample
//
//  Created by Jon Goenetxea on 17/11/14.
//  Copyright (c) 2014 VictorTech. All rights reserved.
//

#import "OOInteractionController.h"

#import "OOMainViewController.h"

@interface OOInteractionController ()
{
    IBOutlet OOMainViewController* outlet_viewController;
    IBOutlet UIButton *outlet_cameraToggleButton;
}
@end

@implementation OOInteractionController

-(IBAction)showAlert:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"Title" message:@"Button pressed" delegate:self
                                             cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alertView show];
}

-(IBAction)switchCamera:(id)sender
{
    [outlet_viewController switchCamera];
}

-(IBAction)setOrientationPortrait:(id)sender
{
    [outlet_viewController setViewOrientation:UIDeviceOrientationPortrait];
}

-(IBAction)setOrientationLandscapeLeft:(id)sender
{
    [outlet_viewController setViewOrientation:UIDeviceOrientationLandscapeLeft];
}

-(IBAction)setOrientationLansdscapeRight:(id)sender
{
    [outlet_viewController setViewOrientation:UIDeviceOrientationLandscapeRight];
}

-(IBAction)reset:(id)sender
{
}

@end
