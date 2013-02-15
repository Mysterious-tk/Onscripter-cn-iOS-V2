#import "DataDownloader.h"
#import "HetimaUnZipContainer.h"

@implementation DataDownloader

- (int) download {
#ifdef ZIP_URL
    char *url = ZIP_URL;
#else
    char *url = "";
#endif
#ifdef MAGIC_FILE
    char *magic = MAGIC_FILE;
#else
    char *magic = ".ONS.COPY.DONE";
#endif

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    ons_path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ONS"];
    magic_path = [ons_path stringByAppendingPathComponent:[NSString stringWithCString: magic encoding:NSUTF8StringEncoding]];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:magic_path]) return 0;

    // create progress bar
    UIWindow *uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [uiwindow addSubview:self.view];
    [uiwindow makeKeyAndVisible];

    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Downloading archives from Internet:\n\n\n\n" 
                                         delegate:self 
                                         cancelButtonTitle:nil
                                         destructiveButtonTitle:nil 
                                         otherButtonTitles:nil];
    [actionSheet autorelease];

    progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 40.0f, 240.0f, 90.0f)];
    progressBar.progressViewStyle = UIProgressViewStyleDefault;
    progressBar.progress = 0.0f;
    [actionSheet addSubview:progressBar];

    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 240.0f, 20.0f)];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.textColor = [UIColor whiteColor];
    [actionSheet addSubview:progressLabel];

    [actionSheet showInView:uiwindow];

    // waiting for download to be completed
    total_read = 0;
    int num_retry = 0;
    is_completed = NO;
    while(YES){
        is_running = YES;
        NSString *url_path = [NSString stringWithCString: url encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_path] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0f];
        if (total_read > 0){
            NSString *str = [NSString stringWithFormat:@"bytes=%qi-%qi", total_read, total_size];
            [req setValue:str forHTTPHeaderField:@"Range"];
            actionSheet.title = [NSString stringWithFormat:@"Downloading archives from Internet:\nRetry %d\n\n\n", ++num_retry];
        }
        con = [[NSURLConnection alloc] initWithRequest:req delegate:self];

        while(YES){
            [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            if (is_running == NO) break;
        }
        if (con != nil){
            [con release];
            con = nil;
        }
        if (is_completed) break;

        if (num_retry > 100){
            [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Download failed." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil] autorelease];
            [alert show];
            is_alert_finished = NO;
            while(is_alert_finished == NO){
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            [alert release];
            return -1;
        }
    }

    [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];

    if (is_unzip_completed == NO) return -1;

    return 0;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    is_alert_finished = YES;
}

///////////////////////////////////////////////////////////////////////////////////////
// HetimaUnZipItemDelegate
- (void)item:(HetimaUnZipItem *)item didExtractDataOfLength:(NSUInteger)length {
    total_size += length;
    if (total_original_size > 0) progressBar.progress = (long double)total_size / total_original_size;
    progressLabel.text = [NSString stringWithFormat:@"%qi / %qi KB", total_size/1024, total_original_size/1024];
}

///////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)con {
    actionSheet.title = [NSString stringWithFormat:@"Extracting archives:\n\n\n\n"];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	
    is_unzip_completed = YES;
    HetimaUnZipContainer *unzipContainer = [[HetimaUnZipContainer alloc] initWithZipFile:zip_path];
    [unzipContainer setListOnlyRealFile:YES];
	
    if ([[unzipContainer contents] count] == 0) {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSString *err = NSLocalizedString(@"Timeout or zip file is not found.", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:err delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        is_alert_finished = NO;
        while(is_alert_finished == NO){
            [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        [alert release];
        is_unzip_completed = NO;
    } else {
        HetimaUnZipItem *item;
        NSEnumerator *contentsEnum = [[unzipContainer contents] objectEnumerator];
        total_size = 0;
        total_original_size = 0;
        for (item in contentsEnum)
            total_original_size += [item uncompressedSize];

        contentsEnum = [[unzipContainer contents] objectEnumerator];
        for (item in contentsEnum) {
            NSString *path = [ons_path stringByAppendingPathComponent:[item path]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories: YES attributes: nil error:nil];
            BOOL result = [item extractTo:path delegate:self];
            if (!result) {
                [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
                NSString *err = [NSString stringWithFormat:@"Failed to extract %@.", [item path]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:err delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
                [alert show];
                is_alert_finished = NO;
                while(is_alert_finished == NO){
                    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                }
                [alert release];
                is_unzip_completed = NO;
                break;
            }
        }
    }
	
    if (is_unzip_completed)
        [[NSFileManager defaultManager] createFileAtPath:magic_path contents:nil attributes:nil];
	
    is_completed = YES;
    [[NSFileManager defaultManager] removeItemAtPath:zip_path error:nil];

    [unzipContainer release];

    is_running = NO;
}

- (void)connection:(NSURLConnection *)con didFailWithError:(NSError *)error {
    is_running = NO;
}

- (void)connection:(NSURLConnection *)con didReceiveResponse:(NSURLResponse *)res {
    NSString *path = [res suggestedFilename];
    zip_path = [[[NSTemporaryDirectory() stringByAppendingPathComponent:path] stringByStandardizingPath] retain];

    if (total_read == 0) total_size = [res expectedContentLength];
    progressBar.progress = 0.0f;
}

- (void)connection:(NSURLConnection *)con didReceiveData:(NSData *)data {
    @try {
        if (file == nil) {
            [[NSFileManager defaultManager] createFileAtPath:zip_path contents:[NSData data] attributes:nil];
            file = [[NSFileHandle fileHandleForWritingAtPath:zip_path] retain];
        }
        [file writeData:data];
    }
    @catch (NSException * e) {
        [con cancel];
    }

    total_read += [data length];
    if (total_size > 0) progressBar.progress = (float)total_read / total_size;
    progressLabel.text = [NSString stringWithFormat:@"%qi / %qi KB", total_read/1024, total_size/1024];
}
@end
