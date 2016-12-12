//
//  SHAddCommodityViewController.m
//  DDMMerchant
//
//  Created by Love on 16/5/10.
//  Copyright © 2016年 YISS. All rights reserved.
//

#import "SHPhotoPreviewViewController.h"
#import "AJPhotoZoomingScrollView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SHPhotoPreviewViewController () <UIScrollViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation SHPhotoPreviewViewController {
    //data
    NSUInteger _currentPageIndex;
    NSMutableArray *_photos;
    
    //views
    UIScrollView *_photoScrollView;
    
    //Paging & layout
    NSMutableSet *_visiblePhotoViews,*_reusablePhotoViews;
}

#pragma mark - init

- (instancetype)initWithPhotos:(NSArray *)photos {
    self = [super init];
    if (self) {
        [self commonInit];
        _currentPageIndex = 0;
        [_photos addObjectsFromArray:photos];
    }
    return self;
}

- (instancetype)initWithPhotos:(NSArray *)photos index:(NSInteger)index {
    self = [super init];
    if (self) {
        [self commonInit];
        _currentPageIndex = index;
        if (index < 0)
            _currentPageIndex = 0;
        if (index > photos.count-1)
            _currentPageIndex = photos.count - 1;
        
        [_photos addObjectsFromArray:photos];
    }
    return self;
}

- (void)commonInit {
    _visiblePhotoViews = [[NSMutableSet alloc] init];
    _reusablePhotoViews = [[NSMutableSet alloc] init];
    _photos = [[NSMutableArray alloc] init];
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"预览";
    [self setRightItemWithTitle:@"删除" selector:@selector(delBtnAction:)];
    self.view.clipsToBounds = YES;
    //initUI
    [self initUI];
    
    [self showPhotoViewAtIndex:_currentPageIndex];
    
    [self setTitlePageInfo];
    //显示指定索引
    _photoScrollView.contentOffset = CGPointMake(_currentPageIndex * _photoScrollView.bounds.size.width, 0);
}

- (void)initUI {
    //photoScrollview
    _photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CONTENT_HEIGHT)];
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.delegate = self;
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.backgroundColor = UIColor.clearColor;
    _photoScrollView.contentSize = CGSizeMake(kScreenWidth * _photos.count, 0);
    [self.view addSubview:_photoScrollView];
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CONTENT_HEIGHT - 18 - 39, kScreenWidth, 18)];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:self.countLabel];
    }
    return _countLabel;
}

//开始显示
- (void)showPhotos {
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = floor((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floor((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= _photos.count) {
        firstIndex = _photos.count - 1;
    }
    if (lastIndex < 0){
        lastIndex = 0;
    }
    if (lastIndex >= _photos.count) {
        lastIndex = _photos.count - 1;
    }
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex = 0;
    for (AJPhotoZoomingScrollView *photoView in _visiblePhotoViews) {
        photoViewIndex = photoView.tag-100;
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView prepareForReuse];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:index];
        }
    }
}

//显示指定索引的图片
- (void)showPhotoViewAtIndex:(NSInteger)index {
    AJPhotoZoomingScrollView *photoView = [self dequeueReusablePhotoView];
    if (photoView == nil) {
        photoView = [[AJPhotoZoomingScrollView alloc] init];
    }
    
    //显示大小处理
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.origin.x = bounds.size.width * index;
    
    photoView.tag = 100 + index;
    photoView.frame = photoViewFrame;
    
    //显示照片处理
    UIImage *photo = nil;
    id photoObj = _photos[index];
    if ([photoObj isKindOfClass:[UIImage class]]) {
        photo = [self imageCompressionRatio:photoObj];
        //show
        [photoView setShowImage:photo];
    } else if ([photoObj isKindOfClass:[ALAsset class]]) {
        CGImageRef fullScreenImageRef = ((ALAsset *)photoObj).defaultRepresentation.fullScreenImage;
        photo = [UIImage imageWithCGImage:fullScreenImageRef];
        
        //show
        [photoView setShowImage:photo];
    } else if ([photoObj isKindOfClass:[NSString class]]) {
        [photoView setShowImageWithUrl:photoObj];
    }
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
}

