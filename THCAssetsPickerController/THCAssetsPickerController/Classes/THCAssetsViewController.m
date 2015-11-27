//
//  THCAssetsViewController.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/11.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCAssetsViewController.h"
#import "THCAssetsCell.h"
#import "THCAssetsPickerController.h"
#import "THCAssetsPreviewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define kItemPadding 3

@interface THCAssetsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, THCAssetsCellDelegate, THCAssetsPreviewControllerDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) NSMutableOrderedSet * selectedSet;

@property (nonatomic, strong) UIView * toolBarView;

@property (nonatomic, strong) UILabel * selectedLabel;

@property (nonatomic, strong) UIButton * okButton;

@property (nonatomic, strong) UILabel * footerViewLabel;

@property (nonatomic, assign) BOOL needScrollToBottom;

@end

@implementation THCAssetsViewController
{
    ALAssetsLibrary * _assetLibrary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self initVariable];
    [self ConfigAssetsViewControllerUI];
}
- (void)initVariable
{
    if (self.picker.portraitOrientationAssetsCount == 0) {
        self.picker.portraitOrientationAssetsCount = 4;
    }
    
    if(self.picker.landscapeOrientationAssetsCount == 0){
        self.picker.landscapeOrientationAssetsCount = 7;
    }
    
    self.dataSource = [[NSMutableArray alloc] init];
    self.selectedSet = [[NSMutableOrderedSet alloc] init];
}

- (void)ConfigAssetsViewControllerUI
{
    //导航条
    if ([_album isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup * group = _album;
        self.navigationItem.title = [group valueForProperty:ALAssetsGroupPropertyName];
    }else if([_album isKindOfClass:[PHAssetCollection class]]){
        PHAssetCollection * collection = _album;
        self.navigationItem.title = collection.localizedTitle;
    }

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消  " style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightItem;

    //UICollectionView
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.sectionInset = UIEdgeInsetsMake(kItemPadding, 0, kItemPadding, 0);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 40) collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[THCAssetsCell class] forCellWithReuseIdentifier:@"THCAssetsCell"];
    [self.view addSubview:_collectionView];
    //toolBarView
    {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 40)];
        _toolBarView.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1];
        [self.view addSubview:_toolBarView];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _toolBarView.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_toolBarView addSubview:lineView];
        
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(CGRectGetMaxX(lineView.frame) - 82, 5, 70, 30);
        _okButton.backgroundColor = [UIColor colorWithRed:1 green:0.23 blue:0.21 alpha:1];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _okButton.layer.cornerRadius = 5;
        _okButton.layer.masksToBounds = YES;
        [_okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _okButton.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1];
        _okButton.enabled = NO;
        [_toolBarView addSubview:_okButton];
        [self setSelectedNum];
        
        [_okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 100, 30)];
        _selectedLabel.font = [UIFont boldSystemFontOfSize:16];
        _selectedLabel.textColor = [UIColor colorWithRed:0.29 green:0.3 blue:0.31 alpha:1];
        _selectedLabel.text = @"照片选择";
        [_toolBarView addSubview:_selectedLabel];
    }
    
    //加载相册图片
    if ([self.album isKindOfClass:[ALAssetsGroup class]]) {
        [self loadAssetsWithAssetsLibrary];
    }else if([self.album isKindOfClass:[PHAssetCollection class]]){
        [self loadAssetsWithPhotoLibrary];
    }

}

- (UILabel *)footerViewLabel
{
    if (_footerViewLabel ) {
        return _footerViewLabel;
    }
    
    _footerViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    
    _footerViewLabel.font = [UIFont systemFontOfSize:16];
    _footerViewLabel.backgroundColor = [UIColor whiteColor];
    _footerViewLabel.textColor = [UIColor blackColor];
    _footerViewLabel.textAlignment = NSTextAlignmentCenter;
    _footerViewLabel.text = @"共456张照片";
    return _footerViewLabel;
}

#pragma mark - UINavigationControllerItem Action
- (void)rightItemAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.picker.delegate assetsPickerControllerDidCancel:self.picker];
    }
}

- (void)setSelectedNum
{
    if (self.selectedSet.count) {
        [_okButton setTitle:[NSString stringWithFormat:@"确定(%ld)", self.selectedSet.count] forState:UIControlStateNormal];
        self.okButton.backgroundColor = [UIColor colorWithRed:1 green:0.23 blue:0.21 alpha:1];
        self.okButton.enabled = YES;

    }else {
        [_okButton setTitle:@"确定" forState:UIControlStateNormal];
        self.okButton.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1];
        self.okButton.enabled = NO;
    }
}

