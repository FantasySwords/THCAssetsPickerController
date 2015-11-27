//
//  THCPhotoAlbumController.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/11.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCPhotoAlbumController.h"
#import "THCPhotoAlbumCell.h"
#import "THCAssetsViewController.h"
#import "THCAssetsPickerController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface THCPhotoAlbumController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end


@implementation THCPhotoAlbumController
{
    ALAssetsLibrary * _assetLibrary;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVariable];
    [self configPhotoAlbumControllerUI];
}

- (void)initVariable
{
    self.dataSource = [[NSMutableArray alloc] init];
}

- (void)configPhotoAlbumControllerUI
{
    //导航栏
    self.navigationItem.title = @"相册";
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消  " style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //TableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[THCPhotoAlbumCell class] forCellReuseIdentifier:@"THCPhotoAlbumCell"];
    [self.view addSubview:_tableView];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
        [self loadAssetsGroup];
    }else {
        //iOS版本高于8.0使用Photos
        [self loadAssetCollection];
        //[self loadAssetsGroup];
    }
}

#pragma mark - UINavigationControllerItem Action
- (void)rightItemAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.picker.delegate assetsPickerControllerDidCancel:self.picker];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

#pragma mark - ALAssetsGroup PHAssetCollection

- (void)loadAssetsGroup
{
    [_dataSource removeAllObjects];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    for (NSNumber * types in @[@(ALAssetsGroupSavedPhotos), @(ALAssetsGroupAlbum)]) {
        
        [_assetLibrary enumerateGroupsWithTypes:[types integerValue] usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [_dataSource addObject:group];
                if (self.picker.showAllAssetsAtFirst && [[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos) {
                    self.picker.showAllAssetsAtFirst = NO;
                    THCAssetsViewController * assetsViewController = [[THCAssetsViewController alloc] init];
                    assetsViewController.album = group;
                    assetsViewController.picker = self.picker;
                    [self.navigationController pushViewController:assetsViewController animated:NO];
                }
                
            }else {
            
                [self.tableView reloadData];
                
            }
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
}

- (void)loadAssetCollection
{
    [_dataSource removeAllObjects];
    
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    for (NSNumber * subtypeNumber in self.picker.assetCollectionSubtypes) {
        PHFetchResult * smartAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subtypeNumber.integerValue  options:nil];
        
        for (NSInteger i = 0; i < smartAlbumResult.count; i++) {
            PHAssetCollection * collection = smartAlbumResult[i];
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
           
            if (assetsFetchResult.count > 0) {
                [_dataSource addObject:collection];
            }
        }
    }
    
    PHFetchResult *topLevelUserResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    for (NSInteger i = 0; i < topLevelUserResult.count; i++) {
        PHAssetCollection * collection = topLevelUserResult[i];
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        if (assetsFetchResult.count > 0) {
            [_dataSource addObject:collection];
        }
    }

    [self.tableView reloadData];
    
    if (self.picker.showAllAssetsAtFirst) {
        self.picker.showAllAssetsAtFirst = NO;
        if (self.dataSource.count) {
            THCAssetsViewController * assetsViewController = [[THCAssetsViewController alloc] init];
            assetsViewController.album = self.dataSource[0];
            assetsViewController.picker = self.picker;
            [self.navigationController pushViewController:assetsViewController animated:NO];
        }
    }
}


#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPhotoAlbumCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"THCPhotoAlbumCell";
    THCPhotoAlbumCell * cell = (THCPhotoAlbumCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.album = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    THCAssetsViewController * assetsViewController = [[THCAssetsViewController alloc] init];
    assetsViewController.album = _dataSource[indexPath.row];
    assetsViewController.picker = self.picker;
    [self.navigationController pushViewController:assetsViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
