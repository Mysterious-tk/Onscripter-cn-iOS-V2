#import "DataCopier.h"

@implementation DataCopier

- (int) copy {
#ifdef MAGIC_FILE
    char *magic = MAGIC_FILE;
#else
    char *magic = ".ONS.COPY.DONE";
#endif

    NSString* src_path = [[NSBundle mainBundle] pathForResource:@"ONS" ofType:@""];

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* dst_path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ONS"];
    NSString* magic_path = [dst_path stringByAppendingPathComponent:[NSString stringWithCString: magic encoding:NSUTF8StringEncoding]];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dst_path]){
        if ([fm fileExistsAtPath:magic_path]) return 0;
        // delete and copy again
        //[fm removeItemAtPath:dst_path error:nil];
    }

    // create progress bar
    UIWindow *uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [uiwindow addSubview:self.view];
    [uiwindow makeKeyAndVisible];

    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Copying archives from Resources...\n\n" 
                                         delegate:self 
                                         cancelButtonTitle:nil
                                         destructiveButtonTitle:nil 
                                         otherButtonTitles:nil];
    [actionSheet autorelease];
    [actionSheet showInView:uiwindow];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    [fm copyItemAtPath:src_path toPath:dst_path error:nil];
    [fm createFileAtPath:magic_path contents:nil attributes:nil];

    [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];

    return 0;
}
@end
