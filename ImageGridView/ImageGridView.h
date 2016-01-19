//
//  ImageGridView.h
//  ImageGrid
//
//  Created by Wayne Tai on 2016/1/12.
//  Copyright © 2016年 IFIT LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageGridViewDataSource;

@interface ImageGridView : UIScrollView

@property (weak, nonatomic) id<ImageGridViewDataSource> dataSource;

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<ImageGridViewDataSource>)dataSource;

@end

@protocol ImageGridViewDataSource <NSObject>

@required

- (NSUInteger)numberOfImages;

- (CGFloat)imageGridView:(ImageGridView *)imageGridView widthOfImageAtIndex:(NSUInteger)index;

- (CGFloat)imageGridView:(ImageGridView *)imageGridView heightOfImageAtIndex:(NSUInteger)index;

- (UIImage *)imageGridView:(ImageGridView *)imageGridView imageAtIndex:(NSUInteger)index;

- (UIColor *)imageGridView:(ImageGridView *)imageGridView backgroundColorAtIndex:(NSUInteger)index;

@end
