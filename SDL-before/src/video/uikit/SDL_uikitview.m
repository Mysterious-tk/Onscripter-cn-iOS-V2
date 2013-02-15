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

#import "SDL_uikitview.h"
#import "SDL_uikitwindow.h"
#import "SDL_uikitGesture.h"
#import "CustomMoviePlayerViewController.h"

#include "../../events/SDL_keyboard_c.h"
#include "../../events/SDL_mouse_c.h"
#include "../../events/SDL_touch_c.h"

#if SDL_IPHONE_KEYBOARD
#import "keyinfotable.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_uikitkeyboard.h"
#import "SDL_uikitwindow.h"
#endif

@implementation SDL_uikitview

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];

#if SDL_IPHONE_KEYBOARD
    [self initializeKeyboard];
#endif
   // [self setCanCancelContentTouches:NO];
  /*
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGSize p = rect.size;
    
    p.width = p.height / 4.0 * 3 * 2;
    p.height *= 2;
*/

    [self initGesture];
    [self upperGraph];
   // [self setContentSize:p];


    return self;

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"doing scrollViewing");
}

-(void) upperGraph{
    /*
     CGContextRef context = UIGraphicsGetCurrentContext();
    CGInterpolationQuality q = kCGInterpolationHigh;
    CGContextSetInterpolationQuality(context, q);
     */
}

-(void) loadMoviePlayer:(NSURL *)path
{
    
    //NSString *path = [[NSBundle mainBundle]pathForResource:@"op" ofType:@"mp4"];
   // NSString* pathl = @"/var/mobile/Applications/BDEAB0A8-49DA-4629-8D6E-D585A4916B2E/Documents/hello/op.mp4";
    
    moviePlayer = [[[CustomMoviePlayerViewController alloc] initWithPath:path]autorelease];
    
     [self->viewcontroller presentModalViewController:moviePlayer animated:YES];
    
    [moviePlayer readyPlayer];
}

- (void)initGesture{
    
    UILongPressGestureRecognizer* fingerLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:fingerLongPress];
    [fingerLongPress release];
    /*
     UISwipeGestureRecognizer* fingerSwip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipGesture:)];
     [fingerSwip setDirection:UISwipeGestureRecognizerDirectionLeft];
     [self addGestureRecognizer:fingerSwip];
     [fingerSwip release];
    */
    
    UITapGestureRecognizer* fingerDTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDTapGesture:)];
    [fingerDTap setNumberOfTapsRequired:1];
    [fingerDTap setNumberOfTouchesRequired:2];
    [self addGestureRecognizer:fingerDTap];
    [fingerDTap release];
    
    /*
    UITapGestureRecognizer* fingerTriTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTriTapGesture:)];
    [fingerTriTap setNumberOfTapsRequired:1];
    [fingerTriTap setNumberOfTouchesRequired:3];
    [self addGestureRecognizer:fingerTriTap];
    [fingerTriTap release];
    */
    
    SDL_uikitGesture* fingerTap = [[SDL_uikitGesture alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [fingerTap setNumberOfTapsRequired:1];
    [fingerTap setNumberOfTouchesRequired:1];
    [fingerTap setCancelsTouchesInView:NO];
    [self addGestureRecognizer:fingerTap];
    [fingerTap release];
     
     
     
}

-(IBAction)handleLongPressGesture:(id)sender{
    
    NSLog(@"long press performed");
    
    SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_S);
    SDL_SendKeyboardKey(SDL_RELEASED,SDL_SCANCODE_S);
    // SDL_SendKeyboardKey(SDL_PRESSED,SDL_SCANCODE_ESCAPE);
    //  SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_ESCAPE);
    gs.swipUp = gs.longPress = gs.swipDown = gs.fDTap = gs.fTap = 0;
    
}



