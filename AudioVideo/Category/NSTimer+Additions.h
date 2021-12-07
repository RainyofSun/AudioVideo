//
//  NSTimer+Additions.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import <Foundation/Foundation.h>

typedef void(^TimerFireBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Additions)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval firing:(TimerFireBlock)fireBlock;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock;

@end

NS_ASSUME_NONNULL_END
