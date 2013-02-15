//
//  ONS_scrollView.m
//  SDL
//
//  Created by yc on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ONS_scrollView.h"
#import "SDL_uikitGesture.h"

#import "SDL_uikitwindow.h"
#import "SDL_uikitGesture.h"


#import "../../events/SDL_keyboard_c.h"
#import "../../events/SDL_mouse_c.h"
#import "../../events/SDL_touch_c.h"
#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5


@interface ONS_scrollView (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end


@implementation ONS_scrollView
- (id)initWithRectAndViewAndOri:(CGRect)rect :(UIView*)gameView :(bool)Ori{
    //  rect = CGRectMake(0, 0, 1024, 768);
 //   float scalar = [[UIScreen mainScreen]scale];
 //   CGRect tt = CGRectMake(0, 0, gameView.frame.size.width/scalar, gameView.frame.size.height/scalar);
    self = [super initWithFrame:rect];
    if (self) {
        [gameView setTag:ZOOM_VIEW_TAG];
        gameViewBak = gameView;
        isLeft = !Ori;
     //   NSLog(@"Ori is %d\n",isLeft);
        /*
        if (rect.size.height > rect.size.width) {
            float t = rect.size.width;
            rect.size.width = rect.size.height;
            rect.size.height = t;
        }*/
        onsScrollView = [[UIScrollView alloc]initWithFrame:rect];
        [onsScrollView addSubview:gameView];


        //计算初始缩放值
        minimumScale = [onsScrollView frame].size.width  / [gameView frame].size.width;
        [onsScrollView setMinimumZoomScale:minimumScale];
        [onsScrollView setZoomScale:minimumScale];
        [onsScrollView setMaximumZoomScale:5.];
        [onsScrollView setScrollEnabled:YES];
        [onsScrollView setContentSize:gameView.frame.size];
        [onsScrollView setDelegate:self];
        [onsScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [onsScrollView setBackgroundColor:[UIColor blackColor]];
        [onsScrollView setCenter:CGPointMake(rect.size.width/2, rect.size.height/2)];
        [onsScrollView setBounces:YES];
        
        [self initGesture];
       // [onsScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [onsScrollView setAutoresizingMask:0];
        [onsScrollView setCanCancelContentTouches:YES];
        [onsScrollView setDelaysContentTouches:NO];
    
    }
    return self;
    
}

- (void)resetPinchScale{

    CGRect rect = [[UIScreen mainScreen]bounds];
    rect.size.width *= [[UIScreen mainScreen]scale];
    rect.size.height *= [[UIScreen mainScreen]scale];
    [onsScrollView setBounds:rect];
    [onsScrollView setCenter:CGPointMake(rect.size.width/2 , rect.size.height/2)];

}

- (void)dealloc {
    [onsScrollView removeFromSuperview];
    [onsScrollView release];
    [super dealloc];
}
- (void)initGesture {
 
    twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [twoFingerPinch setScale:1];
    [onsScrollView addGestureRecognizer:twoFingerPinch];
 
}





#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView* t =  [onsScrollView viewWithTag:ZOOM_VIEW_TAG];
  //  NSLog(@"%s",t != nil?"yes":"no");
    return t;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    NSLog(@"will begin scroll..");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
 //   [onsScrollView setZoomScale:scale+0.01 animated:NO];
 //   [onsScrollView setZoomScale:scale animated:NO];
    NSLog(@"scale at %f",scale);
   
   
  //  [scrollView setTransform:ca];
 

     CGAffineTransform ca = scrollView.transform;
    float pi = isLeft?M_PI_2:-M_PI_2;
     ca = CGAffineTransformRotate(ca, pi);
    ca = CGAffineTransformScale(ca, scale, scale);
    [gameViewBak setTransform:ca];
 //   [gameViewBak setCenter:onsScrollView.center];

  //  [onsScrollView setZoomScale:1.3];
    CGSize cs =  gameViewBak.bounds.size;
    cs.width *= scale;
    cs.height *= scale;
    cs = CGSizeMake(cs.height, cs.width);
    
    [onsScrollView setContentSize:cs];
    [gameViewBak setCenter:CGPointMake(cs.width/2, cs.height/2)];
    CGRect rect = [[UIScreen mainScreen]bounds];
 //   rect.size.width *= [[UIScreen mainScreen]scale];
 //   rect.size.height *= [[UIScreen mainScreen]scale];
    [onsScrollView setBounds:rect];
    [onsScrollView setCenter:CGPointMake(rect.size.width/2 , rect.size.height/2)];
    
    if(preLessOne && scale >= 1){
        preLessOne = 0;
    }
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
  
    float newScale = gestureRecognizer.scale;
    NSLog(@"doing pinch %f",newScale);
    if (newScale > 3) {
        newScale = 3;
    }
    if (preLessOne && newScale > 1) {
        newScale = 1;
      
    }

    else if (newScale < 1){
        newScale = minimumScale;
        preLessOne = 1;
    }
    
    /*
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [onsScrollView zoomToRect:zoomRect animated:YES];
     */
  //  float pi = isLeft?M_PI_2:-M_PI_2;
   // CGAffineTransform ca = CGAffineTransformMakeRotation(pi);
    CGRect rect = [gameViewBak bounds];
 //   [gameViewBak setTransform:ca];
    [onsScrollView setZoomScale:newScale animated:YES];
    [gameViewBak setCenter:CGPointMake(rect.size.width/2, rect.size.height)];
    
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [onsScrollView frame].size.height / scale;
    zoomRect.size.width  = [onsScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    NSLog(@"zoomRect at w = %f , h = %f",zoomRect.size.width,zoomRect.size.height);
    return zoomRect;
}

@end
