//
//  THCAssetsPreviewController.h
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/16.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THCAssetsPreviewController;
@class THCAssetsPickerController;

@protocol THCAssetsPreviewControllerDelegate <NSObject>

- (void)assetsPreviewController:(THCAssetsPreviewController *)previeController selected:(BOOL)selected index:(NSInteger)index;

@end

@interface THCAssetsPreviewController : UIViewController

@property (nonatomic, weak) id<THCAssetsPreviewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray * assetArray;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) NSString * albumTitle;

@property (nonatomic, strong) NSMutableOrderedSet * selectedSet;

@property (nonatomic, weak) THCAssetsPickerController * picker;

@end
