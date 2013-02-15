/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2012 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "SDL_config.h"

#if SDL_VIDEO_DRIVER_UIKIT

#include "SDL_video.h"
#include "SDL_assert.h"
#include "SDL_hints.h"
#include "../SDL_sysvideo.h"
#include "../../events/SDL_events_c.h"

#include "SDL_uikitwindow.h"
#include "SDL_uikitviewcontroller.h"
#include "SDL_uikitvideo.h"

@implementation SDL_uikitviewcontroller

@synthesize window;

- (id)initWithSDLWindow:(SDL_Window *)_window
{
    self = [self init];

    if (self == nil) {
        return nil;
    }
    self.window = _window;
   
    return self;
}

static bool ori = 0;



- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation==UIInterfaceOrientationPortrait) {
        // do some sh!t
        
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    const char *orientationsCString;
    if ((orientationsCString = SDL_GetHint(SDL_HINT_ORIENTATIONS)) != NULL) {
        BOOL rotate = NO;
        NSString *orientationsNSString = [NSString stringWithCString:orientationsCString
                                                            encoding:NSUTF8StringEncoding];
        NSArray *orientations = [orientationsNSString componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" "]];

        switch (orient) {
            case UIInterfaceOrientationLandscapeLeft:
                rotate = [orientations containsObject:@"LandscapeLeft"];
                break;

            case UIInterfaceOrientationLandscapeRight:
                rotate = [orientations containsObject:@"LandscapeRight"];
                break;

            case UIInterfaceOrientationPortrait:
                rotate = [orientations containsObject:@"Portrait"];
                break;

            case UIInterfaceOrientationPortraitUpsideDown:
                rotate = [orientations containsObject:@"PortraitUpsideDown"];
                break;

            default: break;
        }

        return rotate;
    }

    if (self->window->flags & SDL_WINDOW_RESIZABLE) {
        return YES;  // any orientation is okay.
    }

    // If not resizable, allow device to orient to other matching sizes
    //  (that is, let the user turn the device upside down...same screen
    //   dimensions, but it lets the user place the device where it's most
    //   comfortable in relation to its physical buttons, headphone jack, etc).
    switch (orient) {
        case UIInterfaceOrientationLandscapeLeft:
            
        case UIInterfaceOrientationLandscapeRight:
            return (self->window->w >= self->window->h);

        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return (self->window->h >= self->window->w);

        default: break;
    }

    return NO;  // Nothing else is acceptable.
}

- (void)loadView
{
    // do nothing.

   
}

- (void)dealloc
{
    [onsScrollView release];
    [super dealloc];
}



// Send a resized event when the orientation changes.
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    extern int btnIsFull;
    
    const UIInterfaceOrientation toInterfaceOrientation = [self interfaceOrientation];
    SDL_WindowData *data = self->window->driverdata;
    UIWindow *uiwindow = data->uiwindow;
    UIScreen *uiscreen;
    if (SDL_UIKit_supports_multiple_displays)
        uiscreen = [uiwindow screen];
    else
        uiscreen = [UIScreen mainScreen];
    const int noborder = (self->window->flags & (SDL_WINDOW_FULLSCREEN|SDL_WINDOW_BORDERLESS));
    CGRect frame = noborder ? [uiscreen bounds] : [uiscreen applicationFrame];
     CGSize size = frame.size;
    int w, h;
  
 //   size.width *= uiscreen.scale;
 //   size.height *= uiscreen.scale;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            w = (size.width < size.height) ? size.width : size.height;
            h = (size.width > size.height) ? size.width : size.height;
            break;

        case UIInterfaceOrientationLandscapeLeft:
            w = (size.width > size.height) ? size.width : size.height;
            h = (size.width < size.height) ? size.width : size.height;
            ori = 1;
           
            break;
        case UIInterfaceOrientationLandscapeRight:
            w = (size.width > size.height) ? size.width : size.height;
            h = (size.width < size.height) ? size.width : size.height;
            ori = 0;
            break;

        default:
            SDL_assert(0 && "Unexpected interface orientation!");
            return;
    }
    w *= uiscreen.scale;
    h *= uiscreen.scale;
    
 

    [uiwindow setFrame:frame];
    [uiwindow setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];

    if (btnIsFull) {
        [data->view removeFromSuperview];
        [onsScrollView release];
        [data->view setBounds:CGRectMake(0, 0,frame.size.height, frame.size.height/4.0*3 )];
        [data->view setCenter:CGPointMake(frame.size.height/4.0*3/2, frame.size.height/2)];
        // fprintf(stderr,"w = %d,h = %d\n",w,h);
        
        
        [data->view updateFrame];
        
        onsScrollView = [[ONS_scrollView alloc]initWithRectAndViewAndOri:frame :data->view :ori];
        [uiwindow addSubview:onsScrollView->onsScrollView];
    }
    else {
        [data->view setFrame:frame];
        [data->view updateFrame];
        
    }

 
    NSLog(@"doing relote");


    if (btnIsFull) {
        h = w/4.*3;
    }
    SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_RESIZED, w, h);
  //  SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_RESIZED, 2048, 2048);
}

#endif /* SDL_VIDEO_DRIVER_UIKIT */

@end
