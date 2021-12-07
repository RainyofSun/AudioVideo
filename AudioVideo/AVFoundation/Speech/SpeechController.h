//
//  SpeechController.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 文本播报
 */

@protocol SpeechDelegate <NSObject>

// 播放停止
- (void)speechFinish;

@end

@interface SpeechController : NSObject

@property (nonatomic,strong,readonly) AVSpeechSynthesizer *synthesizer;
@property (nonatomic,weak) id<SpeechDelegate> delegate;

+ (instancetype)speechController;
- (void)beginConversion:(NSArray *)speechStrs;
- (void)stopConversion;

@end

NS_ASSUME_NONNULL_END
