//
//  UIView+PropertiesAccess.h
//  ImageGrid
//
//  Created by HungWeiTai on 2015/11/6.
//  Copyright © 2015年 IFIT LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PropertiesAccess)

@property (assign, nonatomic) CGFloat x;

@property (assign, nonatomic) CGFloat y;

@property (assign, nonatomic) CGFloat width;

@property (assign, nonatomic) CGFloat height;

@property (assign, nonatomic) CGPoint origin;

@property (assign, nonatomic) CGSize size;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)minX;
- (CGFloat)minY;

- (CGFloat)midX;
- (CGFloat)midY;

- (CGFloat)maxX;
- (CGFloat)maxY;

- (CGFloat)centerX;
- (CGFloat)centerY;

- (CGPoint)origin;
- (void)setOrigin:(CGPoint)origin;

- (CGSize)size;
- (void)setSize:(CGSize)size;

@end
