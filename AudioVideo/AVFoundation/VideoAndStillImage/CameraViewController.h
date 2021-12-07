//
//  CameraViewController.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraControllerDelegate <NSObject>

- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

@interface CameraViewController : UIViewController

@property (nonatomic,weak) id<CameraControllerDelegate> cameraDelegate;
@property (nonatomic,strong,readonly) AVCaptureSession *captureSession;

- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;

@property (nonatomic,readonly) NSUInteger cameraCount;
@property (nonatomic,readonly) BOOL cameraHasTorch; // 手电筒
@property (nonatomic,readonly) BOOL cameraHasFlash; // 闪光灯
@property (nonatomic,readonly) BOOL cameraSupportsTapFocus; // 聚焦
@property (nonatomic,readonly) BOOL cameraSupportsTapExpose;    // 曝光
@property (nonatomic) AVCaptureTorchMode torchMode; // 手电筒模式
@property (nonatomic) AVCaptureFlashMode flashMode; // 闪光灯模式

- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

- (void)captureStillImage; // 捕捉静态图片
- (void)startRecording; // 开始录制
- (void)stopRecording;  // 关闭录制
- (BOOL)isRecording;    // 录制状态
- (CMTime)recordedDuration; // 录制时间

@end

NS_ASSUME_NONNULL_END
