//
//  OpenGLES2DView.m
//  GLFun
//
//  Created by Jeff LaMarche on 8/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OpenGLES2DView.h"

@implementation OpenGLES2DView

//************************************//
// Add new method before init
- (void)setupDisplayLink
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    _displayLink.frameInterval = 2;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setupDisplayLink];
        self->m_isLansdcape = false;
    }
    
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)renderFrame:(cv::Mat&) frame
{
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glBindTexture(GL_TEXTURE_2D, backgroundTextureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_BGRA, GL_UNSIGNED_BYTE, frame.data);
}

//- (void)draw
// This function is called every frame interval by the system
- (void)render:(CADisplayLink*)displayLink
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glEnable(GL_DEPTH_TEST);
    
    [self draw];
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
    glFlush();
}

//***************************************//


+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder
{
    if((self = [super initWithCoder:coder]))
    {
        m_isLansdcape = true;
        [self setRenderOrientation:UIDeviceOrientationPortrait];
        // Get the layer
        eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,  kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];
        
        
        framebufferWidth = self.frame.size.width;
        framebufferHeight = self.frame.size.height;
        [self initContext];
        
        // init display link
        [self setupDisplayLink];
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
        [context presentRenderbuffer:GL_RENDERBUFFER];
        glBindBuffer (GL_ARRAY_BUFFER, 0);
        glFlush();
    }
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];
    
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    [_displayLink invalidate];
    _displayLink = nil;
}


#pragma mark -
- (BOOL)createFramebufferPortrait
{
    // Generate the depth buffer for the render
    glGenRenderbuffers(1, &depthRenderBufferPort);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBufferPort);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
    
	// Generate the render buffer for the render
    glGenRenderbuffers(1, &viewRenderbufferPort);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbufferPort);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer]; 
    
    // Generate the frame buffer for the render
    glGenFramebuffers(1, &viewFramebufferPort);
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebufferPort);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbufferPort);
       
    // Add the depth buffer to the rendering buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBufferPort);
    
    switch(glCheckFramebufferStatus(GL_FRAMEBUFFER))
	{
		case GL_FRAMEBUFFER_COMPLETE:
			printf("Framebuffer OK\n");
            break;
		case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
			printf("Framebuffer incomplete attachment\n");
            break;
		case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
			printf("Framebuffer incomplete missing attachment\n");
            break;
		case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
			printf("Framebuffer incomplete dimensions\n");
            break;
		case GL_FRAMEBUFFER_UNSUPPORTED:
			printf("Framebuffer unsuported\n");
            break;
	}

	return YES;
}



- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if(eaglLayer)
        {
            eaglLayer = nil;
        }
        
        if(viewFramebufferPort)   glDeleteFramebuffers ( 1, &viewFramebufferPort   );
        if(depthRenderBufferPort) glDeleteRenderbuffers( 1, &depthRenderBufferPort );
        if(viewRenderbufferPort)  glDeleteRenderbuffers( 1, &viewRenderbufferPort  );
        
        NSLog(@"Framebuffer deleted");
    }
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        context = newContext;
        
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)setFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (!viewFramebufferPort)
            [self createFramebufferPortrait];
        
        glBindFramebuffer(GL_FRAMEBUFFER, viewFramebufferPort);
        glViewport(0, 0, framebufferWidth, framebufferHeight);
        
        glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
        
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbufferPort);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)initContext
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!context)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:context])
        NSLog(@"Failed to set ES context current");
    
    [self setContext:context];
    [self setFramebuffer];
    
    glGenTextures(1, &backgroundTextureId);
    glBindTexture(GL_TEXTURE_2D, backgroundTextureId);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void) setRenderOrientation:(UIDeviceOrientation) ori
{
    switch (ori)
    {
        case UIDeviceOrientationPortrait:
//            GLfloat uv[] =
//            {
//                0, 1,
//                1, 1,
//                0, 0,
//                1, 0
//            };
            textureVertices[0] = 0;
            textureVertices[1] = 1;
            textureVertices[2] = 1;
            textureVertices[3] = 1;
            textureVertices[4] = 0;
            textureVertices[5] = 0;
            textureVertices[6] = 1;
            textureVertices[7] = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
//            GLfloat uv[] =
//            {
//                0, 0,
//                0, 1,
//                1, 0,
//                1, 1
//            };
            textureVertices[0] = 0;
            textureVertices[1] = 0;
            textureVertices[2] = 0;
            textureVertices[3] = 1;
            textureVertices[4] = 1;
            textureVertices[5] = 0;
            textureVertices[6] = 1;
            textureVertices[7] = 1;
            break;
        case UIDeviceOrientationLandscapeRight:
//            GLfloat uv[] =
//            {
//                1, 1,
//                1, 0,
//                0, 1,
//                0, 0
//            };
            textureVertices[0] = 1;
            textureVertices[1] = 1;
            textureVertices[2] = 1;
            textureVertices[3] = 0;
            textureVertices[4] = 0;
            textureVertices[5] = 1;
            textureVertices[6] = 0;
            textureVertices[7] = 0;
            break;
        default:
            break;
    }
}

- (void)draw
{
    [self setFramebuffer];
    
    //    static const GLfloat squareVertices[] =
    //    {
    //        -1, -1,
    //        +1, -1,
    //        -1, +1,
    //        +1, +1
    //    };
    //
    //    static GLfloat textureVertices[] =
    //    {
    //        0, 1,
    //        1, 1,
    //        0, 0,
    //        1, 0
    //    };
    
    static const GLfloat squareVertices[] =
    {
        -1, -1,
        +1, -1,
        -1, +1,
        +1, +1
    };
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glDisable(GL_COLOR_MATERIAL);
    
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, backgroundTextureId);
    
    // Update attribute values.
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, textureVertices);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glColor4f(1,1,1,1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    
    bool ok = [self presentFramebuffer];
    assert(ok);
}

@end
