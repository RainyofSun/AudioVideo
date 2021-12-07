//
//  CaptureButton.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CaptureButtonMode) {
    CaptureButtonMode_Photo,
    CaptureButtonMode_Video
};

@interface CaptureButton : UIButton

@property (nonatomic,assign) CaptureButtonMode captureMode;

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(CaptureButtonMode)captureMode;

@end

NS_ASSUME_NONNULL_END
