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

#include "SDL_uikitopengles.h"
#include "SDL_uikitopenglview.h"
#include "SDL_uikitappdelegate.h"
#include "SDL_uikitwindow.h"
#include "jumphack.h"
#include "SDL_sysvideo.h"
#include "../../events/SDL_keyboard_c.h"
#include "../../events/SDL_mouse_c.h"
#include "../../power/uikit/SDL_syspower.h"
#include "SDL_loadso.h"
#include <dlfcn.h>

static int UIKit_GL_Initialize(_THIS);

void *
UIKit_GL_GetProcAddress(_THIS, const char *proc)
{
    /* Look through all SO's for the proc symbol.  Here's why:
       -Looking for the path to the OpenGL Library seems not to work in the iPhone Simulator.
       -We don't know that the path won't change in the future.
    */
    return dlsym(RTLD_DEFAULT, proc);
}

/*
    note that SDL_GL_Delete context makes it current without passing the window
*/
int UIKit_GL_MakeCurrent(_THIS, SDL_Window * window, SDL_GLContext context)
{
    if (context) {
        SDL_WindowData *data = (SDL_WindowData *)window->driverdata;
        [data->view setCurrentContext];
    }
    else {
        [EAGLContext setCurrentContext: nil];
    }

    return 0;
}

int
UIKit_GL_LoadLibrary(_THIS, const char *path)
{
    /*
        shouldn't be passing a path into this function
        why?  Because we've already loaded the library
        and because the SDK forbids loading an external SO
    */
    if (path != NULL) {
        SDL_SetError("iPhone GL Load Library just here for compatibility");
        return -1;
    }
    return 0;
}

void UIKit_GL_SwapWindow(_THIS, SDL_Window * window)
{
#if SDL_POWER_UIKIT
    // Check once a frame to see if we should turn off the battery monitor.
    SDL_UIKit_UpdateBatteryMonitoring();
#endif

    SDL_WindowData *data = (SDL_WindowData *)window->driverdata;

    if (nil == data->view) {
        return;
    }
    [data->view swapBuffers];
    /* since now we've got something to draw
       make the window visible */
    [data->uiwindow makeKeyAndVisible];

    /* we need to let the event cycle run, or the OS won't update the OpenGL view! */
    SDL_PumpEvents();

}

SDL_GLContext UIKit_GL_CreateContext(_THIS, SDL_Window * window)
{
    SDL_uikitopenglview *view;
    SDL_WindowData *data = (SDL_WindowData *) window->driverdata;
    UIWindow *uiwindow = data->uiwindow;
    

  //  CGRect rect = [uiwindow bounds];
    CGRect rect = [[UIScreen mainScreen]bounds];
    /*
    if (rect.size.height > rect.size.width) {
        float t = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = t;
    }
*/
    /* construct our view, passing in SDL's OpenGL configuration data */
    view = [[SDL_uikitopenglview alloc] initWithFrame:rect
                                    retainBacking: _this->gl_config.retained_backing
                                    rBits: _this->gl_config.red_size
                                    gBits: _this->gl_config.green_size
                                    bBits: _this->gl_config.blue_size
                                    aBits: _this->gl_config.alpha_size
                                    depthBits: _this->gl_config.depth_size
                                    stencilBits: _this->gl_config.stencil_size
                                    majorVersion: _this->gl_config.major_version];
    if (!view) {
        return NULL;
    }

  
   // [view->scrollView addSubview:view];
   // data->view = view;
    data->view = view;
    view->viewcontroller = data->viewcontroller;
   // view->viewcontroller = test;
    //view->viewcontroller = test;
    if (view->viewcontroller != nil) {
        [view->viewcontroller setView:data->view];
        
        
        [view->viewcontroller retain];
    }
    //add custom button here
    
    extern int btnShow;
    extern int btnIsFull;
    if (btnShow && !btnIsFull) {
        view.btn = (UIButton**)malloc(sizeof(UIButton*) * 5);
        CGRect cr = [[UIScreen mainScreen]bounds];
        CGRect tcr;
        for (int i = 0; i < 5; i++){
            tcr.origin.y = cr.size.width - 65*(i+1)+2;
            tcr.size.width = 49;
            tcr.origin.x = cr.size.height - 51;
            tcr.size.height = 63;
            view.btn[i] = [[UIButton alloc]initWithFrame:tcr];
            [view.btn[i] setAlpha:0.3f];
            [view.btn[i] addTarget:view action:@selector(procKeyInfo:) forControlEvents:UIControlEventTouchUpInside];
            [view.btn[i] setTag:i+3];
        }
        [view.btn[4] setBackgroundImage:[UIImage imageNamed:@"acquire.png"] forState:UIControlStateNormal];
        [view.btn[3] setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        [view.btn[2] setBackgroundImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        [view.btn[1] setBackgroundImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
        [view.btn[0] setBackgroundImage:[UIImage imageNamed:@"skip.png"] forState:UIControlStateNormal];
    
    

    for (int i = 0; i < 5; i++)
        [view addSubview:view.btn[i]];
    }
    UIView* blackView = [[UIView alloc]initWithFrame:rect];
    [blackView setBackgroundColor:[UIColor blackColor]];
   
  //  view->viewcontroller-> onsScrollView = [[ONS_scrollView alloc]initWithRectAndView:rect:view];
    
    [uiwindow addSubview: view];
    


    if ( UIKit_GL_MakeCurrent(_this, window, view) < 0 ) {
        UIKit_GL_DeleteContext(_this, view);
        return NULL;
    }

    /* Make this window the current mouse focus for touch input */
    /* !!! FIXME: only do this if this is the primary screen. */
    SDL_SetMouseFocus(window);
    SDL_SetKeyboardFocus(window);

    return view;
}

void UIKit_GL_DeleteContext(_THIS, SDL_GLContext context)
{
    /* the delegate has retained the view, this will release him */
    SDL_uikitopenglview *view = (SDL_uikitopenglview *)context;

    if (view->viewcontroller) {
        [view->viewcontroller setView:nil];
        [view->viewcontroller release];
    }
    [view removeFromSuperview];
    [view release];
}

//custom function


#endif /* SDL_VIDEO_DRIVER_UIKIT */

/* vi: set ts=4 sw=4 expandtab: */
