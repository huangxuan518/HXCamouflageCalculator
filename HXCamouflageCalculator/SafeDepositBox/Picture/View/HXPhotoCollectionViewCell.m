//
//  HXPhotoCollectionViewCell.m
//  DDMMerchant
//
//  Created by Love on 16/5/18.
//  Copyright © 2016年 YISS. All rights reserved.
//

#import "HXPhotoCollectionViewCell.h"
#import "AssetHelper.h"
#import "PictureEntity.h"

@implementation HXPhotoCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data delegate:(id)delegate {
    if ([data isKindOfClass:[NSDictionary class]]) {
        ALAsset *asset = data[@"asset"];
        
        PictureEntity *picture = (PictureEntity *)data[@"data"];
        
        BOOL select = [data[@"select"] boolValue];
        
        if (asset) {
            _photoImageView.image = [ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_THUMBNAIL];
        } else if (picture) {
            NSString *name = picture.name;
            NSInteger time = picture.time;
            _photoImageView.image = [UIImage imageWithData:picture.data];
        }
        
        if (select) {
            _selectView.hidden = NO;
        } else {
            _selectView.hidden = YES;
        }
        
    }
}

@end
