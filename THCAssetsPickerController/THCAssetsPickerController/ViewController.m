//
//  ViewController.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/7/24.
//  Copyright (c) 2015年 Jerry Ho. All rights reserved.
//

#import "ViewController.h"
#import "THCAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, THCAssetsPickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    self.navigationItem.title =  @"相册图片选择器";
    
    //self.view
    self.view.backgroundColor = [UIColor whiteColor];
    
    //self.tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    //self.dataSource
    self.dataSource = @[@"图片选择器"];
}


#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView  dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [self assetsPickerControllerAction];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewWillLayoutSubviews
{
     self.tableView.frame = self.view.bounds;
}

#pragma mark - 二级界面

- (void)assetsPickerControllerAction
{
    THCAssetsPickerController * assetsPickerController = [[THCAssetsPickerController alloc] init];
    assetsPickerController.maximalSelectedNum = 5;
    assetsPickerController.delegate = self;
    assetsPickerController.showAllAssetsAtFirst = YES;
    [self presentViewController:assetsPickerController animated:YES completion:nil];
}

- (void)assetsPickerController:(THCAssetsPickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"%@", assets);
}

- (void)assetsPickerControllerDidCancel:(THCAssetsPickerController *)imagePickerController
{
    NSLog(@"取消");
}

#pragma mark - 收到内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
