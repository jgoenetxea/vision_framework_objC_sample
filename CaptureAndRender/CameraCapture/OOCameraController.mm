//
//  OOCameraController.m
//
//  Created by Victor Goñi on 07/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OOCameraController.h"

@interface OOCameraController ()
{
    // Capture Camera Buffer
    AVCaptureSession *_captureSession;
    UIImageView *_imageView;
    AVCaptureVideoPreviewLayer *_prevLayer;
    AVCaptureMovieFileOutput *MovieFileOutput;      // File where save a record
    AVCaptureDeviceInput *VideoInputDevice;         // Capture input
    AVCaptureVideoDataOutput *captureOutput;
    
    cv::Mat m_frame;
    size_t m_frameHeight, m_frameWidth;
    CVImageBufferRef m_imageBuffer;
    
    UIDeviceOrientation m_orientation;
    AVCaptureDevicePosition m_position;
}
/////////
// Properties
/////////

// Buffer Camera

/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;

/*!
 @brief	The UIImageView we use to display the image generated from the imageBuffer
 */
@property (nonatomic, retain) UIImageView *imageView;
/*!
 @brief	The CALayer we use to display the CGImageRef generated from the imageBuffer
 */
@property (nonatomic, retain) CALayer *customLayer;
/*!
 @brief	The CALAyer customized by apple to display the video corresponding to a capture session
 */
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;
@end

@implementation OOCameraController


// Camera Buffer
@synthesize captureSession = _captureSession;
@synthesize imageView = _imageView;
@synthesize customLayer = _customLayer;
@synthesize prevLayer = _prevLayer;
@synthesize delegate;


// Buttons


#pragma mark -
#pragma mark Initialization
- (id)init 
{
	self = [super init];
	if (self) 
    {
		/*We initialize some variables (they might be not initialized depending on what is commented or not)*/
		self.imageView = nil;
		self.prevLayer = nil;
		self.customLayer = nil;
        self->m_orientation = UIDeviceOrientationPortrait;
	}
	return self;
}


- (void)viewDidLoad 
{
    
    // Initialize Engine
    // Hide Status Bar?
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    
	/*We intialize the capture*/
	[self initCapture];
}


/**
 *  Init all inputs, outputs, and subviews
 */
- (void)initCapture 
{ 
    
    /* 1º create a capture session */
    
	self.captureSession = [[AVCaptureSession alloc] init];
    
    
    
    
	/* 2º Create, output */
    
    
	captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // Configure output
    
	/*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
	 If you don't want this behaviour set the property to NO */
    
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
	/*We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
	 in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	 In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	 we are not able to process more than 10 frames per second.*/
	//captureOutput.minFrameDuration = CMTimeMake(1, 10);
	
	/*We create a serial queue to handle the processing of our frames*/
     
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	///dispatch_release(queue);
    
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[captureOutput setVideoSettings:videoSettings];      
     
       	   
	/* 3º Add output to Capture Session */
    
    [self.captureSession addOutput:captureOutput];
    
    /* 4º Configure session */
    
    //SET THE CONNECTION PROPERTIES (output properties)
	[self CameraSetOutputProperties];
    
    /*Medium quality, less resources; High quality: 720p resolution --> More resources.*/
    
    NSString *deviceType = [UIDevice currentDevice].model;
    // Context Video Resolution
    if([deviceType isEqualToString:@"iPhone"])
    {
        //[self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
        //[self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    else 
    {
        // [self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
        // OPTIMIZATION Resolution
        //[self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        //[self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    } 

    
    // OPTIMIZATION Auto-Orientation & Max Framerate
    AVCaptureConnection * connection = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection) {
        if ([connection isVideoMirroringSupported])
        {
            NSLog(@"isVideoMirroringSupported");
            connection.videoMirrored = YES;
        }
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    /* 5º Configure view and layers */
    
    
    self.view.backgroundColor = [UIColor clearColor];
    
	/* 6º Start the capture*/
	[self.captureSession startRunning];
    
    
    // NOTE: This is set after the session start running, because the camera initialization orientationis different after and before this call //
    /* 7º Capture device, input: VIDEO */
    AVCaptureDevice *VideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (VideoDevice)
    {
        [self setCameraWithPosition:AVCaptureDevicePositionFront];
    }
    else
    {
        NSLog(@"Couldn't create video capture device");
    }
	
}

// OPTIMIZATION Auto-Orientation
-(void) adjustCaptureCameraOrientation
{
    NSLog(@"adjustCaptureCameraOrientation1");
    UIDeviceOrientation ori = [[UIDevice currentDevice] orientation];
    AVCaptureConnection *previewLayerConnection=[captureOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([previewLayerConnection isVideoOrientationSupported])
    {
        switch (ori)
        {
            case UIInterfaceOrientationPortrait:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIInterfaceOrientationLandscapeRight:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight]; //home button on right. Refer to .h not doc
                break;
            case UIInterfaceOrientationLandscapeLeft:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft]; //home button on left. Refer to .h not doc
                break;
            default:
                [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait]; //for portrait upside down. Refer to .h not doc
                break;
        }
    }
}

-(void) adjustCaptureCameraOrientation:(UIDeviceOrientation)ori
{
    NSLog(@"adjustCaptureCameraOrientation2");
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: ori] forKey:@"orientation"];
}

- (void) setCameraOrientation:(UIDeviceOrientation) ori
{
    m_orientation = ori;
}