- (void)okButtonAction:(UIButton *)btn
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.picker.delegate assetsPickerController:self.picker didFinishPickingAssets:[self.selectedSet array]];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int width = 0;
    int count = 0;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        
        if (self.picker.portraitOrientationAssetsCount) {
            count = (int) self.picker.portraitOrientationAssetsCount;
        }else {
            count = 4;
        }
    
    } else if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        
        if (self.picker.portraitOrientationAssetsCount) {
            count = (int) self.picker.landscapeOrientationAssetsCount;
        }else {
            count = 7;
        }
    }
    
    width = ([UIScreen mainScreen].bounds.size.width - (count - 1) * kItemPadding) / count;
    
    _flowLayout.itemSize = CGSizeMake(width, width);
    _flowLayout.minimumLineSpacing = kItemPadding;
    _flowLayout.minimumInteritemSpacing = kItemPadding;
    _collectionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 40);
    
    if (self.needScrollToBottom && self.dataSource.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.needScrollToBottom = NO;
    }
}

#pragma mark - loadAssert
- (void)loadAssetsWithAssetsLibrary
{
    if (![self.album isKindOfClass:[ALAssetsGroup class]]) {
        return;
    }
    [_dataSource removeAllObjects];
    ALAssetsGroup * group = self.album;
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
       
                NSString * type = [result valueForProperty:ALAssetPropertyType];
                if ([type isEqualToString:@"ALAssetTypePhoto"]) {
                    [self.dataSource addObject:result];
                }
           
        }else {
            self.needScrollToBottom = YES;
            [self.collectionView reloadData];
        }
        
    }];
}

- (void)loadAssetsWithPhotoLibrary
{
    if (![self.album isKindOfClass:[PHAssetCollection class]]) {
        return;
    }
    [_dataSource removeAllObjects];
    
    PHAssetCollection * collection = self.album;
    PHFetchOptions * options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    
    [fetchResult enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {

        [self.dataSource addObject:obj];
    }];
    self.needScrollToBottom = YES;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    THCAssetsCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"THCAssetsCell" forIndexPath:indexPath];
    cell.delegate = self;
    id asset = self.dataSource[indexPath.row];
    
    if ([self.selectedSet containsObject:asset]) {
        cell.assetSelected = YES;
    }else {
        cell.assetSelected = NO;
    }
    
    cell.asset = asset;
    return cell;
}

#pragma mark - THCAssetsPreviewControllerDelegate
- (void)assetsPreviewController:(THCAssetsPreviewController *)previeController selected:(BOOL)selected index:(NSInteger)index
{
    THCAssetsCell * cell = (THCAssetsCell *)[self.collectionView  cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.assetSelected = selected;
    [self setSelectedNum];
}

#pragma mark - THCAssetsCellDelegate
- (void)assetsCell:(THCAssetsCell *)assetsCell imageTapWithAsset:(id)asset
{
    THCAssetsPreviewController * previewController = [[THCAssetsPreviewController alloc] init];
    previewController.assetArray = self.dataSource;
    previewController.selectedIndex = [self.collectionView indexPathForCell:assetsCell].row;
    previewController.albumTitle = self.navigationItem.title;
    previewController.selectedSet = self.selectedSet;
    previewController.delegate = self;
    previewController.picker = self.picker;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)assetsCell:(THCAssetsCell *)assetsCell selected:(BOOL)isSelected asset:(id)asset
{
    if (isSelected) {
        //取消选择
        assetsCell.assetSelected = NO;
        [self.selectedSet removeObject:asset];
    }else {
//        if ([asset isKindOfClass:[PHAsset class]] && [self CheckIsICloudAsset:asset]) {
//            NSLog(@"dd");
//            return;
//        }
        //选择
        if (self.selectedSet.count >= self.picker.maximalSelectedNum) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"你最多只能选择%ld张照片", self.picker.maximalSelectedNum] message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了" ,nil];
            [alertView show];
            return;
        }else {
            assetsCell.assetSelected = YES;
            [self.selectedSet addObject:asset];
        }
    }
    
    [self setSelectedNum];
}

//#pragma mark - 检查是否iCloudAsset
//- (BOOL)CheckIsICloudAsset:(PHAsset *)asset
//{
//    __block BOOL isICloudAsset;
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.networkAccessAllowed = NO;
//    options.resizeMode = PHImageRequestOptionsResizeModeFast;
//    options.synchronous = YES;
//    
//    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *  imageData, NSString *  dataUTI, UIImageOrientation orientation, NSDictionary * info) {
//        if([info[PHImageResultIsInCloudKey] boolValue]) {
//            isICloudAsset = YES;
//        }
//    }];
//    
//    return isICloudAsset;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
