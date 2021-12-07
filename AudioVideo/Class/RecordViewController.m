//
//  RecordViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/29.
//

#import "RecordViewController.h"
#import "CameraViewController.h"
#import "CameraView.h"
#import "PreviewView.h"
#import "OverLayView.h"
#import "CameraModeView.h"
#import "StatusView.h"
#import "FlashControlView.h"
#import "NSTimer+Additions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CaptureButton.h"

@interface RecordViewController ()<UINavigationControllerDelegate,PreviewViewDelegate>

@property (nonatomic,strong) CameraView *cameraView;

@property (nonatomic,assign) CameraMode cameraMode;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) CameraViewController *cameraController;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self addNotification];
    [self setupSession];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.delegate = self;
    
    CGRect viewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.cameraView = [[CameraView alloc] initWithFrame:viewFrame];
    
    [self.view addSubview:self.cameraView];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThumbnail:) name:ThumbnalCreatedNotification object:nil];
}

- (void)setupSession {
    self.cameraMode = CameraMode_Video;
    self.cameraController = [[CameraViewController alloc] init];
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        [self.cameraView.previewView setSession:self.cameraController.captureSession];
        self.cameraView.previewView.delegate = self;
        [self.cameraController startSession];
    } else {
        NSLog(@"ERROR : %@",error.localizedDescription);
    }
    
    self.cameraView.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapFocus;
    self.cameraView.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapExpose;
}

#pragma mark - Notification
- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *thumbImg = notification.object;
    [self.cameraView.controlsView.modeView setThumbImg:thumbImg];
}

#pragma mark - Target
// 开始录制/拍照
- (void)startCaptureOrRecorded:(CaptureButton *)sender {
    if (self.cameraMode == CameraMode_Photo) {
        [self.cameraController captureStillImage];
    } else if (self.cameraMode == CameraMode_Video) {
        if (!self.cameraController.isRecording) {
            dispatch_async(dispatch_queue_create("com.nice.camera", NULL), ^{
                [self.cameraController startRecording];
                [self startTimer];
            });
        } else {
            [self.cameraController stopRecording];
            [self stopTimer];
        }
    }
    sender.selected = !sender.selected;
}

// 反转相机
- (void)swapCameras {
    if ([self.cameraController switchCameras]) {
        BOOL hidden = NO;
        if (self.cameraMode == CameraMode_Photo) {
            hidden = !self.cameraController.cameraHasFlash;
        } else {
            hidden = !self.cameraController.cameraHasTorch;
        }
        
        self.cameraView.controlsView.flashControlHidden = hidden;
        self.cameraView.previewView.tapToExposeEnabled = self.cameraController.cameraSupportsTapExpose;
        self.cameraView.previewView.tapToFocusEnabled = self.cameraController.cameraSupportsTapFocus;
        [self.cameraController resetFocusAndExposureModes];
    }
}

// 视频录制/拍照
- (void)cameraModeChanged:(CameraModeView *)cameraMode {
    self.cameraMode = [cameraMode cameraMode];
}

// 点击缩略图跳转相册
- (void)showCameraAlbum {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    [self presentViewController:pickerController animated:YES completion:nil];
}

// 改变闪光灯/手电筒模式
- (void)flashControlChanged:(FlashControlView *)sender {
    NSUInteger mode = [sender selectedMode];
    if (self.cameraMode == CameraMode_Photo) {
        self.cameraController.flashMode = mode;
    } else if (self.cameraMode == CameraMode_Video) {
        self.cameraController.torchMode = mode;
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

#pragma mark - PreviewViewDelegate
- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
}

- (void)tappedToExposeAtPoint:(CGPoint)point {
    [self.cameraController exposeAtPoint:point];
}

-(void)tappedResetFocusAndExposure {
    [self.cameraController resetFocusAndExposureModes];
}

#pragma mark - timer
- (void)startTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTimeDisplay:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay:(NSTimer *)timer {
    CMTime duration = self.cameraController.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    NSUInteger hours = time / 3600;
    NSUInteger minutes = (time/60)%60;
    NSUInteger seconds = time % 60;
    
    NSString *formate = @"%02i:%02i:%02i";
    NSString *timeStr = [NSString stringWithFormat:formate,hours,minutes,seconds];
    self.cameraView.controlsView.statusView.elapsedTimeLabel.text = timeStr;
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        self.cameraView.controlsView.statusView.elapsedTimeLabel.text = @"00:00:00";
    }
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
