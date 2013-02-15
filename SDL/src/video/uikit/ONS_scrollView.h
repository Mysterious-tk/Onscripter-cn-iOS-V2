//
//  ONS_scrollView.h
//  SDL
//
//  Created by yc on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ONS_scrollView : UIScrollView<UIScrollViewDelegate> {
@public
    UIScrollView* onsScrollView;
    UIView* gameViewBak;
    bool isLeft;
    bool preLessOne;
    bool preGreaterOne;
@private
    UIPinchGestureRecognizer *twoFingerPinch;
    float minimumScale;
}
- (void)initGesture;
- (id)initWithRectAndViewAndOri:(CGRect)rect :(UIView*)gameView :(bool)Ori;
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;

- (void)resetPinchScale;
@end
