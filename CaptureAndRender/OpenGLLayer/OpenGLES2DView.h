//
//  OpenGLES2DView.h
//  GLFun
//
//  Created by Jeff LaMarche on 8/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface OpenGLES2DView : UIView {
    
    GLuint _program;
    
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    bool m_isLansdcape;
    
@protected
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    EAGLContext *context;
    GLuint viewRenderbufferPort, viewFramebufferPort, depthRenderBufferPort;
    CAEAGLLayer *eaglLayer;
    GLuint backgroundTextureId;
    GLint framebufferWidth, framebufferHeight;
    
    GLfloat textureVertices[8];
}

- (void)renderFrame:(cv::Mat&) frame;
- (void) setRenderOrientation:(UIDeviceOrientation) ori;

@property (nonatomic, retain) CADisplayLink * displayLink;

@end
