//
//  AssetsLibrary.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AssetsLibrary : NSObject

- (void)writeImage:(UIImage *)image;
- (void)writeVideo:(NSURL *)videoUrl;

@end

NS_ASSUME_NONNULL_END
