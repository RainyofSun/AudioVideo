//
//  NSFileManager+Additions.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/21.
//

#import "NSFileManager+Additions.h"
#import "NSObject+Timestamp.h"

@implementation NSFileManager (Additions)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString {
    NSString *tempStr = templateString;
    if (templateString.length) {
        tempStr = [NSString stringWithFormat:@"%@_%@",templateString,[self getCurrentTimes]];
    } else {
        tempStr = [self getCurrentTimes];
    }
    NSString *mkdTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:tempStr];
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    
    NSString *directoryPath = nil;
    char *result = mkdtemp(buffer);
    
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer length:strlen(result)];
    }
    
    free(buffer);
    return directoryPath;
}

@end
