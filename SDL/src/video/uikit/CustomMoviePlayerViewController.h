//
//  CustomMoviePlayerViewController.h
//  customMovie
//
//  Created by yc on 12-1-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CustomMoviePlayerViewController : UIViewController{
    MPMoviePlayerController *mp;
    NSURL *movieURL;
    int vol;
}

- (id)initWithPath:(NSURL *)moviePath;
- (void)readyPlayer;
- (void) moviePlayerStopChanged:(NSNotification*)notification;
@end
