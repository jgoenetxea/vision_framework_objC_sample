//
//  OOViulibViewController.m
//
//  Created by Victor Goñi on 07/11/13.
//  Copyright (c) 2013 VictorTech. All rights reserved.
//

#import "OOMainViewController.h"

#import "MBProgressHUD.h"

#import <Vision/Vision.h>

@interface OOMainViewController ()
{
    CVImageBufferRef m_cvImage;
    CIImage *m_ciImage;
    VNDetectFaceRectanglesRequest *m_faceRectanglesReq;
    VNDetectFaceLandmarksRequest *m_faceLandmarksReq;
    NSDictionary *m_d;
    VNImageRequestHandler *m_handler;
    float m_width, m_height, m_x, m_y;
}
@end

@implementation OOMainViewController

@synthesize cameraController = _cameraController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        m_faceRectanglesReq = [VNDetectFaceRectanglesRequest new];
//        m_faceLandmarksReq = [VNDetectFaceLandmarksRequest new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"--- Initial view did load; Initing...");
    _isFirstTime = true;
    [self initInterface];
    [self initViulibEngine];
    NSLog(@"--- Initial view did load; Initing done!");
    
}

- (void)dealloc
{
    // Declare camera manager and opengl context
    _cameraController = nil;
    
    // Views
    customCameraView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Function:       initInterface
 *  Description:    First step to load Viulib Singleton with all necessary elements
 */
-(void)initInterface
{
    NSLog(@"Initing View Interface...");

    NSLog(@"UI initialization");
    // Alloc View
    if( customCameraView == nil )
    {
        NSLog(@"Creating camera view...");
        // Generate camera controller instance
        customCameraView = [[UIView alloc] init];
        
        if( _cameraController == nil )
        {
            // Alloc Controllers
            _cameraController = [[OOCameraController alloc] init];
            [_cameraController setDelegate:self];
        }
        
        // Add the camera controller to the tree. Is necesary to add the view to the tree in order to be called for each frame
        [customCameraView addSubview:_cameraController.view];
        [self.view addSubview:customCameraView];
        [self.view bringSubviewToFront:customCameraView];
    }
    
    //UIDeviceOrientation ori = UIDeviceOrientationLandscapeLeft;
    UIDeviceOrientation ori = UIDeviceOrientationPortrait;
    //UIDeviceOrientation ori = UIDeviceOrientationLandscapeRight;
    [self setViewOrientation:ori];
    
    NSLog(@"Initing View Interface done!");
}


/**
 *  Function:       initViulibEngine
 *  Description:    Initiates the engine to be used later
 */
- (void) initViulibEngine
{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"])
    {
        // InitSize
        NSLog(@"iPhone detected");
        
        [_cameraController adjustCaptureCameraOrientation:UIDeviceOrientationPortrait];
    }

}


- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait /*| UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight*/;
}

-(BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark -
#pragma mark NewFrameDelegate

- (void) frameCapturedWithRef:(CMSampleBufferRef) samplebuf
{
    // options: (0) rect detection, (1) landmark detection
    const int opt = 1;
    
    dispatch_sync( dispatch_get_main_queue(),
      ^{
          // m_native->processFrame(frame);
          // Transform the image type to a CIImage type
          m_cvImage = CMSampleBufferGetImageBuffer(samplebuf);
          m_ciImage = [[CIImage alloc] initWithCVPixelBuffer:m_cvImage];
          
          m_faceRectanglesReq = [VNDetectFaceRectanglesRequest new];
          m_faceLandmarksReq = [VNDetectFaceLandmarksRequest new];
          
          //create req
          m_d = [[NSDictionary alloc] init];
          //req handler
          m_handler = [[VNImageRequestHandler alloc] initWithCIImage:m_ciImage
                                                             options:m_d];
          
          if (opt == 0) {
              // Find the rectangles
              [m_handler performRequests:@[m_faceRectanglesReq] error:nil];
          } else if (opt == 1) {
              [m_handler performRequests:@[m_faceLandmarksReq] error:nil];
          }
          
          
          // Get the opencv type image
          CVPixelBufferLockBaseAddress(m_cvImage, 0);
          uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(m_cvImage);
          float frameWidth = CVPixelBufferGetWidth(m_cvImage);
          float frameHeight = CVPixelBufferGetHeight(m_cvImage);
          size_t stride = CVPixelBufferGetBytesPerRow(m_cvImage);
          cv::Mat frame = cv::Mat(frameHeight, frameWidth, CV_8UC4,
                                  (void*)baseAddress, stride);
          CVPixelBufferUnlockBaseAddress(m_cvImage, 0);
          // Correct frame channel ammounr
          switch (frame.channels())
          {
              case 1:
                  cv::cvtColor(frame, frame, CV_GRAY2BGRA);
                  break;
                  
              case 2:
                  cv::cvtColor(frame, frame, CV_BGR5652BGRA);
                  break;
                  
              case 3:
                  cv::cvtColor(frame, frame, CV_RGB2RGBA);
                  break;
          };
          
          // Pait the rectangles in the image
          if (opt == 0) {
              for(VNFaceObservation *observation in m_faceRectanglesReq.results) {
                  if(observation){
                      CGRect boundingBox = observation.boundingBox;
                      m_width = boundingBox.size.width * frame.cols;
                      m_height = boundingBox.size.height * frame.rows;
                      m_x = boundingBox.origin.x * frame.cols;
                      m_y = (1 - boundingBox.origin.y) * frame.rows - m_height;
                      cv::Rect r(m_x, m_y, m_width, m_height);
                      cv::rectangle(frame, r, cv::Scalar(0, 255, 0, 255));
                  }
              }
          } else if (opt == 1) {
              for(VNFaceObservation *observation in m_faceLandmarksReq.results) {
                  if(observation){
                      // Draw rect
                      CGRect boundingBox = observation.boundingBox;
                      m_width = boundingBox.size.width * frame.cols;
                      m_height = boundingBox.size.height * frame.rows;
                      m_x = boundingBox.origin.x * frame.cols;
                      m_y = (1 - boundingBox.origin.y) * frame.rows - m_height;
                      cv::Rect r(m_x, m_y, m_width, m_height);
                      cv::rectangle(frame, r, cv::Scalar(0, 255, 0, 255));
                      
                      // Draw landmarks
                      const CGPoint* lands = observation.landmarks.allPoints.normalizedPoints;
                      for (int i = 0; i < 65; ++i) {
                          // NSLog(@"*(p + %d) : %f\n",  i, *(p + i) );
                          const CGPoint* l = (lands + i);
                          cv::Point p(l->x * m_width + m_x,
                                      (1 - l->y) * m_height + m_y);
                          cv::circle(frame, p, 6, cv::Scalar(0, 0, 255, 255), -1);
                      }
                  }
              }
          }
          frame = frame.t();
          // Show the result in the screen
          [_renderView renderFrame:frame];
//
      });
}


//***************************************************************//
//****          SMALL INTERFACE                             *****//
//***************************************************************//
-(int) switchCamera
{
    return [_cameraController toggleCamera];
}

-(void) setViewOrientation:(UIDeviceOrientation) ori
{
    [_cameraController setCameraOrientation:ori];
    [_renderView setRenderOrientation:ori];
}

@end
