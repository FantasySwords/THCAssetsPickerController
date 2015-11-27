//
//  THCAssetsPreviewCell.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/16.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCAssetsPreviewCell.h"
#import "THCZoomScrollView.h"

@implementation THCAssetsPreviewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configAssetsPreviewCellUI];
    }
    return self;
}

- (void)configAssetsPreviewCellUI
{
    self.backgroundColor = [UIColor redColor];
    
    _zoomScrollView = [[THCZoomScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_zoomScrollView];
}

- (void)layoutSubviews
{
    _zoomScrollView.frame = self.bounds;
}


@end
