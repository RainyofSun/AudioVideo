//
//  CameraView.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import "PreviewView.h"
#import "OverLayView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraView : UIView

@property (nonatomic,strong) PreviewView *previewView;
@property (nonatomic,strong) OverLayView *controlsView;

@end

NS_ASSUME_NONNULL_END
