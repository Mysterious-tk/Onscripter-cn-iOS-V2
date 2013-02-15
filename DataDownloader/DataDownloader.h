#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HetimaUnZipItem.h"

@interface DataDownloader : UIViewController<UIActionSheetDelegate, HetimaUnZipItemDelegate> {
    NSURLConnection *con;
    NSString *zip_path;
    NSString *magic_path;
    NSString *ons_path;
    NSFileHandle *file;

    UIActionSheet *actionSheet;
    UIProgressView *progressBar;
    UILabel *progressLabel;

    volatile BOOL is_running;
    volatile BOOL is_unzip_completed;
    volatile BOOL is_alert_finished;
    volatile BOOL is_completed;
    long long total_read;
    long long total_size;
    long long total_original_size;
}

-(int) download;

- (void)downloadDidFinish:(NSURLConnection *)con;
- (void)download:(NSURLConnection *)con didFailWithError:(NSError *)error;
- (void)download:(NSURLConnection *)con didReceiveData:(NSData *)data;
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

