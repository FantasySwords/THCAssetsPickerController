//
//  THCAssetsCell.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/11.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCAssetsCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface THCAssetsCell ()

@property(nonatomic, strong) UIImageView * assetsImageView;

@property(nonatomic, strong) UIButton * selectButton;

@end


@implementation THCAssetsCell

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configAssetsCellUI];
    }
    
    return self;
}

- (void)configAssetsCellUI
{
    _assetsImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _assetsImageView.contentMode = UIViewContentModeScaleAspectFill;
    _assetsImageView.clipsToBounds = YES;
    [self addSubview:_assetsImageView];
    _assetsImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_assetsImageView addGestureRecognizer:tap];
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectButton.frame = CGRectMake(self.frame.size.width - 30, 0, 30, 30);
    [_selectButton setImage:[UIImage imageNamed:@"THCAssetsPickerController.bundle/THC_ico_photo_thumb_uncheck"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"THCAssetsPickerController.bundle/THC_ico_photo_thumb_check"] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectButton];
}

- (void)tapAction
{
    if ([self.delegate respondsToSelector:@selector(assetsCell:imageTapWithAsset:)]) {
        [self.delegate assetsCell:self imageTapWithAsset:self.asset];
    }
}

- (void)selectButtonAction
{    
    if ([self.delegate respondsToSelector:@selector(assetsCell:selected:asset:)]) {
        [self.delegate assetsCell:self
                         selected:self.selectButton.selected
                            asset:self.asset];
    }
}

- (void)setAssetSelected:(NSInteger)assetSelected
{
    self.selectButton.selected = assetSelected;
}

- (void)setAsset:(id)asset
{
    _asset = asset;
    
    if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset * alAsset = asset;
    
        self.assetsImageView.image = [UIImage imageWithCGImage:alAsset.thumbnail];
        
    }else if([asset isKindOfClass:[PHAsset class]]){
        
        PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        NSInteger retinaScale = [UIScreen mainScreen].scale;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(self.frame.size.width * retinaScale, self.frame.size.height * retinaScale)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:requestOptions
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            self.assetsImageView.image = result;
            
        }];
    }
    
}

@end
