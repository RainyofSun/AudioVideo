//
//  CameraModeView.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CameraMode) {
    CameraMode_Photo,
    CameraMode_Video
};

@interface CameraModeView : UIControl

@property (nonatomic,assign) CameraMode cameraMode;

- (void)setThumbImg:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