-(IBAction) procKeyInfo:(id) notify{
    UIButton* tBtn = (UIButton*)notify;
    NSInteger v = tBtn.tag - 3;
   // [self loadMoviePlayer];
    if (v == 4){
        SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_RETURN);
        SDL_SendKeyboardKey(SDL_RELEASED,SDL_SCANCODE_RETURN);
        
    }
    else if (v == 3){
        SDL_SendMouseMotion(NULL,SDL_PRESSED,100,100);
        SDL_SendMouseButton(NULL,SDL_PRESSED,SDL_BUTTON_RIGHT);
        
        SDL_SendMouseMotion(NULL,SDL_RELEASED,101,101);
        SDL_SendMouseButton(NULL,SDL_RELEASED,SDL_BUTTON_RIGHT);
    }
    else if (v == 2){
        
        SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_LEFT);
        SDL_SendKeyboardKey(SDL_RELEASED,SDL_SCANCODE_LEFT);
    }
    else if (v == 1){
        SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_RIGHT);
        SDL_SendKeyboardKey(SDL_RELEASED,SDL_SCANCODE_RIGHT);
    }
    else if (v == 0){
        SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_S);
        SDL_SendKeyboardKey(SDL_RELEASED,SDL_SCANCODE_S);
    }
    NSLog(@"get a tag %d\n",tBtn.tag);
}



-(IBAction)handleTriTapGesture:(id)sender{

 
    fprintf(stderr, "tri Taped\n");
    if(gs.isTriTap){
        [self setTransform:CGAffineTransformIdentity];
        [self setCenter : CGPointMake(160, 240)];
        
        gs.isTriTap^=1;
    }
    else{
        [self setCenter :  CGPointMake(160, 150)];
#ifdef CLANNAD
        view.center = CGPointMake(160, 210);
#else
        [self setCenter :   CGPointMake(160, 270)];
#endif
        
        [self setTransform: CGAffineTransformScale([ self transform], 1.12476, 1.0)];
        gs.isTriTap^=1;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(IBAction)handleSwipGestureR:(id)sender{
    //    if(gs.swipUp)
    //       return;
    NSLog(@"swip up performed");
    SDL_SendKeyboardKey(SDL_PRESSED,SDL_SCANCODE_KP_ENTER);
    SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_KP_ENTER);
    
    
    
    gs.swipUp = gs.longPress = gs.swipDown = gs.fDTap = gs.fTap = 0;
    gs.swipUp = 1;
}
-(IBAction)handleSwipGesture:(id)sender{
    //    if(gs.swipDown)
    //      return;
    NSLog(@"swip left performed");
    
    SDL_SendKeyboardKey(SDL_PRESSED,SDL_SCANCODE_SPACE);
    SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_SPACE);  
    
    gs.swipUp = gs.longPress = gs.swipDown = gs.fDTap = gs.fTap = 0;
    gs.swipDown = 1;
}

-(IBAction)handleDTapGesture:(id)sender{//把双键当成右键还是esc
    //   if(gs.fDTap)
    //      return;
    NSLog(@"Dtap performed");
    
#ifdef CLANNAD
    SDL_SendKeyboardKey(SDL_PRESSED,SDL_SCANCODE_ESCAPE);
    SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_ESCAPE);
#else
    SDL_SendMouseMotion(NULL,SDL_PRESSED,100,100);
    SDL_SendMouseButton(NULL,SDL_PRESSED,SDL_BUTTON_RIGHT);
    
    SDL_SendMouseMotion(NULL,SDL_RELEASED,101,101);
	SDL_SendMouseButton(NULL,SDL_RELEASED,SDL_BUTTON_RIGHT);
    //   SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_RIGHT);
    //    SDL_SendKeyboardKey(SDL_RELEASED,SDL_SCANCODE_RIGHT);
#endif
    
     SDL_SendMouseMotion(NULL,SDL_PRESSED,100,100);
     SDL_SendMouseButton(NULL,SDL_PRESSED,SDL_BUTTON_RIGHT);
     
     SDL_SendMouseMotion(NULL,SDL_RELEASED,101,101);
     SDL_SendMouseButton(NULL,SDL_RELEASED,SDL_BUTTON_RIGHT);
     
    gs.swipUp =gs.longPress = gs.swipDown = gs.fDTap = gs.fTap = 0;
    gs.fDTap = 1;
}
extern int btnShow;

