//
//  ONS_movieplay.h
//  SDL
//
//  Created by yc on 12-1-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SDL.h"
#import "SDL_uikitwindow.h"


@interface ONS_movieplay : NSObject{
   //  CustomMoviePlayerViewController *moviePlayer;
  
}

-(id) initAndPlayMovie:(NSURL *)movieURL :(SDL_Window *)sdl_window;
-(id) initAndPlayMovieDbg:(NSURL *)movieURL :(UIViewController *)win;
- (void)readyPlayer:(NSURL* )movieURL;

@property(nonatomic,retain) MPMoviePlayerController *mp;
@property(nonatomic,retain)   UIView *view;

@end
