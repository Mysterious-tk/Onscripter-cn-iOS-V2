//
//  CustomMoviePlayerViewController.m
//  customMovie
//
//  Created by yc on 12-1-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomMoviePlayerViewController.h"
#import "SDL_mixer.h"

@implementation CustomMoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma - custom function
- (id)initWithPath:(NSURL *)moviePath{
    if (self = [super init]){
        movieURL = moviePath;
        [movieURL retain];
           SDL_PauseAudio(1);
    
    }
    return self;
}

- (void) readyPlayer
{
    mp = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
    [mp setControlStyle:MPMovieControlStyleFullscreen];
    [mp setScalingMode:MPMovieScalingModeAspectFit];
    [mp setFullscreen:YES];
    [mp setUseApplicationAudioSession:YES];
    
    [mp prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStopChanged:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    if ([mp loadState] != MPMovieLoadStateUnknown){
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
        
        [[mp view] setFrame:cr];
        [[self view] addSubview:[mp view]];
        
        [mp play];
    }
}

- (void) moviePlayerStopChanged:(NSNotification*)notification
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    SDL_PauseAudio(0);
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}

@end
