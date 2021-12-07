//
//  StatusView.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import "StatusView.h"

@implementation StatusView

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
    self.flashControl = [[FlashControlView alloc] initWithFrame:CGRectZero];
    self.flashControl.frameX = 16;
    self.flashControl.frameY = 9;
    self.flashControl.flashDelegate = self;
    [self.flashControl addTarget:self action:@selector(flashControl:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.flashControl];
    
    self.elapsedTimeLabel = [[UILabel alloc] init];
    self.elapsedTimeLabel.frameX = CGRectGetMidX(self.bounds) - CGRectGetWidth(self.bounds)/6;
    self.elapsedTimeLabel.frameY = self.flashControl.frameY;
    self.elapsedTimeLabel.frameSize = CGSizeMake(CGRectGetWidth(self.bounds)/3, 26);
    self.elapsedTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.elapsedTimeLabel];
    self.elapsedTimeLabel.textColor = [UIColor whiteColor];
    self.elapsedTimeLabel.font = [UIFont systemFontOfSize:19];
    self.elapsedTimeLabel.text = @"00:00:00";
    
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setTitle:@"📷" forState:UIControlStateNormal];
    self.switchCameraButton.frameY = (self.frameHeight  - 40)/2;
    self.switchCameraButton.frameX = CGRectGetWidth(self.bounds) - 56;
    self.switchCameraButton.frameSize = CGSizeMake(40, 40);
    [self.switchCameraButton addTarget:self action:@selector(swicthCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.switchCameraButton];
}

#pragma mark - Target
- (void)flashControl:(FlashControlView *)sender {
    ((void (*) (id, SEL,FlashControlView *)) (void *)objc_msgSend)([self topVC], @selector(flashControlChanged:),sender);
}

- (void)swicthCamera:(UIButton *)sender {
    ((void (*) (id, SEL)) (void *)objc_msgSend)([self topVC], @selector(swapCameras));
}

#pragma mark - FlashControlDelegate
- (void)flashControlWillExpand {
    [UIView animateWithDuration:0.2 animations:^{
        self.elapsedTimeLabel.alpha = 0.f;
    }];
}

- (void)flashControlDidCollapse {
    [UIView animateWithDuration:0.1f animations:^{
        self.elapsedTimeLabel.alpha = 1.0f;
    }];
}

@end
