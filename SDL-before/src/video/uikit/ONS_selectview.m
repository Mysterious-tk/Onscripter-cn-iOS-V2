//
//  ONS_selectview.m
//  SDL
//
//  Created by yc on 12-1-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ONS_selectview.h"
#include "SDL_config.h"
#include "SDL_hints.h"
#include "SDL_movieplay.h"

#import "../SDL_sysvideo.h"
#import "SDL_assert.h"
#import "SDL_hints.h"
#import "../../SDL_hints_c.h"

#import "SDL_uikitappdelegate.h"
#import "SDL_uikitopenglview.h"
#import "SDL_events_c.h"
#import "jumphack.h"

#ifdef main
#undef main
#endif

extern int SDL_main(int argc, char *argv[]);
static int forward_argc;
static char **forward_argv;
static int exit_status;

#import "ONS_choiceview.h"
#import "ONS_selectview.h"




@implementation ONS_selectview
@synthesize ONS_data;
@synthesize ONS_data_full;
@synthesize logo;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"游戏选择", @"游戏选择");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.title = NSLocalizedString(@"游戏选择", @"游戏选择");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        ONS_data = [[NSMutableArray alloc]init];
        ONS_data_full = [[NSMutableArray alloc]init];
        [self getONSData];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Custom function

- (BOOL) checkpath:(const char*) str{
    int len = strlen(str);
    for (int i = 0; i < len; i ++) {
        if (str[i] == '/')
            return NO;
    }
    return YES;
}

- (void) getONSData
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths;
    NSString *path,*fullpath;
    NSDirectoryEnumerator *myDicEnu;
    NSEnumerator* myEnu;
    NSDictionary *mydic;
    NSString *key;
    BOOL is;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    myDicEnu = [fm enumeratorAtPath:path];
 
    while (key = [myDicEnu nextObject]) {
        fullpath = [path stringByAppendingPathComponent:key];
        
        if ([fm fileExistsAtPath:fullpath isDirectory:&is] && is == YES && [self checkpath:[key UTF8String]]){
            [ONS_data addObject:key];
            [ONS_data_full addObject:fullpath];
        }
    }
    
    //add logo
    logo = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"logo" ofType:@"png"]];
    usrLogo = (UIImage**)malloc(sizeof(UIImage*)*[ONS_data count]);
    int cnt = 0;
    
    for (NSString* path in ONS_data_full){
        usrLogo[cnt++] = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"icon.png"] ];
    }
}

static void SDL_IdleTimerDisabledChanged(const char *name, const char *oldValue, const char *newValue)
{
    SDL_assert(SDL_strcmp(name, SDL_HINT_IDLE_TIMER_DISABLED) == 0);
    
    BOOL disable = (*newValue != '0');
    [UIApplication sharedApplication].idleTimerDisabled = disable;
}

extern int isplaying;
extern int btnWide;
extern int btnIsFull;

-(void)loadGame:(NSString *)path{
    /* register a callback for the idletimer hint */
    SDL_SetHint(SDL_HINT_IDLE_TIMER_DISABLED, "0");
    SDL_RegisterHintChangedCb(SDL_HINT_IDLE_TIMER_DISABLED, &SDL_IdleTimerDisabledChanged);
    [self dismissModalViewControllerAnimated:NO];
    
    forward_argc = 3;
    
    forward_argv = (char **)malloc(sizeof(char*)*forward_argc);
    
    forward_argv[0] = "";
    forward_argv[1] = (char*)malloc(sizeof(char)*7);
    strcpy(forward_argv[1], "--root");
    forward_argv[2] = (char*)malloc(sizeof(char)*([path length]+2));
    strcpy(forward_argv[2], [path UTF8String]);
    if (btnWide) {
        forward_argc++;
        forward_argv[3] = (char*)malloc(sizeof(char)*7);
        strcpy(forward_argv[3], "--wide");
    }
    if (btnIsFull) {
        forward_argc++;
        forward_argv[forward_argc-1] = (char*)malloc(sizeof("--full"));
        strcpy(forward_argv[forward_argc - 1], "--full");
    }

    /* run the user's application, passing argc and argv */
    SDL_main(forward_argc, forward_argv);
 /*   char dd[1024];
    strcpy(dd, forward_argv[2]);
    strcat(dd, "/CA.mp4");
    isplaying = 1;
    SDL_moveplayDbg(self, dd);
    while (isplaying) {
        sleep(10);
    }
    */
    /* exit, passing the return status from the user's application */
    // exit(exit_status);
}

#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) dealloc
{
    for (int i = 0; i < [ONS_data count]; i++){
        [usrLogo[i] release];
    }
    free(usrLogo);
    [ONS_data release];
    [ONS_data_full release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [ONS_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSString *path = [ONS_data_full objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell.imageView setImage:[UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"icon.png"]] ];
    if (cell.imageView.image == nil) {
     [cell.imageView setImage:[UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"logo.png"]] ];
    }
    if (cell.imageView.image == nil) {
        [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"logo" ofType:@"png"]]];
    }
    cell.textLabel.text = [ONS_data objectAtIndex:indexPath.row];
  
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadGame:[ONS_data_full objectAtIndex:indexPath.row]];
}

@end
