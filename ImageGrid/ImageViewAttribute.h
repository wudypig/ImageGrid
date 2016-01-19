//
//  ImageViewAttribute.h
//  ImageGrid
//
//  Created by Wayne Tai on 2016/1/15.
//  Copyright © 2016年 IFIT LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface ImageViewAttribute : NSObject

@property (assign, nonatomic) NSUInteger index;

@property (assign, nonatomic) CGFloat width;

@property (assign, nonatomic) CGFloat height;

+ (instancetype)attributeWithIndex:(NSUInteger)index width:(CGFloat)width height:(CGFloat)height;

- (void)resizeByNewHeight:(CGFloat)newHeight;

- (void)resizeByNewWidth:(CGFloat)newWidth;

@end
