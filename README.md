# Vision Framework ObjC Sample
This is a sample project to show the performance and behaviour of the Vision framework published by Apple.

When the application is started, the front camera is loaded and the frames captured from this camera are processed sequentialy. The results of the rectangle and landmark detection are painted on the processed frame, and shown in the screen using OpenGL rendering features.

The detection works whith the device in landscape orientation (with the home button in the left side) because of the orientation of the captured image.

Only Objective-C code is used (no Swift functions).
OpenCV Library is also used to show the final result in the image.

To succesfully run the application, you have to download and uncompress the opencv framework in the root directory (same as this readme file) from 'https://sourceforge.net/projects/opencvlibrary/files/opencv-ios/3.3.1/opencv-3.3.1-ios-framework.zip/download'.

Any comment or contribution is wellcome.