#pragma mark - 图片尺寸处理

//1000PX以下不缩放； 1000-2000PX缩放至1/2大小；2000-4800PX缩放至1/4大小；4800PX以上缩放至1/8大小。
- (UIImage *)imageCompressionRatio:(UIImage *)image {
    int width = image.size.width;
    int height = image.size.height;
    
    float size;
    if (width > height) {
        size = width;
    } else {
        size = height;
    }
    
    UIImage *croppedImage;
    if (size > 4800) {
        croppedImage = [image imageCompressForSize:image targetSize:CGSizeMake(image.size.width/8, image.size.height/8)];
    } else if (size > 2000) {
        croppedImage = [image imageCompressForSize:image targetSize:CGSizeMake(image.size.width/4, image.size.height/4)];
    } else if (size > 1000) {
        croppedImage = [image imageCompressForSize:image targetSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    } else {
        croppedImage = [image imageCompressForSize:image targetSize:CGSizeMake(image.size.width, image.size.height)];
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation != UIDeviceOrientationPortrait) {
        
        CGFloat degree = 0;
        if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            degree = 180;// M_PI;
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            degree = -90;// -M_PI_2;
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            degree = 90;// M_PI_2;
        }
        croppedImage = [croppedImage rotatedByDegrees:degree];
    }
    
    NSLog(@"width:%f height:%f",croppedImage.size.width,croppedImage.size.height);
    
    return croppedImage;
}

//获取可重用的view
- (AJPhotoZoomingScrollView *)dequeueReusablePhotoView {
    AJPhotoZoomingScrollView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

//判断是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSInteger)index {
    for (AJPhotoZoomingScrollView* photoView in _visiblePhotoViews) {
        if ((photoView.tag - 100) == index) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Action

- (void)delBtnAction:(UIButton *)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认删除此图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil];
    [alert show];
}

#pragma mark - UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        id image;
        if (_photos.count > 0 && _currentPageIndex < _photos.count) {
            image = _photos[_currentPageIndex];
            [_photos removeObjectAtIndex:_currentPageIndex];
        }
        
        //reload;
        _currentPageIndex --;
        if (_currentPageIndex == -1 && _photos.count == 0) {
            [self backAction:nil];
        } else {
            _currentPageIndex = (_currentPageIndex == (-1) ? 0 : _currentPageIndex);
            if (_currentPageIndex == 0) {
                [self showPhotoViewAtIndex:0];
                [self setTitlePageInfo];
            }
            _photoScrollView.contentOffset = CGPointMake(_currentPageIndex * _photoScrollView.bounds.size.width, 0);
            _photoScrollView.contentSize = CGSizeMake(_photoScrollView.bounds.size.width * _photos.count, 0);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            if (_deleteCompletion) {
                _deleteCompletion(self,_photos,image);
            }
        });
       
    }
}

#pragma mark - uiscrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    int pageNum = floor((_photoScrollView.contentOffset.x - _photoScrollView.frame.size.width / (_photos.count+2)) / _photoScrollView.frame.size.width) + 1;
    _currentPageIndex = pageNum==_photos.count?pageNum-1:pageNum;
    [self setTitlePageInfo];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPageIndex = floor((_photoScrollView.contentOffset.x - _photoScrollView.frame.size.width / (_photos.count+2)) / _photoScrollView.frame.size.width) + 1;
    [self setTitlePageInfo];
}

- (void)setTitlePageInfo {
    NSString *title = [NSString stringWithFormat:@"%lu/%lu",_currentPageIndex+1,(unsigned long)_photos.count];
    self.countLabel.text = title;
}

- (void)dealloc {
    [_photos removeAllObjects];
    [_reusablePhotoViews removeAllObjects];
    [_visiblePhotoViews removeAllObjects];
}

@end
