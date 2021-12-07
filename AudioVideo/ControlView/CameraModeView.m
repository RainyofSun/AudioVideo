//
//  CameraModeView.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/22.
//

#import "CameraModeView.h"
#import "CaptureButton.h"
#import <CoreText/CoreText.h>

#define COMPONENT_MARGIN 20.0f
#define BUTTON_SIZE CGSizeMake(68.0f, 68.0f)

@interface CameraModeView ()

@property (nonatomic,strong) UIColor *foregroundColor;
@property (nonatomic,strong) CATextLayer *videoTextLayer;
@property (nonatomic,strong) CATextLayer *photoTextLayer;
@property (nonatomic,strong) UIView *labelContainerView;
@property (nonatomic,strong) UIButton *thumbnailButton;
@property (nonatomic,strong) CaptureButton *captureButton;
@property (nonatomic,assign) BOOL maxLeft;
@property (nonatomic,assign) BOOL maxRight;
@property (nonatomic,assign) CGFloat videoStringWidth;

@end

@implementation CameraModeView

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
    self.maxRight = YES;
    self.cameraMode = CameraMode_Video;
    
    self.backgroundColor = [UIColor clearColor];
    self.foregroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.videoTextLayer = [self textLayerWithTitle:@"VIDEO"];
    self.videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
    self.photoTextLayer = [self textLayerWithTitle:@"PHOTO"];
    
    CGSize size = [@"VIDEO" sizeWithAttributes:[self fontAttributes]];
    self.videoStringWidth = size.width;
    
    self.videoTextLayer.frame = CGRectMake(0, 0, 40, 20);
    self.photoTextLayer.frame = CGRectMake(60, 0, 50, 20);
    
    CGRect containerRect = CGRectMake(0, 0, 120, 20);
    self.labelContainerView = [[UIView alloc] initWithFrame:containerRect];
    
    [self.labelContainerView.layer addSublayer:self.videoTextLayer];
    [self.labelContainerView.layer addSublayer:self.photoTextLayer];
    
    self.labelContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.labelContainerView];
    
    self.labelContainerView.centerY += 8.f;
    
    self.captureButton = [CaptureButton captureButton];
    self.captureButton.centerX = self.centerX;
    self.captureButton.frameY = self.labelContainerView.frameY + self.labelContainerView.frameHeight + 8;
    [self.captureButton addTarget:self action:@selector(captureOrRecorded:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.captureButton];
    
    self.thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.thumbnailButton.frameSize = CGSizeMake(45, 45);
    self.thumbnailButton.frameX = 40;
    self.thumbnailButton.frameY = self.captureButton.frameY + 8;
    self.thumbnailButton.backgroundColor = [UIColor whiteColor];
    self.thumbnailButton.layer.cornerRadius = 4.f;
    self.thumbnailButton.clipsToBounds = YES;
    [self.thumbnailButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.thumbnailButton];
    
    UISwipeGestureRecognizer *rightRecongizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    UISwipeGestureRecognizer *leftRecongizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    leftRecongizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:rightRecongizer];
    [self addGestureRecognizer:leftRecongizer];
}

- (void)setThumbImg:(UIImage *)img {
    [self.thumbnailButton setBackgroundImage:img forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}

#pragma mark - Target
- (void)captureOrRecorded:(CaptureButton *)sender {
    ((void (*) (id, SEL,CaptureButton *)) (void *)objc_msgSend)([self topVC], @selector(startCaptureOrRecorded:),sender);
}

- (void)showCameraRoll:(UIButton *)sender {
    ((void (*) (id, SEL)) (void *)objc_msgSend)([self topVC], @selector(showCameraAlbum));
}

- (void)toggleSelected {
    self.captureButton.selected = !self.captureButton.selected;
}

- (void)switchMode:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft && !self.maxLeft) {
        [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.labelContainerView.frameX -= 62;
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
                [CATransaction disableActions];
                self.photoTextLayer.foregroundColor = self.foregroundColor.CGColor;
                self.videoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
            } completion:^(BOOL finished) {
                
            }];
        } completion:^(BOOL finished) {
            self.cameraMode = CameraMode_Photo;
            self.maxLeft = YES;
            self.maxRight = NO;
        }];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight && !self.maxRight) {
        [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.labelContainerView.frameX += 62;
            self.videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
            self.photoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        } completion:^(BOOL finished) {
            self.cameraMode = CameraMode_Video;
            self.maxRight = YES;
            self.maxLeft = NO;
        }];
    }
}

- (void)setCameraMode:(CameraMode)cameraMode {
    if (_cameraMode != cameraMode) {
        _cameraMode = cameraMode;
        if (cameraMode == CameraMode_Photo) {
            self.captureButton.selected = NO;
            self.captureButton.captureMode = CaptureButtonMode_Photo;
            self.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        } else {
            self.captureButton.captureMode = CaptureButtonMode_Video;
            self.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CATextLayer *)textLayerWithTitle:(NSString *)title {
    CATextLayer *layer = [CATextLayer layer];
    layer.string = [[NSAttributedString alloc] initWithString:title attributes:[self fontAttributes]];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

- (NSDictionary *)fontAttributes {
    return @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17.0f],
             NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.foregroundColor.CGColor);
    
    CGRect circleRect = CGRectMake(CGRectGetMidX(rect) - 4.0f, 2.0f, 6.0f, 6.0f);
    CGContextFillEllipseInRect(context, circleRect);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.labelContainerView.frameX = CGRectGetMidX(self.bounds) - (self.videoStringWidth / 2.0);
}

@end
