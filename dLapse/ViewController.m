//
//  ViewController.m
//  dLapse
//
//  Created by Tristan Wright on 9/27/14.
//
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //UI-Initializing
//    imageView = [[UIImageView alloc] init];
//    CGRect iView = CGRectMake(0, 0, 320, 200);
//    imageView.frame = iView;
//    [self.view addSubview:imageView];
    
    startStopButton = [[UIButton alloc] init];
    [startStopButton setBackgroundColor:[UIColor greenColor]];
    [startStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    [startStopButton addTarget:self action:@selector(startLapse:) forControlEvents:UIControlEventTouchUpInside];
    startStopButton.frame = CGRectMake(0, 190, 90, 50);
    [self.view addSubview:startStopButton];
    
    frameCaptureRateOut = [[UILabel alloc] init];
    [frameCaptureRateOut setTextAlignment:NSTextAlignmentCenter];
    [frameCaptureRateOut setBaselineAdjustment:UIBaselineAdjustmentNone];
    [frameCaptureRateOut setTextColor:[UIColor blackColor]];
    frameCaptureRateOut.frame = CGRectMake(100, 190, 100, 20);
    [self.view addSubview:frameCaptureRateOut];
    
    stepper = [[UIStepper alloc] init];
    [stepper setMinimumValue:1.0];
    [stepper setMaximumValue:300.0];
    [stepper setWraps:YES];
    [stepper setValue:5.0];
    [stepper setStepValue:1.0];
    [stepper addTarget:self
                action:@selector(updateFrameRateOut:)
      forControlEvents:UIControlEventValueChanged];
    [frameCaptureRateOut setText:[NSString stringWithFormat:@"%d seconds", (int)stepper.value]];
    stepper.frame = CGRectMake(100, 210, 50, 20);
    [self.view addSubview:stepper];
    
    capturedFrames = [[UILabel alloc] init];
    [capturedFrames setTextAlignment:NSTextAlignmentCenter];
    [capturedFrames setTextColor:[UIColor blackColor]];
    [capturedFrames setText:@""];
    [capturedFrames setLineBreakMode:NSLineBreakByWordWrapping];
    [capturedFrames setNumberOfLines:2];
    capturedFrames.frame = CGRectMake(200, 200, 100, 40);
    [self.view addSubview:capturedFrames];
    
    brightnessSlider = [[UISlider alloc] init];
    brightnessSlider.minimumValue = 0.0f;
    brightnessSlider.maximumValue = 1.0f;
    [brightnessSlider setValue:[[UIScreen mainScreen] brightness] animated: NO];
    [brightnessSlider setContinuous:YES];
    [brightnessSlider addTarget:self
                      action:@selector(changeBrightness)
            forControlEvents:UIControlEventValueChanged];
    brightnessSlider.frame = CGRectMake(5, 250, 180, 20);
    [self.view addSubview:brightnessSlider];
    
    //Camera-Initializing
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    [self setupCaptureSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - image capture

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    AVCaptureSession * session = [[AVCaptureSession alloc] init];
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];

    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    UIView *aView = self.view;
    CGRect videoRect = CGRectMake(0.0, 0.0, 320.0, 150.0);
    previewLayer.frame = videoRect; // Assume you want the preview layer to fill the view.
    [aView.layer addSublayer:previewLayer];
    self.previewLayer = previewLayer;
    
    if (!input){
        NSLog(@"PANIC: no media input");
    }
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([session canAddOutput:stillImageOutput])
    {
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
        [session addOutput:stillImageOutput];
        [self setStillImageOutput:stillImageOutput];
    }
    
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
    
    // Start the session running to start the flow of data
    [session startRunning];
    
    // Assign session to an ivar.
    [self setSession:session];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"captureOutput: didOutputSampleBufferFromConnection");
    
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    //< Add your code here that uses the image >
    [imageView setImage:image];
    [self.view setNeedsDisplay];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    if (error){
        NSLog(@"%@", error);
    }
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    //NSLog(@"imageFromSampleBuffer: called");
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

