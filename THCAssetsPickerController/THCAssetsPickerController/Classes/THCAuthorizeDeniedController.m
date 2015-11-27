//
//  THCAuthorizeDeniedController.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/12.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCAuthorizeDeniedController.h"

@interface THCAuthorizeDeniedController ()

@end

@implementation THCAuthorizeDeniedController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"无权访问相册";
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消  " style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.view.backgroundColor = [UIColor whiteColor];

    UIImageView * deniedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    deniedImageView.image = [UIImage imageNamed:@"THCAssetsPickerController.bundle/THC_icon_no_access"];
    deniedImageView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 40);
    [self.view addSubview:deniedImageView];
    
    UILabel * descLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(deniedImageView.frame) + 10 , self.view.frame.size.width - 32, 21)];
    descLabel.text = @"此应用程序没有权限来访问您的相册。";
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.textColor = [UIColor colorWithRed:0.2 green:0.28 blue:0.38 alpha:1];
    descLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:descLabel];
    
    UILabel * adviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(descLabel.frame) + 10 , self.view.frame.size.width - 32, 21)];
    adviceLabel.text = @"您可以在“隐私设置”中启用访问";
    adviceLabel.textAlignment = NSTextAlignmentCenter;
    adviceLabel.textColor = [UIColor colorWithRed:0.66 green:0.72 blue:0.72 alpha:1];
    adviceLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:adviceLabel];
}

- (void)rightItemAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
