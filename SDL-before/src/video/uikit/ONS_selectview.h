//
//  ONS_selectview.h
//  SDL
//
//  Created by yc on 12-1-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

UIImage **usrLogo;

@interface ONS_selectview : UITableViewController
@property (retain, nonatomic) NSMutableArray* ONS_data;
@property (retain, nonatomic) NSMutableArray* ONS_data_full;
@property (retain, nonatomic) UIImage *logo;

-(void)getONSData;
-(void)loadGame : (NSString*) path;
- (BOOL) checkpath:(const char*) str;
@end
