//
//  THCAssetsViewController.h
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/11.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THCAssetsPickerController;

@interface THCAssetsViewController : UIViewController

@property (nonatomic, strong) id album;

@property (nonatomic, weak) THCAssetsPickerController * picker;



@end
