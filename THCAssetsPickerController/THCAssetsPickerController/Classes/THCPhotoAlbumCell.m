//
//  THCPhotoAlbumCell.m
//  THCAssetsPickerController
//
//  Created by hejianyuan on 15/11/11.
//  Copyright © 2015年 Jerry Ho. All rights reserved.
//

#import "THCPhotoAlbumCell.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface THCPhotoAlbumCell ()

@property (nonatomic, strong) UIImageView * albumImageView;

@property (nonatomic, strong) UILabel * albumTitleLabel;

@property (nonatomic, strong) UILabel * albumCountLabel;

@end

@implementation THCPhotoAlbumCell

- (void)awakeFromNib
{

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier: reuseIdentifier]) {
        [self configPhotoAlbumCellUI];
    }
    
    return self;
}

- (void)configPhotoAlbumCellUI
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 8, kPhotoAlbumCellHeight - 16, kPhotoAlbumCellHeight - 16)];
    _albumImageView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_albumImageView];
    
    _albumTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_albumImageView.frame)+ 16, 21, [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(_albumImageView.frame) - 20, 20)];
    //_albumTitleLabel.text = @"全部照片空间了";
    _albumTitleLabel.font = [UIFont systemFontOfSize:16];
    _albumTitleLabel.textColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1];
    [self addSubview:_albumTitleLabel];
    
    _albumCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_albumImageView.frame)+ 17, 45, [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(_albumImageView.frame) - 20, 20)];
    _albumCountLabel.font = [UIFont systemFontOfSize:12];
    _albumCountLabel.textColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1];
    //_albumCountLabel.text = @"23";
    [self addSubview:_albumCountLabel];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated: animated];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    }else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Public

- (void)setAlbum:(id)album
{
    if ([album isKindOfClass:[ALAssetsGroup class]]) {
        
        ALAssetsGroup * group = album;
        self.albumImageView.image = [UIImage imageWithCGImage:[group posterImage]];
        self.albumTitleLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
        self.albumCountLabel.text = [NSString stringWithFormat:@"%ld", [group numberOfAssets]];
        
    }else if([album isKindOfClass:[PHAssetCollection class]]){
        
        PHAssetCollection * collection = album;
        
        PHFetchOptions * options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        self.albumTitleLabel.text = collection.localizedTitle;
       
        PHAsset *asset = [fetchResult firstObject];
        PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat dimension = 78.0f;
        CGSize size = CGSizeMake(dimension*scale, dimension*scale);
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            self.albumImageView.image = result;
        }];
        
        self.albumCountLabel.text = [NSString stringWithFormat:@"%ld", fetchResult.count];
    }
}

@end
