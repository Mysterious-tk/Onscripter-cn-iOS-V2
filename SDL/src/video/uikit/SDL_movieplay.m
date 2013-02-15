//
//  SDL_movieplay.c
//  SDL
//
//  Created by yc on 12-1-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <stdio.h>
#import "SDL.h"
#import "ONS_movieplay.h"
ONS_movieplay *mp;
extern DECLSPEC void SDLCALL SDL_moveplay(SDL_Window* win, const char* path){
    Boolean useURL = YES;
    int len = strlen(path);
    NSString *str;
    if (path[len-1] == '4' && path[len-2] == 'p' && path[len-3] == 'm' && path[len-4] == '.')
        useURL = NO;
   
    
    if (useURL) {
        NSString *str2 = [[NSString alloc]initWithUTF8String:path];
        str  = [[NSString alloc]initWithFormat:@"oplayer://%@",str2];
        NSLog(str);
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
        [str2 release];
        return;
    }
    else str = [[NSString alloc]initWithUTF8String:path];
    NSLog(str);
    SDL_WindowData* sdlw;
	sdlw=(SDL_WindowData*)(win->driverdata);
	SDL_uikitopenglview* windowview=sdlw->view;
    [windowview loadMoviePlayer:[NSURL fileURLWithPath:str]];
  //  [mp initAndPlayMovie:[NSURL URLWithString:str] :win];
}

void SDL_moveplayDbg(UIViewController* win, const char* path){
    NSString *str = [[NSString alloc]initWithFormat:@"%s",path];
    mp  = [[ONS_movieplay alloc ]initAndPlayMovieDbg:[NSURL URLWithString:str] :win];
    //  [mp initAndPlayMovie:[NSURL URLWithString:str] :win];
}
