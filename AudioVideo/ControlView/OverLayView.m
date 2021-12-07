//
//  OverLayView.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import "OverLayView.h"

@implementation OverLayView

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
    if (@available(iOS 11.0, *)) {
        self.modeView = [[CameraModeView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 110 - [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom, CGRectGetWidth(self.bounds), 110 + [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom)];
        self.statusView = [[StatusView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].keyWindow.safeAreaInsets.top, CGRectGetWidth(self.bounds), 48)];
    } else {
        // Fallback on earlier versions
        self.modeView = [[CameraModeView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 110, CGRectGetWidth(self.bounds), 110)];
        self.statusView = [[StatusView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 48)];
    }
    
    [self.modeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.statusView];
    [self addSubview:self.modeView];
}

- (void)modeChanged:(CameraModeView *)modeView {
    BOOL photoModeEnabled = modeView.cameraMode == CameraMode_Photo;
    UIColor *toColor = photoModeEnabled ? [UIColor colorWithWhite:0 alpha:0.5] : [UIColor clearColor];
    CGFloat opacity = photoModeEnabled ? 0.0f : 1.0f;
    self.statusView.layer.backgroundColor = toColor.CGColor;
    self.statusView.elapsedTimeLabel.layer.opacity = opacity;
    ((void (*) (id, SEL,CameraModeView *)) (void *)objc_msgSend)([self topVC], @selector(cameraModeChanged:),modeView);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.statusView pointInside:[self convertPoint:point toView:self.statusView] withEvent:event] || [self.modeView pointInside:[self convertPoint:point toView:self.modeView] withEvent:event]) {
        return YES;
    }
    return NO;
}

- (void)setFlashControlHidden:(BOOL)flashControlHidden {
    if (_flashControlHidden != flashControlHidden) {
        _flashControlHidden = flashControlHidden;
        self.statusView.flashControl.hidden = flashControlHidden;
    }
}

@end
