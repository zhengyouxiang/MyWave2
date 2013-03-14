//
//  LeftGroupViewController.m
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "LeftGroupViewController.h"

@interface LeftGroupViewController ()

@end

@implementation LeftGroupViewController

- (void)dealloc
{
    [groupClassifyArray release], groupClassifyArray = nil;
    [_tableView release], _tableView = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    UIImage* resizeImage = [[UIImage imageNamed:@"mask_bg.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:resizeImage] autorelease];
    imageView.frame = CGRectMake(0, 0, 250, [UIScreen mainScreen].bounds.size.height);
    self.tableView.backgroundView = imageView;
    
    groupClassifyArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    switch (self.dataSourceFlag)
    {
        case 0:
        {
            [groupClassifyArray addObjectsFromArray:@[@"用户分组，暂无权限 01",  @"用户分组，暂无权限 02",  @"用户分组，暂无权限 03",  @"用户分组，暂无权限 04",  @"用户分组，暂无权限 05",  @"用户分组，暂无权限 06",  @"用户分组，暂无权限 07",  @"用户分组，暂无权限 08", @"用户分组，暂无权限 09"]];
            break;
        }
        case 1:
        {
            [groupClassifyArray addObjectsFromArray:@[@"所有人", @"关注的人", @"全部微博", @"原创微博", @"@我的评论"]];
            break;
        }
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groupClassifyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [groupClassifyArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = FontOFHelveticaBold16;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
}

@end
