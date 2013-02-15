//
//  ONS_choiceview.m
//  SDL
//
//  Created by yc on 12-1-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "ONS_choiceview.h"
int btnShow = 1;
int btnWide = 0;
int btnIsFull = 0;

@implementation ONS_choiceview
@synthesize btnSWide;
@synthesize btnFull;
@synthesize sldOpqLabel;
@synthesize sldOpqCell;
@synthesize cellWide;
@synthesize cellInitFull;
@synthesize cellBtnAppear;
@synthesize btnWideSw;
@synthesize btnWideSw2;
@synthesize dic;
@synthesize btnAppearSw;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"游戏设置", @"游戏设置");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
       
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.title = NSLocalizedString(@"游戏设置", @"游戏设置");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        [self initAll];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - custom function

- (IBAction)btnWideModeAction:(id)sender {
    UISwitch* btn = (UISwitch*)sender;
    if ([btn isOn] == YES) {
        btnWide = 1;
    }
    else {
        btnWide = 0;
    }
    [dic setValue:[NSString stringWithFormat:@"%d",btnWide] forKey:@"btnWideAction"];
}

- (IBAction)btnInitFullAction:(id)sender {
    UISwitch* btn = (UISwitch*)sender;
    if ([btn isOn] == YES) {
        btnIsFull = 1;
    }
    else {
        btnIsFull = 0;
    }
    [dic setValue:[NSString stringWithFormat:@"%d",btnIsFull] forKey:@"btnInitFullAction"];
}

- (IBAction)btnAppearAction:(id)sender {
    UISwitch* btn = (UISwitch*)sender;
    if ([btn isOn] == YES) {
        btnShow = 1;
    }
    else {
        btnShow = 0;
    }
    [dic setValue:[NSString stringWithFormat:@"%d",btnShow] forKey:@"btnAppearAction"];
}

- (IBAction)sldChangeAction:(id)sender {
}



- (void)initAll{
    NSArray *paths;
    NSString* path;
    NSString* str,*tmpv;
    NSInteger v;
    NSError *err;
    
    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"config"];
    dic = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    if (dic == nil) {
        dic = [[NSMutableDictionary alloc]init ];
        
    }
    
    str = [dic objectForKey:@"btnAppearAction"];
    if (str == nil){
         btnShow = 1;
        [dic setValue:[NSString stringWithFormat:@"%d",btnShow] forKey:@"btnAppearAction"];
    }
    else {
        v = [str intValue];
        btnShow = v;

    }
    str = [dic objectForKey:@"btnWideAction"];
    if (str == nil){
        btnWide = 0;
        [dic setValue:[NSString stringWithFormat:@"%d",btnWide] forKey:@"btnWideAction"];
    }
    else {
        v = [str intValue];
        btnWide = v;
        
    }
    str = [dic objectForKey:@"btnInitFullAction"];
    if (str == nil){
        btnIsFull = 0;
        [dic setValue:[NSString stringWithFormat:@"%d",btnIsFull] forKey:@"btnInitFullAction"];
    }
    else {
        v = [str intValue];
        btnIsFull = v;
        
    }
    [self updateBtn];
    [self writeToFIle];
}

- (void)updateBtn
{
    if (btnShow){
        [btnWideSw2 setOn:YES];
    }
    else {
        [btnWideSw2 setOn:NO];
    }
    if (btnWide){
        [btnSWide setOn:YES];
    }
    else [btnSWide setOn:NO];
    if (btnIsFull){
        [btnFull setOn:YES];
    }
    else [btnFull setOn:NO];
    
}

- (void)writeToFIle{
    NSArray *paths;
    NSString* path;
    NSString* str,*tmpv;
    NSInteger v;
    
    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"config"];
    [dic writeToFile:path atomically:YES];
}

- (IBAction)btnWideAction:(id)sender{
    
}
- (IBAction)sldOpqAction:(id)sender{
    
}
- (IBAction)btnHideAction:(id)sender{
   
}
#pragma mark -
#pragma mark - XML parser delegate method

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
    [self setSldOpqCell:nil];
    [self setSldOpqLabel:nil];
    [self setCellWide:nil];
    [self setCellInitFull:nil];
    [self setCellBtnAppear:nil];
    [self setBtnWideSw:nil];
    [self setBtnAppearSw:nil];
    [self setBtnWideSw2:nil];
    [self setBtnSWide:nil];
    [self setBtnFull:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self writeToFIle];
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"游戏选项";
    else if (section == 1)
        return @"辅助设置";
    else if (section == 2)
        return @"致谢";
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2)
        return @"";
    else if (section == 3)
        return @"";
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (section == 0)
        return 2;
    if (section == 1)
        return 2;
    if (section == 2)
        return 3;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if (indexPath.section == 0){
        if (indexPath.row == 0){
           // cell.textLabel.text = [[NSString alloc]initWithFormat:@"宽屏模式"];
            cell = cellWide;
        }
        else if (indexPath.row == 1){
            //cell.textLabel.text = [[NSString alloc]initWithFormat:@"初始全屏"];
            cell = cellInitFull;
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0){
            cell = sldOpqCell;
           // cell.textLabel.text = [[NSString alloc]initWithFormat:@"按钮透明度"];
        }
        else if (indexPath.row == 1){
            //cell.textLabel.text = [[NSString alloc]initWithFormat:@"按钮出现"];
            cell = cellBtnAppear;
        }
    }
    else if (indexPath.section == 2){
        if (indexPath.row == 0){
            cell.textLabel.text = [[NSString alloc]initWithFormat:@"感谢热心朋友们"];
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = [[NSString alloc]initWithFormat:@"ONS iOS var 2.0 beta 1 launcher"];
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
        }
        else if (indexPath.row == 2){
            cell.textLabel.text = [[NSString alloc]initWithFormat:@"Written by tokTc"];
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)dealloc {
    [sldOpqCell release];
    [sldOpqLabel release];
    [cellWide release];
    [cellInitFull release];
    [cellBtnAppear release];
    [btnWideSw release];
    [btnAppearSw release];
    [btnWideSw2 release];
    [btnSWide release];
    [btnFull release];
    [super dealloc];
}
@end
