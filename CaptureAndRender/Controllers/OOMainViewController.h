//
//  OOViulibViewController.h
//  ViulibWireframe
//
//  Created by Victor Goñi on 07/11/13.
//  Copyright (c) 2013 VictorTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OOCameraController.h"
#import "OpenGLES2DView.h"

typedef enum CalibrationStatus
{
    CalibrationNone = 0,
    CalibrationStarted,
    SnapshotCaptured
} CalibrationStatus;

@interface OOMainViewController : UIViewController<NewFrameDelegate>
{
    // Declare camera manager. This instance will control the camera captures
    OOCameraController *_cameraController;
    
    // Views
    UIView* customCameraView;
    
    bool _isFirstTime;
}

// ******************************************************************************************
// * View Init Functions
//===========================================================================================
-(void)initInterface;

// ******************************************************************************************
// * View Gestures
//===========================================================================================

// ******************************************************************************************
// * IBActions
@property (strong, nonatomic) IBOutlet UIButton *OutletButtonManualAuto;
@property (strong, nonatomic) IBOutlet UIButton *OutletButtonCalibrate;
@property (strong, nonatomic) IBOutlet UIButton *OutletButtonLearnFace;
@property (strong, nonatomic) IBOutlet UIButton *OutletButtonStartRecording;
@property (strong, nonatomic) IBOutlet UIButton *OutletButtonShowPatches;

@property (strong, nonatomic) IBOutlet UIView *OutletHudMouth;
@property (strong, nonatomic) IBOutlet UIView *OutletHudNose;
@property (strong, nonatomic) IBOutlet UIView *OutletHudeye1;
@property (strong, nonatomic) IBOutlet UIView *OutletHudEye2;

@property (strong, nonatomic) IBOutlet UIView *OutletHUDView;

@property (weak, nonatomic) IBOutlet OpenGLES2DView *renderView;

// ******************************************************************************************
// * Properties to synthetize
//===========================================================================================
@property (nonatomic, retain) OOCameraController * cameraController;

-(int) switchCamera;
-(void) setViewOrientation:(UIDeviceOrientation) ori;

@end
