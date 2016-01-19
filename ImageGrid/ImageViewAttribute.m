//
//  ImageViewAttribute.m
//  ImageGrid
//
//  Created by Wayne Tai on 2016/1/15.
//  Copyright © 2016年 IFIT LTD. All rights reserved.
//

#import "ImageViewAttribute.h"

@implementation ImageViewAttribute

+ (instancetype)attributeWithIndex:(NSUInteger)index width:(CGFloat)width height:(CGFloat)height {
    ImageViewAttribute *attribute = [[self alloc] init];
    attribute.index = index;
    attribute.width = width;
    attribute.height = height;
    return attribute;
}

- (void)resizeByNewHeight:(CGFloat)newHeight {
    CGFloat gradient = self.height / self.width;
    CGFloat newWidth = newHeight / gradient;
    
    self.width = newWidth;
    self.height = newHeight;
}

- (void)resizeByNewWidth:(CGFloat)newWidth {
    CGFloat gradient = self.height / self.width;
    CGFloat newHeight = newWidth * gradient;
    
    self.width = newWidth;
    self.height = newHeight;
}

@end
