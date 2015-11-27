//
//  THCAssetsCell.h
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/11.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THCAssetsCell;

@protocol THCAssetsCellDelegate <NSObject>

- (void)assetsCell:(THCAssetsCell *)assetsCell selected:(BOOL)isSelected asset:(id)asset;

- (void)assetsCell:(THCAssetsCell *)assetsCell imageTapWithAsset:(id)asset;

@end

@interface THCAssetsCell : UICollectionViewCell

@property (nonatomic, strong) id asset;

@property (nonatomic, weak) id<THCAssetsCellDelegate> delegate;

@property (nonatomic, assign) NSInteger assetSelected;

@end
