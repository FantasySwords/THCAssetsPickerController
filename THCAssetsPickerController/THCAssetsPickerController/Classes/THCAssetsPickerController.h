//
//  THCAssetsPickerController.h
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/7/27.
//  Copyright (c) 2015年 Jerry Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THCAssetsPickerController;

@protocol THCAssetsPickerControllerDelegate <NSObject>

@optional

- (void)assetsPickerController:(THCAssetsPickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;

- (void)assetsPickerControllerDidCancel:(THCAssetsPickerController *)imagePickerController;

//- (BOOL)assetsPickerController:(THCAssetsPickerController *)imagePickerController shouldSelectAsset:(id)asset;
//
//- (void)assetsPickerController:(THCAssetsPickerController *)imagePickerController didSelectAsset:(id)asset;
//
//- (void)assetsPickerController:(THCAssetsPickerController *)imagePickerController didDeselectAsset:(id)asset;

@end

@interface THCAssetsPickerController : UINavigationController

@property(nonatomic, assign) NSInteger portraitOrientationAssetsCount;

@property(nonatomic, assign) NSInteger landscapeOrientationAssetsCount;

@property(nonatomic, assign) NSInteger maximalSelectedNum;

@property(nonatomic, weak) id<THCAssetsPickerControllerDelegate, UINavigationControllerDelegate> delegate;

@property(nonatomic, assign) BOOL showAllAssetsAtFirst; //default is NO

@property(nonatomic, strong) NSArray * assetCollectionSubtypes;

@end
