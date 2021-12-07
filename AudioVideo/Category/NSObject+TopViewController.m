//
//  NSObject+TopViewController.m
//  AudioVideo
//
//  Created by 刘冉 on 2021/6/29.
//

#import "NSObject+TopViewController.h"

@implementation NSObject (TopViewController)

- (UIViewController *)topVC {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else {
            break;
        }
    }
    return vc;
}

@end
