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

#import <UIKit/UIKit.h>

#include "SDL_video.h"
#include "SDL_mouse.h"
#include "../SDL_sysvideo.h"
#include "../SDL_pixels_c.h"
#include "../../events/SDL_events_c.h"

#include "SDL_uikitvideo.h"
#include "SDL_uikitevents.h"
#include "SDL_uikitwindow.h"
#include "SDL_uikitopengles.h"

#include "SDL_assert.h"

#define UIKITVID_DRIVER_NAME "uikit"

/* Initialization/Query functions */
static int UIKit_VideoInit(_THIS);
static void UIKit_GetDisplayModes(_THIS, SDL_VideoDisplay * sdl_display);
static int UIKit_SetDisplayMode(_THIS, SDL_VideoDisplay * display,
                                SDL_DisplayMode * mode);
static void UIKit_VideoQuit(_THIS);

BOOL SDL_UIKit_supports_multiple_displays = NO;

/* DUMMY driver bootstrap functions */

static int
UIKit_Available(void)
{
    return 1;
}

static void UIKit_DeleteDevice(SDL_VideoDevice * device)
{
    SDL_free(device);
}

static SDL_VideoDevice *
UIKit_CreateDevice(int devindex)
{
    SDL_VideoDevice *device;

    /* Initialize all variables that we clean on shutdown */
    device = (SDL_VideoDevice *) SDL_calloc(1, sizeof(SDL_VideoDevice));
    if (!device) {
        SDL_OutOfMemory();
        if (device) {
            SDL_free(device);
        }
        return (0);
    }

    /* Set the function pointers */
    device->VideoInit = UIKit_VideoInit;
    device->VideoQuit = UIKit_VideoQuit;
    device->GetDisplayModes = UIKit_GetDisplayModes;
    device->SetDisplayMode = UIKit_SetDisplayMode;
    device->PumpEvents = UIKit_PumpEvents;
    device->CreateWindow = UIKit_CreateWindow;
    device->SetWindowFullscreen = UIKit_SetWindowFullscreen;
    device->DestroyWindow = UIKit_DestroyWindow;
    device->GetWindowWMInfo = UIKit_GetWindowWMInfo;


    /* OpenGL (ES) functions */
    device->GL_MakeCurrent        = UIKit_GL_MakeCurrent;
    device->GL_SwapWindow        = UIKit_GL_SwapWindow;
    device->GL_CreateContext    = UIKit_GL_CreateContext;
    device->GL_DeleteContext    = UIKit_GL_DeleteContext;
    device->GL_GetProcAddress   = UIKit_GL_GetProcAddress;
    device->GL_LoadLibrary        = UIKit_GL_LoadLibrary;
    device->free = UIKit_DeleteDevice;

    device->gl_config.accelerated = 1;

    return device;
}

VideoBootStrap UIKIT_bootstrap = {
    UIKITVID_DRIVER_NAME, "SDL UIKit video driver",
    UIKit_Available, UIKit_CreateDevice
};


/*
!!! FIXME:

The main screen should list a AxB mode for portrait orientation, and then
 also list BxA for landscape mode. When setting a given resolution, we should
 rotate the view's transform appropriately (extra credit if you check the
 accelerometer and rotate the display so it's never upside down).

  http://iphonedevelopment.blogspot.com/2008/10/starting-in-landscape-mode-without.html

*/

static void
UIKit_GetDisplayModes(_THIS, SDL_VideoDisplay * display)
{
    UIScreen *uiscreen = (UIScreen *) display->driverdata;
    SDL_DisplayMode mode;
    SDL_zero(mode);

    // availableModes showed up in 3.2 (the iPad and later). We should only
    //  land here for at least that version of the OS.
    if (!SDL_UIKit_supports_multiple_displays) {
        const CGRect rect = [uiscreen bounds];
        mode.format = SDL_PIXELFORMAT_ABGR8888;
        mode.refresh_rate = 0;
        mode.driverdata = NULL;

        mode.w = (int) rect.size.width;
        mode.h = (int) rect.size.height;
        SDL_AddDisplayMode(display, &mode);

        mode.w = (int) rect.size.height;  // swap the orientation, add again.
        mode.h = (int) rect.size.width;
        SDL_AddDisplayMode(display, &mode);
        return;
    }

    for (UIScreenMode *uimode in [uiscreen availableModes]) {
        CGSize size = [uimode size];
        mode.format = SDL_PIXELFORMAT_ABGR8888;
        mode.refresh_rate = 0;
        mode.driverdata = uimode;
        mode.w = (int) size.width;
        mode.h = (int) size.height;
        if (SDL_AddDisplayMode(display, &mode))
            [uimode retain];        // retain is needed because of mode.driverdata

        if (uiscreen == [UIScreen mainScreen]) {
            // Add the mode with swapped width/height
            mode.w = (int) size.height;
            mode.h = (int) size.width;
            if (SDL_AddDisplayMode(display, &mode))
                [uimode retain];
        }
    }
}


