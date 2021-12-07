//
//  CameraViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import "CameraViewController.h"

@interface CameraViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic,strong) dispatch_queue_t videoQueue;   // 视频队列
@property (nonatomic,strong) AVCaptureSession *captureSession;  // 捕捉会话
@property (nonatomic,weak) AVCaptureDeviceInput *activeVideoInput;  // 输入
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic,strong) NSURL *outputURL;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
}

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (BOOL)setupSession:(NSError **)error {
    // 创建会话
    self.captureSession = [[AVCaptureSession alloc] init];
    // 设置图像分辨率
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    // 获取设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 将捕捉设备封装成 deviceInput
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    // 配置输出格式
    self.imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    self.videoQueue = dispatch_queue_create("LR.VideoQueue", NULL);
    return YES;
}

- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - 摄像头支持的方法
- (AVCaptureDevice *)cameraWithPositions:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    // 查找当前激活摄像头的反向摄像头
    AVCaptureDevice *inactiveDevice = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            inactiveDevice = [self cameraWithPositions:AVCaptureDevicePositionFront];
        } else {
            inactiveDevice = [self cameraWithPositions:AVCaptureDevicePositionBack];
        }
    }
    return inactiveDevice;
}

- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras {
    if (![self canSwitchCameras]) {
        return NO;
    }
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (deviceInput) {
        // 标注原配置发生变化
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:deviceInput]) {
            [self.captureSession addInput:deviceInput];
            self.activeVideoInput = deviceInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
            [self.cameraDelegate deviceConfigurationFailedWithError:error];
            return NO;
        }
    }
    return YES;
}

#pragma mark - 聚焦
- (BOOL)cameraSupportsTapFocus {
    // 询问激活中的摄像头是否支持兴趣点对焦
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    // 是否支持兴趣点对焦 / 是否支持自动对焦模式
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                [self.cameraDelegate deviceConfigurationFailedWithError:error];
            }
        }
    }
}

#pragma mark - 点击曝光的方法
- (BOOL)cameraSupportsTapExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *cameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        [device isExposureModeSupported:exposureMode];
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            // 判断设备是否支持锁定曝光模式
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                // 使用KVO的方式确定设备的状态
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&cameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        } else {
            if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                [self.cameraDelegate deviceConfigurationFailedWithError:error];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &cameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        // 判断设备是否不再调整曝光等级,确认设备的exposureMode是否可以设置为AVCaptureExposureModeLocked
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            // 移除作为 adjustingExposure 的self,就不会得到后续变更的通知
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&cameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                        [self.cameraDelegate deviceConfigurationFailedWithError:error];
                    }
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 重新设置对焦和曝光
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    // 获取对焦兴趣点 和 连续自动对焦模式 是否支持
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    // 确认曝光度可以被重新设置
    BOOL canResetExpose = [device isFocusPointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5, 0.5);
    NSError *error;
    
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExpose) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
    } else {
        if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
            [self.cameraDelegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - 闪光灯 & 手电筒
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isTorchModeSupported:torchMode]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
    } else {
        if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
            [self.cameraDelegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - 拍摄静态图片
- (void)captureStillImage {
    // 获取链接
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    // 判断是否支持视频方向
    if (connection.isVideoOrientationSupported) {
        // 获取方向值
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    // 定义handler 块,返回1个图片的NSData 值
    id handler = ^(CMSampleBufferRef sampleBuffer,NSError *error) {
        if (sampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self writeImageToAssetsLibrary:image];
        } else {
            NSLog(@"NUll sampleBuffer %@",[error localizedDescription]);
        }
    };
    // 捕捉静态图片
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
}

// 获取方向值
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

- (void)writeImageToAssetsLibrary:(UIImage *)image {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self postThumbnailNotification:image];
        } else {
            NSLog(@"Save Image Error %@",[error localizedDescription]);
        }
    }];
}

- (void)postThumbnailNotification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ThumbnalCreatedNotification object:image];
    });
}

#pragma mark - 捕捉视频
- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

- (void)startRecording {
    if (![self isRecording]) {
        // 获取当前视频捕捉连接信息
        AVCaptureConnection *videoConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([videoConnection isVideoOrientationSupported]) {
            // 支持修改当前视频方向
            videoConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        // 判断是否支持视频稳定,可以提高视频质量 如果支持防抖就打开防抖
        if ([videoConnection isVideoStabilizationSupported]) {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
        
        AVCaptureDevice *device = [self activeCamera];
        // 摄像头可以平滑进行对焦模式操作，即减慢摄像头镜头对焦速度。当用户移动拍摄时摄像头会尝试快速自动对焦
        if (device.isSmoothAutoFocusEnabled) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            } else {
                if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                    [self.cameraDelegate deviceConfigurationFailedWithError:error];
                }
            }
        }
        
        // 查找写入捕捉视频的唯一文件系统URL
        self.outputURL = [self uniqueURL];
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
    }
}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

- (NSURL *)uniqueURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *direPath = [fileManager temporaryDirectoryWithTemplateString:nil];
    if (direPath) {
        NSString *filePath = [direPath stringByAppendingPathComponent:@"camera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (void)stopRecording {
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (error) {
        if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
            [self.cameraDelegate deviceConfigurationFailedWithError:error];
        }
    } else {
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    self.outputURL = nil;
}

- (void)writeVideoToAssetsLibrary:(NSURL *)videoUrl {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoUrl]) {
        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;
        completionBlock = ^(NSURL *assetURL,NSError *error) {
            if (error) {
                if (self.cameraDelegate != nil && [self.cameraDelegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                    [self.cameraDelegate deviceConfigurationFailedWithError:error];
                }
            } else {
                [self generateThumbnailForVideoAtURL:videoUrl];
            }
        };
        [library writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:completionBlock];
    }
}

// 获取视频左下角缩略图
- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    dispatch_async(self.videoQueue, ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100, 0);    // 根据视频的宽高比来计算图片的高度
        // 捕捉视频缩略图会考虑视频的变化（如视频方向的变化），如果不设置，缩略图的方向可能会出错
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postThumbnailNotification:image];
        });
    });
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
