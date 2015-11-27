//
//  THCAssetsPreviewController.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/16.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCAssetsPreviewController.h"
#import "THCAssetsPreviewCell.h"
#import "THCAssetsPickerController.h"

@interface THCAssetsPreviewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,THCZoomScrollViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIView * toolBarView;

@property (nonatomic, strong) UIButton * selectedButton;
@property (nonatomic, strong) UILabel * selectedLabel;
@property (nonatomic, strong) UIButton * okButton;

@end

@implementation THCAssetsPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configAssetsPreviewControllerUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self performSelector:@selector(toolBarHiden) withObject:self afterDelay:1.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self toolBarShow];
}

- (void)configAssetsPreviewControllerUI
{
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", self.selectedIndex + 1, self.assetArray.count];
    
    _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedButton.frame = CGRectMake(0, 0, 25, 44);
    [_selectedButton setImage:[UIImage imageNamed:@"THCAssetsPickerController.bundle/THC_ico_photo_thumb_uncheck"] forState:UIControlStateNormal];
    [_selectedButton setImage:[UIImage imageNamed:@"THCAssetsPickerController.bundle/THC_ico_photo_thumb_check"] forState:UIControlStateSelected];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:_selectedButton];
    self.navigationItem.rightBarButtonItem = barItem;
    
    id asset = self.assetArray[self.selectedIndex];
    
    if ([self.selectedSet containsObject:asset]) {
        self.selectedButton.selected = YES;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    //collectionView
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    _flowLayout.minimumLineSpacing = 14;
    _flowLayout.minimumInteritemSpacing = 14;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 7, 0, 7);
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-7, 0, [UIScreen mainScreen].bounds.size.width + 14, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:_flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.clipsToBounds = YES;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[THCAssetsPreviewCell class] forCellWithReuseIdentifier:@"THCAssetsPreviewCell"];
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
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
        [_toolBarView addSubview:_okButton];
        [self setSelectedNum];
        [_okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 100, 30)];
        _selectedLabel.font = [UIFont boldSystemFontOfSize:16];
        _selectedLabel.textColor = [UIColor colorWithRed:0.29 green:0.3 blue:0.31 alpha:1];
        _selectedLabel.text = @"照片预览";
        [_selectedButton addTarget:self action:@selector(selectedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:_selectedLabel];
    }
    
}

- (void)okButtonAction:(UIButton *)btn
{
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        if (self.selectedSet.count) {
            [self.picker.delegate assetsPickerController:self.picker didFinishPickingAssets:[self.selectedSet array]];
        }else {
            NSInteger index = ABS(self.collectionView.contentOffset.x) / self.collectionView.frame.size.width;
            
            if (index >= 0 && index < self.assetArray.count) {
                id asset = self.assetArray[index];
              
                [self.picker.delegate assetsPickerController:self.picker didFinishPickingAssets:@[asset]];
            }
        }
        
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)selectedButtonAction:(UIButton *)btn
{
    NSInteger index = ABS(self.collectionView.contentOffset.x) / self.collectionView.frame.size.width;
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", index + 1, self.assetArray.count];
    
    if (index >= 0 && index < self.assetArray.count) {
        id asset = self.assetArray[index];
        
        if ([self.selectedSet containsObject:asset]) {
            self.selectedButton.selected = NO;
            [self.selectedSet removeObject:asset];
        }else {
            //选择
            if (self.selectedSet.count >= self.picker.maximalSelectedNum) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"你最多只能选择%ld张照片", self.picker.maximalSelectedNum] message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了" ,nil];
                [alertView show];
                return;
            }else {
                self.selectedButton.selected = YES;
                [self.selectedSet addObject:asset];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(assetsPreviewController:selected:index:)]) {
            [self.delegate assetsPreviewController:self selected:self.selectedButton.selected index:index];
        }
    }
    [self setSelectedNum];
}

- (void)viewWillLayoutSubviews
{
    _flowLayout.itemSize = self.view.bounds.size;
}

- (void)toolBarShow
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
        self.toolBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 40);
    }];
}

- (void)toolBarHiden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
        self.toolBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 1, [UIScreen mainScreen].bounds.size.width, 40);
    }];
}

- (void)setSelectedNum
{
    if (self.selectedSet.count) {
        [_okButton setTitle:[NSString stringWithFormat:@"确定(%ld)", self.selectedSet.count] forState:UIControlStateNormal];
    }else {
         [_okButton setTitle:@"确定" forState:UIControlStateNormal];
        
    }
}

#pragma mark - UICollectionViewDelegate DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    THCAssetsPreviewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"THCAssetsPreviewCell" forIndexPath:indexPath];
    [cell.zoomScrollView setAsset:self.assetArray[indexPath.row]];
    cell.zoomScrollView.actionDelgate = self;
    return cell;
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = ABS(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", index + 1, self.assetArray.count];
    
    if (index >= 0 && index < self.assetArray.count) {
        id asset = self.assetArray[index];
        
        if ([self.selectedSet containsObject:asset]) {
            self.selectedButton.selected = YES;
        }else {
            self.selectedButton.selected = NO;
        }
    }
}

#pragma mark - zoomScrollViewDelegate
- (void)zoomScrollView:(THCZoomScrollView *)zoomScrollView singleTap:(UITapGestureRecognizer *)tap isInImageView:(BOOL)isInImageView
{
    if (self.navigationController.navigationBar.isHidden) {
        [self toolBarShow];
    }else {
        [self toolBarHiden];
    }
}
- (void)zoomscrollview:(THCZoomScrollView *)zoomScrollView doubleTapInImageView:(UITapGestureRecognizer *)tap
{
    //双击
}

#pragma mark - 旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
