//
//  PreviewView.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import "PreviewView.h"

#define BOX_BOUNDS CGRectMake(0.0f, 0.0f, 150, 150.0f)

@interface PreviewView ()

@property (nonatomic,strong) UIView *focusBox;
@property (nonatomic,strong) UIView *exposureBox;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *doubleDoubleTapRecognizer;

@end

@implementation PreviewView

+ (Class)layerClass {
    /*
     重写 layerClass 方法并返回 AVCaptureVideoPreviewLayer 对象
    */
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    /*
     重写 session 方法，返回捕捉会话
     */
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setSession:(AVCaptureSession *)session {
    /*
     重写 session 属性的访问方法，在 setsession 方法中访问视图 Layer 属性
     AVCaptureVideoPreviewLayer 实例，并且设置 AVCaptureSession 将捕捉数据直接输出到图层中，确保与会话同步
     */
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

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
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDoubleTap:)];
    self.doubleDoubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleDoubleTapRecognizer.numberOfTouchesRequired = 2;
    
    [self addGestureRecognizer:self.singleTapRecognizer];
    [self addGestureRecognizer:self.doubleTapRecognizer];
    [self addGestureRecognizer:self.doubleDoubleTapRecognizer];
    
    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    
    self.focusBox = [self viewWithColor:[UIColor colorWithRed:0.102 green:0.636 blue:1.0 alpha:1]];
    self.exposureBox = [self viewWithColor:[UIColor colorWithRed:1.0 green:0.421 blue:0.054 alpha:1]];
    
    [self addSubview:self.focusBox];
    [self addSubview:self.exposureBox];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self];
    [self runBoxAnimationOnView:self.focusBox point:point];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tapToFocusEnabled)]) {
        [self.delegate tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self];
    [self runBoxAnimationOnView:self.exposureBox point:point];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tapToExposeEnabled)]) {
        [self.delegate tappedToExposeAtPoint:[self captureDevicePointForPoint:point]];
    }
}

- (void)handleDoubleDoubleTap:(UITapGestureRecognizer *)sender {
    [self runResetAnimation];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tappedResetFocusAndExposure)]) {
        [self.delegate tappedResetFocusAndExposure];
    }
}

- (void)runResetAnimation {
    if (!self.tapToExposeEnabled && !self.tapToFocusEnabled) {
        return;
    }
    
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    CGPoint centerPoint = [layer pointForCaptureDevicePointOfInterest:CGPointMake(0.5f, 0.5f)];
    self.focusBox.center = centerPoint;
    self.exposureBox.center = centerPoint;
    self.exposureBox.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusBox.hidden = self.exposureBox.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.focusBox.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
        self.exposureBox.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
    } completion:^(BOOL finished) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            self.focusBox.hidden = self.exposureBox.hidden = YES;
            self.focusBox.transform = CGAffineTransformIdentity;
            self.exposureBox.transform = CGAffineTransformIdentity;
        });
    }];
}

- (void)setTapToFocusEnabled:(BOOL)tapToFocusEnabled {
    _tapToFocusEnabled = tapToFocusEnabled;
    self.singleTapRecognizer.enabled = tapToFocusEnabled;
}

- (void)setTapToExposeEnabled:(BOOL)tapToExposeEnabled {
    _tapToExposeEnabled = tapToExposeEnabled;
    self.doubleTapRecognizer.enabled = tapToExposeEnabled;
}

/*
 用于支持该类定义的不同触摸方法，将屏幕坐标系上的点转换为摄像头上的坐标系点
 
 坐标空间转换：
 captureDevicePointOfInterestForPoint:获取屏幕坐标系的CGPoint 数据，返回转换得到的设备坐标系CGPoint数据。
 pointForCaptureDevicePointOfInterest:获取摄像头坐标系的CGPoint数据，返回转换得到的屏幕坐标系CGPoint 数据。
 */
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (void)runBoxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL finished) {
        double deleayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(deleayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

- (UIView *)viewWithColor:(UIColor *)color {
    UIView *view = [[UIView alloc] initWithFrame:BOX_BOUNDS];
    view.backgroundColor = [UIColor clearColor];
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = 5.0f;
    view.hidden = YES;
    return view;
}

@end
