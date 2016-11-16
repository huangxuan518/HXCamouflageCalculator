//
//  UIImage+Extension.h
//  黄轩博客 blog.libuqing.com
//
//  Created by 黄轩 on 16/1/14.
//  Copyright © 2016年 IT小子. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

//通过颜色生成图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//按比例缩放,size 是你要把图显示到 多大区域 CGSizeMake(300, 140)
- (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;

//图片旋转
- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

@end
