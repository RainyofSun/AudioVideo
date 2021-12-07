//
//  NSFileManager+Additions.h
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Additions)

- (NSString *)temporaryDirectoryWithTemplateString:(nullable NSString *)templateString;

@end

NS_ASSUME_NONNULL_END
