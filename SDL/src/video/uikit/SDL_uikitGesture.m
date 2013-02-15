//
//  SDL_uikitGesture.m
//  SDL
//
//  Created by yc on 12-1-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SDL_uikitGesture.h"

@implementation SDL_uikitGesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES; // handle the touch
}
@end