static void
UIKit_AddDisplay(UIScreen *uiscreen, int w, int h)
{
    SDL_VideoDisplay display;
    SDL_DisplayMode mode;
    SDL_zero(mode);
    mode.format = SDL_PIXELFORMAT_ABGR8888;
    mode.w = w;
    mode.h = h;
    mode.refresh_rate = 0;

    // UIScreenMode showed up in 3.2 (the iPad and later). We're
    //  misusing this supports_multiple_displays flag here for that.
    if (SDL_UIKit_supports_multiple_displays) {
        UIScreenMode *uimode = [uiscreen currentMode];
        [uimode retain];  // once for the desktop_mode
        [uimode retain];  // once for the current_mode
        mode.driverdata = uimode;
    }

    SDL_zero(display);
    display.desktop_mode = mode;
    display.current_mode = mode;

    [uiscreen retain];
    display.driverdata = uiscreen;
    SDL_AddVideoDisplay(&display);
}


int
UIKit_VideoInit(_THIS)
{
    _this->gl_config.driver_loaded = 1;

    // this tells us whether we are running on ios >= 3.2
    SDL_UIKit_supports_multiple_displays = [UIScreen instancesRespondToSelector:@selector(currentMode)];

    // Add the main screen.
    UIScreen *uiscreen = [UIScreen mainScreen];
    const CGSize size = [uiscreen bounds].size;
    UIKit_AddDisplay(uiscreen, (int)size.width * uiscreen.scale, (int)size.height * uiscreen.scale);

    // If this is iPhoneOS < 3.2, all devices are one screen, 320x480 pixels.
    //  The iPad added both a larger main screen and the ability to use
    //  external displays. So, add the other displays (screens in UI speak).
    if (SDL_UIKit_supports_multiple_displays) {
        for (UIScreen *uiscreen in [UIScreen screens]) {
            // Only add the other screens
            if (uiscreen != [UIScreen mainScreen]) {
                const CGSize size = [uiscreen bounds].size;
                UIKit_AddDisplay(uiscreen, (int)size.width, (int)size.height);
            }
        }
    }

    /* We're done! */
    return 0;
}

static int
UIKit_SetDisplayMode(_THIS, SDL_VideoDisplay * display, SDL_DisplayMode * mode)
{
    UIScreen *uiscreen = (UIScreen *) display->driverdata;
    if (!SDL_UIKit_supports_multiple_displays) {
        // Not on at least iPhoneOS 3.2 (versions prior to iPad).
        SDL_assert(mode->driverdata == NULL);
    } else {
        UIScreenMode *uimode = (UIScreenMode *) mode->driverdata;
        [uiscreen setCurrentMode:uimode];

        CGSize size = [uimode size];
        if (size.width >= size.height) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        } else {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        }
    }

    return 0;
}

static void
UIKit_ReleaseUIScreenMode(SDL_DisplayMode * mode)
{
    if (!SDL_UIKit_supports_multiple_displays) {
        // Not on at least iPhoneOS 3.2 (versions prior to iPad).
        SDL_assert(mode->driverdata == NULL);
    } else {
        UIScreenMode *uimode = (UIScreenMode *) mode->driverdata;
        [uimode release];
        mode->driverdata = NULL;
    }
}

void
UIKit_VideoQuit(_THIS)
{
    // Release Objective-C objects, so higher level doesn't free() them.
    int i, j;
    for (i = 0; i < _this->num_displays; i++) {
        SDL_VideoDisplay *display = &_this->displays[i];
        UIScreen *uiscreen = (UIScreen *) display->driverdata;
        [uiscreen release];
        display->driverdata = NULL;
        UIKit_ReleaseUIScreenMode(&display->desktop_mode);
        UIKit_ReleaseUIScreenMode(&display->current_mode);
        for (j = 0; j < display->num_display_modes; j++) {
            SDL_DisplayMode *mode = &display->display_modes[j];
            UIKit_ReleaseUIScreenMode(mode);
        }
    }
}

#endif /* SDL_VIDEO_DRIVER_UIKIT */

/* vi: set ts=4 sw=4 expandtab: */
