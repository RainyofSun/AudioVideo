//
//  PreviewView.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 预览视图
 */
@protocol PreviewViewDelegate <NSObject>

// 聚焦
- (void)tappedToFocusAtPoint:(CGPoint)point;
// 曝光
- (void)tappedToExposeAtPoint:(CGPoint)point;
// 重置聚焦/曝光
- (void)tappedResetFocusAndExposure;

@end

@interface PreviewView : UIView

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,weak) id<PreviewViewDelegate> delegate;
@property (nonatomic,assign) BOOL tapToFocusEnabled;
@property (nonatomic,assign) BOOL tapToExposeEnabled;

@end

NS_ASSUME_NONNULL_END
