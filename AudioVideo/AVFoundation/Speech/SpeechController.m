//
//  SpeechController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/7/1.
//

#import "SpeechController.h"

@interface SpeechController ()<AVSpeechSynthesizerDelegate>

@property (nonatomic,strong) NSArray *voices;
@property (nonatomic,strong) NSArray *speechStrings;

@end

@implementation SpeechController

+ (instancetype)speechController {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
        // 声音内容
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"],
                    [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionModeMoviePlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    }
    return self;
}

- (void)beginConversion:(NSArray *)speechStrs {
    self.speechStrings = speechStrs;
    for (NSInteger i = 0; i < self.speechStrings.count; i ++) {
        @autoreleasepool {
            // 生成实例，传递字符串
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.speechStrings[i]];
            // 预定义的2个声音之间做切换
            utterance.voice = self.voices[i%2];
            // 播放语音内容速度
            utterance.rate = 0.4f;
            // 语调
            utterance.pitchMultiplier = 0.8f;
            // 在说下一句话前的停顿时长
            utterance.postUtteranceDelay = 0.1f;
            // 开始播放语言
            [self.synthesizer speakUtterance:utterance];
        }
    }
}

- (void)stopConversion {
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(speechFinish)]) {
        [self.delegate speechFinish];
    }
}

@end
