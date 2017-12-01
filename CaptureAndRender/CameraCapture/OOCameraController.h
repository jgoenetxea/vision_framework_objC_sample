//
//  OOCameraController.h
//
//  Created by Victor Goñi on 07/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#define OO_CAPTURE_FRAMES_PER_SECOND		20

@protocol NewFrameDelegate <NSObject>

- (void) frameCapturedWithRef:(CMSampleBufferRef) frame;

@end

@interface OOCameraController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property id<NewFrameDelegate> delegate;


/////////////
// Functions
/////////////
- (void)initCapture;
- (void) CameraSetOutputProperties;
- (void) adjustCaptureCameraOrientation;
- (void) adjustCaptureCameraOrientation:(UIDeviceOrientation)ori;
- (AVCaptureVideoOrientation) videoOrientation;
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;
- (void)setBoundsLayer:(float)x:(float)y:(float)width:(float)height;

- (int) toggleCamera;
- (void) setCameraOrientation:(UIDeviceOrientation) ori;


@end
