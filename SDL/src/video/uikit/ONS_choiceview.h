//
//  ONS_choiceview.h
//  SDL
//
//  Created by yc on 12-1-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomMoviePlayerViewController;
@interface ONS_choiceview : UITableViewController{
   
}


- (IBAction)btnWideAction:(id)sender;
- (IBAction)sldOpqAction:(id)sender;
- (IBAction)btnHideAction:(id)sender;
@property (retain, nonatomic) IBOutlet UISwitch *btnSWide;//宽屏标签
@property (retain, nonatomic) IBOutlet UISwitch *btnFull;

@property (retain, nonatomic) IBOutlet UILabel *sldOpqLabel;
@property (retain, nonatomic) IBOutlet UITableViewCell *sldOpqCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellWide;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellInitFull;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellBtnAppear;
@property (retain, nonatomic) IBOutlet UITableViewCell *btnWideSw;
@property (retain, nonatomic) IBOutlet UISwitch *btnWideSw2;

@property (retain, nonatomic) NSMutableDictionary *dic;
@property (retain, nonatomic) IBOutlet UITableViewCell *btnAppearSw;


- (IBAction)btnWideModeAction:(id)sender;
- (IBAction)btnInitFullAction:(id)sender;//全屏选项
- (IBAction)btnAppearAction:(id)sender;
- (IBAction)sldChangeAction:(id)sender;


- (void)initAll;
- (void)writeToFIle;
- (void)updateBtn;

@end
