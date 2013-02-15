#import "ScriptSelector.h"

@implementation ScriptSelector

- (NSString*) select{
    directory_array = [[NSMutableArray alloc] init];
    [self updateFileList];

    if ([directory_array count] == 1){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *docpath = [paths objectAtIndex:0];
        return [[docpath stringByAppendingPathComponent:[directory_array objectAtIndex:0]] retain];
    }

    UIWindow *uiwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [uiwindow addSubview:self.view];
    [uiwindow makeKeyAndVisible];

    is_running = YES;
    while(is_running)
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    return script_dir;
}

- (void) viewDidLoad{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionInTableView:(UITableView*)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) return directory_array.count;
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];

    if (indexPath.section == 0)
        cell.textLabel.text = [directory_array objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    NSString *name = [directory_array objectAtIndex:indexPath.row];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docpath = [paths objectAtIndex:0];
    script_dir = [[docpath stringByAppendingPathComponent:name] retain];
    is_running = NO;
}

- (void) updateFileList{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docpath = [paths objectAtIndex:0];

    NSFileManager *fm = [NSFileManager defaultManager];

    [directory_array removeAllObjects];
    NSArray *arr = [fm contentsOfDirectoryAtPath:docpath error:nil];

    for (NSString *item in arr){
        NSString *path = [docpath stringByAppendingPathComponent:item];
        BOOL is_dir;
        [fm fileExistsAtPath:path isDirectory:&is_dir];
        if (!is_dir) continue;
        if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"0.txt"]] ||
            [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"00.txt"]] ||
            [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"nscr_sec.dat"]] ||
            [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"nscript.___"]] ||
            [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"nscript.dat"]])
            [directory_array addObject:item];
    }
}
@end