-(void)setSession:(AVCaptureSession *)session {
    NSLog(@"setting session...");
    //self.session=session;
}

- (void)snapStillImage {
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation: [[[self previewLayer] connection] videoOrientation]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                [self updateFrameCount];
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                //save to camera-roll
                //[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                
                NSData * binaryImageData = UIImagePNGRepresentation(image);
                [binaryImageData writeToFile:[cwd stringByAppendingPathComponent:[self timeStampWithExtension:@".png"]] atomically:YES];
            }
        }];
    });
}

# pragma mark Start/Stop Lapse
-(void)startLapse: (id)sender{
    //self.session.sessionPreset = AVCaptureSessionPresetHigh;
    self.ticker = [NSTimer scheduledTimerWithTimeInterval:stepper.value target:self
                                            selector:@selector(snapStillImage)
                                            userInfo:nil repeats:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    cwd = [NSString stringWithFormat:@"%@/%@", [self baseDirectoryPath], [self timeStampForDirectory]];
    NSError * error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:cwd withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    
    [brightnessSlider setValue:0.0 animated:NO];
    [self changeBrightness];
    
    [capturedFrames setText:@"0"];
    stepper.enabled = NO;
    [self swapButtonBinding: YES];
}

-(void)stopLapse: (id)sender{
    //NSLog(@"Ticker stopped");
    [self.ticker invalidate];
    self.ticker = nil;
    //self.session.sessionPreset = AVCaptureSessionPresetLow;
    [brightnessSlider setValue:0.8 animated:NO];
    [self changeBrightness];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    stepper.enabled = YES;
    [self swapButtonBinding: NO];
}

-(void) swapButtonBinding: (BOOL) isRecording{
    [startStopButton setTitle:(isRecording ? @"Stop" : @"Start") forState:UIControlStateNormal];
    [startStopButton setBackgroundColor:(isRecording ? [UIColor redColor] : [UIColor greenColor])];
    
    [startStopButton removeTarget:self
                           action:(isRecording ? @selector(startLapse:) : @selector(stopLapse:))
                 forControlEvents:UIControlEventTouchUpInside];
    
    [startStopButton addTarget:self
                        action:(isRecording ? @selector(stopLapse:) : @selector(startLapse:))
              forControlEvents:UIControlEventTouchUpInside];
}

# pragma mark View Orientation
// Disable autorotation of the interface when recording is in progress.
- (BOOL)shouldAutorotate{
    return [[[startStopButton titleLabel] text] isEqualToString:@"Start"];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [[[self previewLayer] connection] setVideoOrientation:(AVCaptureVideoOrientation) toInterfaceOrientation];
}

# pragma mark directory methods

-(NSString *) baseDirectoryPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSString *) timeStampForDirectory{
    NSDateFormatter * fmtr = [[NSDateFormatter alloc] init];
        [fmtr setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString * ret  = [[fmtr stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    ret = [ret stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [NSString stringWithFormat:@"%@", ret];
}

- (NSString *) timeStampWithExtension:(NSString*) ext{
    return [NSString stringWithFormat:@"%d%@", (int)[[NSDate date] timeIntervalSince1970], ext];
}


# pragma mark UI methods

-(void) updateFrameRateOut: (id) sender{
    [frameCaptureRateOut setText:[NSString stringWithFormat:@"%d seconds", (int)stepper.value]];
}

-(void) updateFrameCount{
    NSArray * strArray = [[capturedFrames text] componentsSeparatedByString:@" "];
    [capturedFrames setText:[NSString stringWithFormat:@"%d frames captured", [[strArray objectAtIndex: 0] intValue]+1 ]];
}

-(void) changeBrightness{
    [[UIScreen mainScreen] setBrightness:[brightnessSlider value]];
}

@end
