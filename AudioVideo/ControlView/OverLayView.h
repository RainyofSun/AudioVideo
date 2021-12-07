//
//  OverLayView.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import "CameraModeView.h"
#import "StatusView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverLayView : UIView

@property (nonatomic,strong) CameraModeView *modeView;
@property (nonatomic,strong) StatusView *statusView;
@property (nonatomic,assign) BOOL flashControlHidden;

@end

NS_ASSUME_NONNULL_END