-(IBAction)handleTapGesture:(id)sender{
    NSLog(@"tap performed");
    CGPoint locationInView = [sender locationInView:self];
    locationInView.x *= [[UIScreen mainScreen]scale];
    locationInView.y *= [[UIScreen mainScreen]scale];
    CGRect cr = [[UIScreen mainScreen]bounds];
    cr.size.height *= [[UIScreen mainScreen]scale];
    cr.size.width *= [[UIScreen mainScreen]scale];
  //  CGFloat old = locationInView.x;
  //  locationInView.x = locationInView.y;
  //  locationInView.y = cr.size.height - old;

    
    fprintf(stderr, "the loca x = %f, y = %f\n",locationInView.x,locationInView.y);
    if (btnShow && cr.size.height - locationInView.x <= 63 && cr.size.width - locationInView.y <= 320)
        return;
    
    SDL_SendMouseMotion(NULL,SDL_PRESSED,locationInView.x,locationInView.y);
    SDL_SendMouseButton(NULL,SDL_PRESSED,SDL_BUTTON_LEFT);
    
    SDL_SendMouseMotion(NULL,SDL_RELEASED,locationInView.x+1,locationInView.y+1);
	SDL_SendMouseButton(NULL,SDL_RELEASED,SDL_BUTTON_LEFT);
    
 //   fprintf(stderr, "the loca x = %f, y = %f\n",locationInView.x,locationInView.y);
    gs.swipUp =gs.longPress = gs.swipDown = gs.fDTap = gs.fTap = 0;
    
}

- (CGPoint)touchLocation:(UITouch *)touch
{
    CGPoint point = [touch locationInView: self];
    CGRect frame = [self frame];

    frame = CGRectApplyAffineTransform(frame, [self transform]);
    point.x /= frame.size.width;
    point.y /= frame.size.height;
    return point;
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
    [super touchesBegan:touches withEvent:(UIEvent *)event];
     return;
    if ([touches count] > 1)
        return;
     UITouch *touch = [touches anyObject];
    CGPoint locationInView = [touch locationInView:self];
    locationInView.x *= [[UIScreen mainScreen]scale];
    locationInView.y *= [[UIScreen mainScreen]scale];
    SDL_SendMouseMotion(NULL,SDL_PRESSED,locationInView.x,locationInView.y);
    SDL_SendMouseButton(NULL,SDL_PRESSED,SDL_BUTTON_LEFT);
    
    return;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:(UIEvent *)event];
    return;
    return ;
    if ([touches count] > 1)
        return;
    UITouch *touch = [touches anyObject];
    CGPoint locationInView = [touch locationInView:self];
    locationInView.x *= [[UIScreen mainScreen]scale];
    locationInView.y *= [[UIScreen mainScreen]scale];
    SDL_SendMouseMotion(NULL,SDL_RELEASED,locationInView.x,locationInView.y);
    SDL_SendMouseButton(NULL,SDL_RELEASED,SDL_BUTTON_LEFT);
    return;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{/*
  
    /*
        this can happen if the user puts more than 5 touches on the screen
        at once, or perhaps in other circumstances.  Usually (it seems)
        all active touches are canceled.
    *//*
    SDL_SendMouseButton(NULL,SDL_RELEASED,SDL_BUTTON_LEFT);
	[self touchesEnded: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    return ;
    if ([touches count] > 1)
        return;
    UITouch *touch = [touches anyObject];
    CGPoint locationInView = [touch locationInView:self];
    locationInView.x *= [[UIScreen mainScreen]scale];
    locationInView.y *= [[UIScreen mainScreen]scale];
    SDL_SendMouseMotion(NULL,SDL_MOUSEMOTION,locationInView.x,locationInView.y);
    NSLog(@"at moving");
    return;
}
*/
/*
    ---- Keyboard related functionality below this line ----
*/
#if SDL_IPHONE_KEYBOARD

/* Is the iPhone virtual keyboard visible onscreen? */
- (BOOL)keyboardVisible
{
    return keyboardVisible;
}

/* Set ourselves up as a UITextFieldDelegate */
- (void)initializeKeyboard
{
    textField = [[UITextField alloc] initWithFrame: CGRectZero];
    textField.delegate = self;
    /* placeholder so there is something to delete! */
    textField.text = @" ";

    /* set UITextInputTrait properties, mostly to defaults */
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.enablesReturnKeyAutomatically = NO;
    textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDefault;
    textField.secureTextEntry = NO;

    textField.hidden = YES;
    keyboardVisible = NO;
    /* add the UITextField (hidden) to our view */
    [self addSubview: textField];
    [textField release];
}

/* reveal onscreen virtual keyboard */
- (void)showKeyboard
{
    keyboardVisible = YES;
    [textField becomeFirstResponder];
}

/* hide onscreen virtual keyboard */
- (void)hideKeyboard
{
    keyboardVisible = NO;
    [textField resignFirstResponder];
}

/* UITextFieldDelegate method.  Invoked when user types something. */
- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0) {
        /* it wants to replace text with nothing, ie a delete */
        SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_DELETE);
        SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_DELETE);
    }
    else {
        /* go through all the characters in the string we've been sent
           and convert them to key presses */
        int i;
        for (i = 0; i < [string length]; i++) {

            unichar c = [string characterAtIndex: i];

            Uint16 mod = 0;
            SDL_Scancode code;

            if (c < 127) {
                /* figure out the SDL_Scancode and SDL_keymod for this unichar */
                code = unicharToUIKeyInfoTable[c].code;
                mod  = unicharToUIKeyInfoTable[c].mod;
            }
            else {
                /* we only deal with ASCII right now */
                code = SDL_SCANCODE_UNKNOWN;
                mod = 0;
            }

            if (mod & KMOD_SHIFT) {
                /* If character uses shift, press shift down */
                SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_LSHIFT);
            }
            /* send a keydown and keyup even for the character */
            SDL_SendKeyboardKey(SDL_PRESSED, code);
            SDL_SendKeyboardKey(SDL_RELEASED, code);
            if (mod & KMOD_SHIFT) {
                /* If character uses shift, press shift back up */
                SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_LSHIFT);
            }
        }
        SDL_SendKeyboardText([string UTF8String]);
    }
    return NO; /* don't allow the edit! (keep placeholder text there) */
}

