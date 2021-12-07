//
//  StatusView.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import "FlashControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusView : UIView<FlashControlDelegate>

@property (nonatomic,strong) FlashControlView *flashControl;
@property (nonatomic,strong) UILabel *elapsedTimeLabel;
@property (nonatomic,strong) UIButton *switchCameraButton;

@end

NS_ASSUME_NONNULL_END
