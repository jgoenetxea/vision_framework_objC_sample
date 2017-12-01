//
//  OOViewController.m
//
//  Created by Victor Goñi on 07/11/13.
//  Copyright (c) 2013 VictorTech. All rights reserved.
//

#import "OOViewController.h"

@interface OOViewController ()

@end

@implementation OOViewController

// ******************************************************************************************
// * iOS FUNCTIONS
//===========================================================================================
/**
 *  Function:       viewDidLoad
 *  Description:    iOS function called when view has been loaded and ready to create UI elements
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSLog(@"--- Initial view did load; Initing...");
    [self initInterface];
    NSLog(@"--- Initial view did load; Initing done!");
}

/**
 *  Function:       didReceiveMemoryWarning
 *  Description:    iOS function called when app has memory problems
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"!!! didReceiveMemoryWarning");
}

// ******************************************************************************************
// * Initializing
//===========================================================================================
/**
 *  Function:       initViulib
 *  Description:    First step to load Viulib Singleton with all necessary elements
 */
-(void)initViulib
{

}

/**
 *  Function:       initInterface
 *  Description:    First step to load Viulib Singleton with all necessary elements
 */
-(void)initInterface
{
    NSLog(@"Initing View Interface...");
    
    NSLog(@"Initing View Interface done!");
}

// ******************************************************************************************
// * IBActions
//===========================================================================================
- (IBAction)TouchUpButtonGetStarted:(id)sender
{
    NSLog(@"___ TouchUpButtonGetStarted");
}
@end
