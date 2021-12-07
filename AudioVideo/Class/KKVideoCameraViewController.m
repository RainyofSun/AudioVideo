//
//  KKVideoCameraViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/8/13.
//

#import "KKVideoCameraViewController.h"
#import "GPUImageVideoCamera.h"
#import "GPUImageOutput.h"
#import "GPUImageView.h"
#import "GPUImageBilateralFilter.h"

@interface KKVideoCameraViewController ()

@property (nonatomic,strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic,strong) GPUImageOutput<GPUImageInput> *videoOutput;
@property (nonatomic,strong) GPUImageView *renderLayer;

@end

@implementation KKVideoCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.videoCamera.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    self.videoCamera.horizontallyMirrorRearFacingCamera = YES;
    
    self.videoOutput = [[GPUImageBilateralFilter alloc] init];
    [self.videoCamera addTarget:self.videoOutput];
    
    self.renderLayer = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.renderLayer];
    [self.videoOutput addTarget:self.renderLayer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.videoCamera startCameraCapture];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.videoCamera stopCameraCapture];
    [self.videoOutput removeAllTargets];
    [self.videoCamera removeAllTargets];
    self.videoOutput = nil;
    self.videoCamera = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