- (void) fromUIImageToCVMat
{
    //Lock the image buffer
    CVPixelBufferLockBaseAddress(m_imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(m_imageBuffer);
    m_frameWidth = CVPixelBufferGetWidth(m_imageBuffer);
    m_frameHeight = CVPixelBufferGetHeight(m_imageBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(m_imageBuffer);
    
    // Generate cv::Mat object with the contain of the buffer
    m_frame = cv::Mat(m_frameHeight, m_frameWidth, CV_8UC4, (void*)baseAddress, stride);
    //NSLog(@"Camera Resolution Size: %d %d", m_frameHeight, m_frameWidth );
    
    // Reorientation for the frontal camera
    if( m_position == AVCaptureDevicePositionFront )
    {
        switch (m_orientation) {
            case UIDeviceOrientationPortrait:
                m_frame = m_frame.t();
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                break;
            case UIDeviceOrientationLandscapeLeft:
                flip(m_frame, m_frame, 1);
                break;
            case UIDeviceOrientationLandscapeRight:
                flip(m_frame, m_frame, 0);
                break;
            default:
                break;
        }
    }
    else if( m_position == AVCaptureDevicePositionBack )
    {
        // Reorientation of the frame for the back camera
        switch (m_orientation) {
            case UIDeviceOrientationPortrait:
                m_frame = m_frame.t();
                flip(m_frame, m_frame, 1);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                break;
            case UIDeviceOrientationLandscapeLeft:
                flip(m_frame, m_frame, 0);
                flip(m_frame, m_frame, 1);
                break;
            case UIDeviceOrientationLandscapeRight:
                break;
            default:
                break;
        }
    }
    
    //We unlock the image buffer
    CVPixelBufferUnlockBaseAddress(m_imageBuffer,0);
}

#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection
{
    [delegate frameCapturedWithRef:sampleBuffer];
}


- (AVCaptureVideoOrientation) videoOrientation
{
    NSLog(@"Warning  - cannot find AVCaptureConnection object");
    return AVCaptureVideoOrientationPortrait;
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload 
{
    self.captureSession = nil;
	self.imageView = nil;
	self.customLayer = nil;
	self.prevLayer = nil;
}

// Callbacks from pickers

// Functions

- (IBAction)CameraToggleButtonPressed:(id)sender
{
    [self toggleCamera];
}

- (int) toggleCamera
{
//    [self setCameraWithPosition:AVCaptureDevicePositionFront];
    
    //AVCaptureDevicePosition position = [[VideoInputDevice device] position];
    if (m_position == AVCaptureDevicePositionBack)
    {
        [self setCameraWithPosition:AVCaptureDevicePositionFront];
    }
    else if (m_position == AVCaptureDevicePositionFront)
    {
        [self setCameraWithPosition:AVCaptureDevicePositionBack];
    }
    
    return m_position;
}

- (void) setCameraWithPosition:(AVCaptureDevicePosition) position
{
	//if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1)		//Only do if device has multiple cameras
	{
        NSLog(@"Toggle camera");
        NSError *error;
        AVCaptureDeviceInput *NewVideoInput;
        //AVCaptureDevicePosition position = [[VideoInputDevice device] position];
        m_position = position;
        
        //NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
        NewVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self CameraWithPosition:position] error:&error];
        
        if (NewVideoInput != nil)
        {
            [_captureSession beginConfiguration];		//We can now change the inputs and output configuration.  Use commitConfiguration to end
            [_captureSession removeInput:VideoInputDevice];
            if ([_captureSession canAddInput:NewVideoInput])
            {
                [_captureSession addInput:NewVideoInput];
                VideoInputDevice = NewVideoInput;
            }
            else
            {
                [_captureSession addInput:VideoInputDevice];
            }
            
            //Set the connection properties again
            [self CameraSetOutputProperties];
            
            [_captureSession commitConfiguration];
        }
	}
}

//********** GET CAMERA IN SPECIFIED POSITION IF IT EXISTS **********

- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position
{
	NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *Device in Devices)
	{
		if ([Device position] == Position)
		{
			return Device;
		}
	}
	return nil;
}

//********** CAMERA SET OUTPUT PROPERTIES **********
- (void) CameraSetOutputProperties
{
	//SET THE CONNECTION PROPERTIES (output properties)
	AVCaptureConnection *CaptureConnection = [MovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
	//Set landscape (if required)
//	if ([CaptureConnection isVideoOrientationSupported])
//	{
//		AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;		//<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
//		[CaptureConnection setVideoOrientation:orientation];
//	}
    [CaptureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
	//Set frame rate (if requiered)
//	CMTimeShow(CaptureConnection.videoMinFrameDuration);
//	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
//    
//	if (CaptureConnection.supportsVideoMinFrameDuration)
//		CaptureConnection.videoMinFrameDuration = CMTimeMake(1, OO_CAPTURE_FRAMES_PER_SECOND);
//	if (CaptureConnection.supportsVideoMaxFrameDuration)
//		CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, OO_CAPTURE_FRAMES_PER_SECOND);
//    
//	CMTimeShow(CaptureConnection.videoMinFrameDuration);
//	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}


- (void)setBoundsLayer:(float)x:(float)y:(float)width:(float)height
{
    self.prevLayer.bounds = CGRectMake(x, y, width, height);
    self.prevLayer.frame = self.prevLayer.bounds;
}
@end

