//
//  FlashControlView.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FlashControlDelegate <NSObject>

@optional;
- (void)flashControlWillExpand;
- (void)flashControlDidExpand;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

@interface FlashControlView : UIControl

@property (nonatomic,assign) NSInteger selectedMode;
@property (nonatomic,weak) id<FlashControlDelegate> flashDelegate;

@end

NS_ASSUME_NONNULL_END
