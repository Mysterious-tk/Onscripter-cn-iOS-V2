#import <UIKit/UIKit.h>

@interface ScriptSelector : UITableViewController<UIActionSheetDelegate> {
    NSString *script_dir;
    NSMutableArray *directory_array;
    volatile BOOL is_running;
}

-(NSString*)select;
-(void)updateFileList;

@end
