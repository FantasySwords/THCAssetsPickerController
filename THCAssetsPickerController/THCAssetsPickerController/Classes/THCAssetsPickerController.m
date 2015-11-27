//
//  THCAssetsPickerController.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/7/27.
//  Copyright (c) 2015年 Jerry Ho. All rights reserved.
//

#import "THCAssetsPickerController.h"
#import "THCAssetsViewController.h"
#import "THCPhotoAlbumController.h"
#import "THCAuthorizeDeniedController.h"
#import "THCAssetsViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface THCAssetsPickerController ()

@end


@implementation THCAssetsPickerController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAssetCollectionSubtypes];
    //配置UI
    [self configAssetsPickerControllerUI];
}

- (void)initAssetCollectionSubtypes
{
    if (self.assetCollectionSubtypes) {
        return;
    }
    
    NSMutableArray *  assetCollectionSubtypes = [@[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                                   @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                                   @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                                   @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                                   @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded)] mutableCopy];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f) {
        [assetCollectionSubtypes addObjectsFromArray:@[@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),
                                                       @(PHAssetCollectionSubtypeSmartAlbumScreenshots)
                                                       ]];
    }
    
    self.assetCollectionSubtypes = assetCollectionSubtypes;

 }

- (void)configAssetsPickerControllerUI
{
    //iOS版本低于8.0使用ALAssetsLibrary
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
            //没有权限,显示拒绝查看控制器
            THCAuthorizeDeniedController * authorizeDeniedController = [[THCAuthorizeDeniedController alloc] init];
            [self pushViewController:authorizeDeniedController animated:NO];
            return;
        }
    }else {
        //iOS版本高于8.0使用Photos
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
            THCAuthorizeDeniedController * authorizeDeniedController = [[THCAuthorizeDeniedController alloc] init];
            [self pushViewController:authorizeDeniedController animated:NO];
            return;
        }
    }
    
    THCPhotoAlbumController * photoAlbumController = [[THCPhotoAlbumController alloc] init];
    photoAlbumController.picker = self;
    [self pushViewController:photoAlbumController animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
