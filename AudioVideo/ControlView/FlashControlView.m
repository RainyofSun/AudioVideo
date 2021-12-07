//
//  FlashControlView.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import "FlashControlView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat BUTTON_WIDTH   = 48.0f;
static const CGFloat BUTTON_HEIGHT  = 30.0;
static const CGFloat ICON_WIDTH     = 18.0f;
static const CGFloat FONT_SIZE      = 17.0f;

#define BOLD_FONT   [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:FONT_SIZE]
#define NORMAL_FONT [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:FONT_SIZE]

#define LEFT_SHRINK     CGRectMake(ICON_WIDTH, self.midY, 0.f, NORMAL_FONT.pointSize)
#define RIGHT_SHRINK    CGRectMake(ICON_WIDTH + BUTTON_WIDTH, 0, 0.f, NORMAL_FONT.pointSize)
#define MIDDLE_EXPANDED CGRectMake(ICON_WIDTH, self.midY, BUTTON_WIDTH, NORMAL_FONT.pointSize)

@interface FlashControlView ()

@property (nonatomic,assign) BOOL expanded;
@property (nonatomic,assign) CGFloat defaultWidth;
@property (nonatomic,assign) CGFloat expandedWidth;
@property (nonatomic,assign) NSUInteger selectedIndex;
@property (nonatomic,assign) CGFloat midY;

@property (nonatomic,strong) NSArray <UILabel *>*labels;

@end

@implementation FlashControlView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, ICON_WIDTH + BUTTON_WIDTH, BUTTON_HEIGHT)]) {
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    UIImageView *iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash_icon"]];
    iconImgView.frameY = (self.frameHeight - iconImgView.frameHeight)/2;
    [self addSubview:iconImgView];
    
    self.midY = (self.frameHeight - NORMAL_FONT.pointSize)/2;
    self.labels = [self buildLabels:@[@"Auto",@"On",@"Off"]];
    
    self.defaultWidth = self.frameWidth;
    self.expandedWidth = ICON_WIDTH + (BUTTON_WIDTH * self.labels.count);
    
    self.clipsToBounds = YES;
    
    [self addTarget:self action:@selector(selectMode:forEvent:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSArray <UILabel *>*)buildLabels:(NSArray <NSString *>*)labelTitles {
    CGFloat X = ICON_WIDTH;
    BOOL first = YES;
    NSMutableArray <UILabel *>* tempArray = [NSMutableArray arrayWithCapacity:labelTitles.count];
    for (NSString *title in labelTitles) {
        CGRect frame = CGRectMake(X, self.midY, BUTTON_WIDTH, NORMAL_FONT.pointSize);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = title;
        label.font = NORMAL_FONT;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = first ? NSTextAlignmentLeft : NSTextAlignmentCenter;
        first = NO;
        [self addSubview:label];
        [tempArray addObject:label];
        X += BUTTON_WIDTH;
    }
    return [tempArray copy];
}

- (void)selectMode:(id)sender forEvent:(UIEvent *)event {
    if (!self.expanded) {
        [self performDelegateSelectorIfSupported:@selector(flashControlWillExpand)];
        [UIView animateWithDuration:0.3 animations:^{
            self.frameWidth = self.expandedWidth;
            for (NSInteger i = 0; i < self.labels.count; i ++) {
                self.labels[i].font = (i == self.selectedIndex) ? BOLD_FONT : NORMAL_FONT;
                self.labels[i].frame = CGRectMake(ICON_WIDTH + (i * BUTTON_WIDTH), self.midY, BUTTON_WIDTH, NORMAL_FONT.pointSize);
                if (i > 0) {
                    self.labels[i].textAlignment = NSTextAlignmentCenter;
                }
            }
        } completion:^(BOOL finished) {
            [self performDelegateSelectorIfSupported:@selector(flashControlDidExpand)];
        }];
    } else {
        [self performDelegateSelectorIfSupported:@selector(flashControlWillCollapse)];
        UITouch *touch = [[event allTouches] anyObject];
        for (NSInteger i = 0; i < self.labels.count; i ++) {
            UILabel *tempLabel = self.labels[i];
            CGPoint touchPoint = [touch locationInView:tempLabel];
            if ([tempLabel pointInside:touchPoint withEvent:event]) {
                self.selectedIndex = i;
                tempLabel.textAlignment = NSTextAlignmentCenter;
                
                [UIView animateWithDuration:0.3 animations:^{
                    for (NSUInteger i = 0; i < self.labels.count; i ++) {
                        if (i < self.selectedIndex) {
                            self.labels[i].frame = LEFT_SHRINK;
                        } else if (i > self.selectedIndex) {
                            self.labels[i].frame = RIGHT_SHRINK;
                        } else if (i == self.selectedIndex) {
                            self.labels[i].frame = MIDDLE_EXPANDED;
                        }
                    }
                    self.frameWidth = self.defaultWidth;
                } completion:^(BOOL finished) {
                    [self performDelegateSelectorIfSupported:@selector(flashControlDidCollapse)];
                }];
                
                break;
            }
        }
    }
    self.expanded = !self.expanded;
}

- (void)performDelegateSelectorIfSupported:(SEL)sel {
    if (self.flashDelegate != nil && [self.flashDelegate respondsToSelector:sel]) {
        [self.flashDelegate performSelector:sel withObject:nil];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    NSInteger mode = selectedIndex;
    if (selectedIndex == 0) {
        mode = 2;
    } else if (selectedIndex == 2) {
        mode = 0;
    }
    self.selectedMode = mode;
}

- (void)setSelectedMode:(NSInteger)selectedMode {
    if (_selectedMode != selectedMode) {
        _selectedMode = selectedMode;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
