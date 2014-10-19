//
//  ViewController.h
//  dLapse
//
//  Created by Tristan Wright on 9/27/14.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>{
    UIImageView * imageView;
    UIButton * startStopButton;
    UILabel * frameCaptureRateOut, *capturedFrames;
    UIStepper * stepper;
    UISlider * brightnessSlider;
    
    NSString * cwd;
}

@property (nonatomic) NSTimer * ticker;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

