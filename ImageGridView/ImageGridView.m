//
//  ImageGridView.m
//  ImageGrid
//
//  Created by Wayne Tai on 2016/1/12.
//  Copyright © 2016年 IFIT LTD. All rights reserved.
//

#import "ImageGridView.h"
#import "ImageViewAttribute.h"
#import "UIView+PropertiesAccess.h"

#define ROWS_IN_SCREEN 5

static CGFloat const kSideSpace = 1.0;
static CGFloat const kItemSpace = 1.0;
static CGFloat const kRowSpace = 1.0;

typedef NS_ENUM(NSUInteger, ItemAppendState) {
    ItemAppendStateNone,
    ItemAppendStateRowFinished,
    ItemAppendStateSourceRunOut
};

static NSString *const kImageViewAttributeWidth = @"width";
static NSString *const kImageViewAttributeHeight = @"height";
static NSString *const kImageViewAttributeImageView = @"imageView";

static NSUInteger currentLevel = 0;

static BOOL rowFinished = NO;

@interface ImageGridView ()

@property (strong, nonatomic) NSMutableArray *reusableQueue;

@property (strong, nonatomic) NSMutableArray<ImageViewAttribute *> *imageSource;

@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *imageSourceByRows;

@property (assign, nonatomic) NSUInteger unfinishedRow;

@property (assign, nonatomic) CGFloat defaultRowHeight;

@property (assign, nonatomic) CGFloat defaultGradient;

@end

@implementation ImageGridView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<ImageGridViewDataSource>)dataSource {
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = dataSource;
        [self initProperties];
        [self retrieveImageSource];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self resizeAllImages];
    [self putImageToRow];
    [self adjustEachRow];
    [self draw];
    
    [super drawRect:rect];
}

- (void)initProperties {
    _reusableQueue = [@[] mutableCopy];
    _imageSource = [@[] mutableCopy];
    _imageSourceByRows = [@[] mutableCopy];
    
    _unfinishedRow = 0;
    _defaultRowHeight = self.height / ROWS_IN_SCREEN;
    _defaultGradient =  self.defaultRowHeight / (self.width - (kSideSpace * 2));
}

- (void)retrieveImageSource {
    NSUInteger numberOfImages = [self.dataSource numberOfImages];
    for (NSUInteger index = 0; index < numberOfImages; index++) {
        CGFloat width = [self.dataSource imageGridView:self widthOfImageAtIndex:index];
        CGFloat height = [self.dataSource imageGridView:self heightOfImageAtIndex:index];
        [self.imageSource addObject:[ImageViewAttribute attributeWithIndex:index width:width height:height]];
    }
}

- (void)resizeAllImages {
    for (ImageViewAttribute *viewAttribute in self.imageSource) {
        [viewAttribute resizeByNewHeight:self.defaultRowHeight];
    }
}

#pragma mark - Handle Data Source
#pragma mark Split Data into Rows

- (void)putImageToRow {
    while (self.imageSource.count > 0) {
        if (currentLevel == 0) {
            [self.imageSourceByRows addObject:[@[] mutableCopy]];
            currentLevel++;
            rowFinished = NO;
            [self putImageToRow];
        } else {
            NSMutableArray *currentRow = [self.imageSourceByRows lastObject];
            CGFloat rowWidth = [self widthForRow:currentRow includingSpacing:YES];
            BOOL isCurrentRowNeedsAppend = [self isRowNeedsAppendByWidth:rowWidth];
            
            if (isCurrentRowNeedsAppend) {
                ImageViewAttribute *attribute = [self.imageSource firstObject];
                CGFloat newWidth = (rowWidth + attribute.width + kSideSpace);
                
                if ([self distanceToScrollViewEdgeByWidth:newWidth] < [self distanceToScrollViewEdgeByWidth:rowWidth]) {
                    [currentRow addObject:attribute];
                    [self.imageSource removeObject:attribute];
                    currentLevel++;
                    [self putImageToRow];
                } else {
                    currentLevel--;
                    rowFinished = YES;
                    return;
                }
            } else {
                currentLevel--;
                rowFinished = YES;
                return;
            }
        }
    }
}

- (CGFloat)widthForRow:(NSArray *)row includingSpacing:(BOOL)spacing{
    if (row.count == 0) {
        return 0.0;
    }
    CGFloat width = (spacing)? [self spacingForRow:row]: 0.0;
    for (ImageViewAttribute *attribute in row) {
        width += attribute.width;
    }
    return width;
}

- (CGFloat)spacingForRow:(NSArray *)row {
    CGFloat spacing = (row.count > 1)? ((row.count - 1) * kItemSpace): 0.0;
    spacing += kSideSpace * 2;
    return spacing;
}

- (BOOL)isRowNeedsAppendByWidth:(CGFloat)width {
    CGFloat actualWidth = self.width - (kSideSpace * 2);
    return (width < (actualWidth * 0.9));
}

- (CGFloat)distanceToScrollViewEdgeByWidth:(CGFloat)width {
    return fabs(self.width - width);
}

#pragma mark Adjust Each Row

- (void)adjustEachRow {
    NSUInteger lastIndex = self.imageSourceByRows.count - 1;
    [self.imageSourceByRows enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull row, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < lastIndex || (idx == lastIndex && rowFinished)) {
            CGFloat newHeight = [self newRowHeightForRow:row];
            for (ImageViewAttribute *attribute in row) {
                [attribute resizeByNewHeight:newHeight];
            }
        }
    }];
}

- (CGFloat)newRowHeightForRow:(NSArray *)row {
    CGFloat totalWidth = [self widthForRow:row includingSpacing:NO];
    CGFloat actualWidth = self.width - (kSideSpace * 2) - ((row.count - 1) * kSideSpace);
    CGFloat gradient = self.defaultRowHeight / totalWidth;
    CGFloat newHeight = actualWidth * gradient;
    return newHeight;
}

- (void)draw {
    CGFloat startX;
    CGFloat startY = 1.0;
    for (NSArray<ImageViewAttribute *> *row in self.imageSourceByRows) {
        startX = 1.0;
        for (ImageViewAttribute *attribute in row) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(startX, startY, attribute.width, attribute.height);
            imageView.image = [self.dataSource imageGridView:self imageAtIndex:attribute.index];
            imageView.backgroundColor = [self.dataSource imageGridView:self backgroundColorAtIndex:attribute.index];
            [self addSubview:imageView];
            
            startX = imageView.maxX + kItemSpace;
        }
        ImageViewAttribute *attribute = [row firstObject];
        startY += attribute.height + kRowSpace;
    }
    
    CGSize size = self.contentSize;
    size.height = startY;
    [self setContentSize:size];
}

#pragma mark - Resuable Queue

- (void)enqueueItem:(UIImageView *)item {
    [self.reusableQueue addObject:item];
    [item setImage:nil];
    [item removeFromSuperview];
}

- (UIImageView *)dequeueItem {
    if (self.reusableQueue.count > 0) {
        UIImageView *imageView = [self.reusableQueue lastObject];
        [self.reusableQueue removeLastObject];
        return imageView;
    } else {
        return [[UIImageView alloc] init];
    }
}

@end