/* Terminates the editing session */
- (BOOL)textFieldShouldReturn:(UITextField*)_textField
{
    SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_RETURN);
    SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_RETURN);
    [self hideKeyboard];
    return YES;
}

#endif

@end

/* iPhone keyboard addition functions */
#if SDL_IPHONE_KEYBOARD

static SDL_uikitview * getWindowView(SDL_Window * window)
{
    if (window == NULL) {
        SDL_SetError("Window does not exist");
        return nil;
    }

    SDL_WindowData *data = (SDL_WindowData *)window->driverdata;
    SDL_uikitview *view = data != NULL ? data->view : nil;

    if (view == nil) {
        SDL_SetError("Window has no view");
    }

    return view;
}

int SDL_iPhoneKeyboardShow(SDL_Window * window)
{
    SDL_uikitview *view = getWindowView(window);
    if (view == nil) {
        return -1;
    }

    [view showKeyboard];
    return 0;
}

int SDL_iPhoneKeyboardHide(SDL_Window * window)
{
    SDL_uikitview *view = getWindowView(window);
    if (view == nil) {
        return -1;
    }

    [view hideKeyboard];
    return 0;
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_Window * window)
{
    SDL_uikitview *view = getWindowView(window);
    if (view == nil) {
        return 0;
    }

    return view.keyboardVisible;
}

int SDL_iPhoneKeyboardToggle(SDL_Window * window)
{
    SDL_uikitview *view = getWindowView(window);
    if (view == nil) {
        return -1;
    }

    if (SDL_iPhoneKeyboardIsShown(window)) {
        SDL_iPhoneKeyboardHide(window);
    }
    else {
        SDL_iPhoneKeyboardShow(window);
    }
    return 0;
}

#else

/* stubs, used if compiled without keyboard support */

int SDL_iPhoneKeyboardShow(SDL_Window * window)
{
    SDL_SetError("Not compiled with keyboard support");
    return -1;
}

int SDL_iPhoneKeyboardHide(SDL_Window * window)
{
    SDL_SetError("Not compiled with keyboard support");
    return -1;
}

SDL_bool SDL_iPhoneKeyboardIsShown(SDL_Window * window)
{
    return 0;
}

int SDL_iPhoneKeyboardToggle(SDL_Window * window)
{
    SDL_SetError("Not compiled with keyboard support");
    return -1;
}

#endif /* SDL_IPHONE_KEYBOARD */

#endif /* SDL_VIDEO_DRIVER_UIKIT */

/* vi: set ts=4 sw=4 expandtab: */
