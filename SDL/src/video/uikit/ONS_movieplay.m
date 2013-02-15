//
//  ONS_movieplay.m
//  SDL
//
//  Created by yc on 12-1-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ONS_movieplay.h"
//#import "SDL_mixer.h"

extern UIViewController* myRootController;
@implementation ONS_movieplay
@synthesize mp;
@synthesize view;
-(id)initAndPlayMovie:(NSURL *)movieURL :(SDL_Window *)sdl_window{
    self = [super init];

    // Movie playback is asynchronous, so this method returns immediately.
    return self;
}

- (void)readyPlayer:(NSURL* )movieURL{
    
 //   [mp setControlStyle:MPMovieControlStyleFullscreen];
 //   [mp setScalingMode:MPMovieScalingModeAspectFit];
    [mp setFullscreen:YES];
 //   [mp setUseApplicationAudioSession:NO];
   // Mix_VolumeMusic(0);
    [mp prepareToPlay];
 
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStopChanged:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}


- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    if ([mp loadState] != MPMovieLoadStateUnknown){
         [view addSubview:mp.view];
        CGRect cr = [[UIScreen mainScreen] bounds];
        if (cr.size.width < cr.size.height){
            float old = cr.size.height;
            cr.size.height = cr.size.width;
            cr.size.width = old;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        [[self view] setBounds:cr];
        [[self view] setCenter:CGPointMake(cr.size.height/2, cr.size.width/2)];
        //   [[self view] setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        
    //    [[mp view] setFrame:cr];
        
        
        [mp play];
    }
}

- (void) moviePlayerStopChanged:(NSNotification*)notification
{

    //   [self dismissModalViewControllerAnimated:YES];
    [mp.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

-(id) initAndPlayMovieDbg:(NSURL *)movieURL :(UIViewController *)win{
    self = [super init];

    /*
    
    moviePlayer = [[[CustomMoviePlayerViewController alloc] initWithPath:movieURL]autorelease];
    NSLog(@"%@",movieURL);
    //   self.mp.view.frame = CGRectMake(-130, 130, 1024, 768);
    
    [win presentModalViewController:moviePlayer animated:YES];
    
    [moviePlayer readyPlayer];*/
    // Movie playback is asynchronous, so this method returns immediately.
    return self;
}
// When the movie is done, release the controller.

@end
