//
//  CameraView.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import "CameraView.h"

@implementation CameraView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    [self setupCameracontrolsView:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
}

- (void)setupCameracontrolsView:(CGRect)viewFrame {
    self.previewView = [[PreviewView alloc] initWithFrame:viewFrame];
    self.controlsView = [[OverLayView alloc] initWithFrame:viewFrame];
    
    [self addSubview:self.previewView];
    [self addSubview:self.controlsView];
}

@end
