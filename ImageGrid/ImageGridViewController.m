//
//  ViewController.m
//  ImageGrid
//
//  Created by HungWeiTai on 2015/11/5.
//  Copyright © 2015年 IFIT LTD. All rights reserved.
//

#import "ImageGridViewController.h"
#import "UIView+PropertiesAccess.h"

#define NUMBER_OF_IMAGES 1000

#define ROWS_IN_SCREEN 5

#define RANDOM_COLOR ((arc4random() % 256) / 255.0)

#define COLOR(r, g, b) [UIColor colorWithRed:r green:g blue:b alpha:1.0]

typedef NS_ENUM(NSUInteger, ItemAppendState) {
    ItemAppendStateNone,
    ItemAppendStateRowFinished,
    ItemAppendStateSourceRunOut
};

CGFloat const kSideSpace = 1.0;
CGFloat const kItemSpace = 1.0;
CGFloat const kRowSpace = 1.0;

@interface ImageGridViewController ()

@property (weak, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *imageSource;

@property (strong, nonatomic) NSMutableArray *imageSourceByRows;

@property (strong, nonatomic) NSMutableArray *unfinishedRow;

@property (assign, nonatomic) CGFloat defaultRowHeight;

@property (assign, nonatomic) CGFloat defaultGradient;

@end

@implementation ImageGridViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _imageSource = [@[] mutableCopy];
        _imageSourceByRows = [@[] mutableCopy];
        _unfinishedRow = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self setup];
    
//    NSLog(@"imageSource: %@", self.imageSource);
    
    CGFloat startX;
    CGFloat startY = 1.0;
    for (NSArray<UIView *> *row in self.imageSourceByRows) {
        startX = 1.0;
        for (UIView *item in row) {
            [self.scrollView addSubview:item];
            item.x = startX;
            item.y = startY;
            
            startX = item.maxX + 1.0;
        }
        startY = [row firstObject].maxY + 1.0;
    }
    
    CGSize size = self.scrollView.contentSize;
    size.height = startY;
    [self.scrollView setContentSize:size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ dealloc...", NSStringFromClass([self class]));
}

#pragma mark - Setup

- (void)setup {
    [self createMainScrollView];
    [self createSourceImages];
    [self resizeAllImages];
    
    [self putImagesIntoRows];
    [self adjustEachRows];
//    NSLog(@"imageSourceByRows: %@", self.imageSourceByRows);
}

- (void)resizeAllImages {
    for (UIView *view in self.imageSource) {
        [view resizeToHeight:self.defaultRowHeight];
    }
}

- (void)putImagesIntoRows {
    NSMutableArray *bufferedImageSource = [self.imageSource mutableCopy];
    
    while (bufferedImageSource.count > 0) {
        NSArray *imagesInRow = [self putImagesInRow:[bufferedImageSource mutableCopy]];
        [self.imageSourceByRows addObject:imagesInRow];
        [bufferedImageSource removeObjectsInArray:imagesInRow];
        imagesInRow = nil;
    }
    
}

//Choose the fit one to append
/*
- (NSArray *)putImagesInRow:(NSMutableArray *)imageSource {
    
    NSMutableArray *row = (self.unfinishedRow)? [self.unfinishedRow mutableCopy]: [@[] mutableCopy];
    [row addObject:[imageSource firstObject]];
    [imageSource removeObjectAtIndex:0];
    
    CGFloat rowWidth = [self widthForRow:row includingSpacing:YES];
    BOOL isCurrentRowNeedsAppend = [self isRowNeedsAppendByWidth:rowWidth];
    
    while (isCurrentRowNeedsAppend && (imageSource.count > 0)) {
        UIView *choice = [self findOutBestChoiceInBuffer:imageSource forCurrentRowWidth:rowWidth];
        [row addObject:choice];
        [imageSource removeObject:choice];
        rowWidth = [self widthForRow:row includingSpacing:YES];
        isCurrentRowNeedsAppend = [self isRowNeedsAppendByWidth:rowWidth];
    }
    
    if (isCurrentRowNeedsAppend) {
        self.unfinishedRow = row;
    }
    
    [imageSource removeAllObjects];
    imageSource = nil;
    
    return row;
}
 */

//Put the next one
- (NSArray *)putImagesInRow:(NSMutableArray *)imageSource {
    
    NSMutableArray *row = (self.unfinishedRow)? [self.unfinishedRow mutableCopy]: [@[] mutableCopy];
    [row addObject:[imageSource firstObject]];
    [imageSource removeObjectAtIndex:0];
    
    CGFloat rowWidth = [self widthForRow:row includingSpacing:YES];
    BOOL isCurrentRowNeedsAppend = [self isRowNeedsAppendByWidth:rowWidth];
    
    while (isCurrentRowNeedsAppend && (imageSource.count > 0)) {
        UIView *choice = [imageSource firstObject];
        CGFloat newWidth = (rowWidth + choice.width + kSideSpace);
        if ([self distanceToScrollViewEdgeByWidth:newWidth] < [self distanceToScrollViewEdgeByWidth:rowWidth]) {
            [row addObject:choice];
            [imageSource removeObject:choice];
            rowWidth = [self widthForRow:row includingSpacing:YES];
        } else {
            isCurrentRowNeedsAppend = NO;
            break;
        }
        
        isCurrentRowNeedsAppend = [self isRowNeedsAppendByWidth:rowWidth];
    }
    
    if (isCurrentRowNeedsAppend) {
        self.unfinishedRow = row;
    }
    
    [imageSource removeAllObjects];
    imageSource = nil;
    
    return row;
}

- (UIView *)findOutBestChoiceInBuffer:(NSArray<UIView *> *)buffer forCurrentRowWidth:(CGFloat)rowWidth {
    CGFloat tmpTotalWidth = 0.0;
    UIView *tmpChoice = nil;
    for (UIView *item in buffer) {
        CGFloat newWidth = (rowWidth + item.width + kSideSpace);
        if ([self distanceToScrollViewEdgeByWidth:newWidth] < [self distanceToScrollViewEdgeByWidth:tmpTotalWidth]) {
            tmpChoice = item;
            tmpTotalWidth = newWidth;
        }
    }
    return tmpChoice;
}

- (CGFloat)distanceToScrollViewEdgeByWidth:(CGFloat)width {
    return fabs(self.scrollView.width - width);
}

- (void)adjustEachRows {
    for (NSArray *row in self.imageSourceByRows) {
        if (row != self.unfinishedRow) {
            CGFloat newHeight = [self newRowHeightForRow:row];
            [self adjustEachItemInRow:row newHeight:newHeight];
        }
    }
}

- (void)adjustEachItemInRow:(NSArray *)row newHeight:(CGFloat)newHeight {
    for (UIView *item in row) {
        [item resizeToHeight:newHeight];
    }
}

- (CGSize)sizeOfRow:(NSArray *)row {
    CGFloat width = [self widthForRow:row includingSpacing:YES];
    return (CGSize){width, self.defaultRowHeight};
}

- (CGFloat)newRowHeightForRow:(NSArray *)row {
    CGFloat totalWidth = [self widthForRow:row includingSpacing:NO];
    CGFloat actualWidth = self.scrollView.width - (kSideSpace * 2) - ((row.count - 1) * kSideSpace);
    CGFloat gradient = self.defaultRowHeight / totalWidth;
    CGFloat newHeight = actualWidth * gradient;
    return newHeight;
}

- (CGFloat)widthForRow:(NSArray *)row includingSpacing:(BOOL)spacing{
    CGFloat width = (spacing)? [self spacingForRow:row]: 0.0;
    for (UIView *item in row) {
        width += item.width;
    }
    return width;
}

- (CGFloat)spacingForRow:(NSArray *)row {
    CGFloat spacing = (row.count > 1)? ((row.count - 1) * kItemSpace): 0.0;
    spacing += kSideSpace * 2;
    return spacing;
}

- (BOOL)isRowNeedsAppendByWidth:(CGFloat)width {
    CGFloat actualWidth = self.scrollView.width - (kSideSpace * 2);
    return (width < (actualWidth * 0.9));
}

#pragma mark - Creation

- (void)createMainScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setContentSize:self.scrollView.size];
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)createSourceImages {
    for (NSInteger idx = 0; idx < NUMBER_OF_IMAGES; idx++) {
        [self.imageSource addObject:[self createRandomSizeOfView]];
    }
}

- (UIView *)createRandomSizeOfView {
    CGFloat width = (arc4random() % 301) + 350;
    CGFloat height = (arc4random() % 301) + 350;
    
    UIView *randomView = [[UIView alloc] initWithFrame:CGRectMake(1.0, 0.0, width, height)];
    [randomView setBackgroundColor:COLOR(RANDOM_COLOR, RANDOM_COLOR, RANDOM_COLOR)];
    
    return randomView;
}

#pragma mark - Gettet & Setter

- (CGFloat)defaultRowHeight {
    if (_defaultRowHeight == 0.0) {
        CGFloat screenHeight = self.view.height - 20.0 - ((ROWS_IN_SCREEN + 1) * kRowSpace);
        
        if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
            screenHeight -= self.navigationController.navigationBar.height;
        }
        if (self.navigationController && !self.navigationController.isToolbarHidden) {
            screenHeight -= self.navigationController.toolbar.height;
        }
        
        _defaultRowHeight = screenHeight / ROWS_IN_SCREEN;
    }
    return _defaultRowHeight;
}

- (CGFloat)defaultGradient {
    if (_defaultGradient == 0.0) {
        _defaultGradient =  self.defaultRowHeight / (self.view.width - (kSideSpace * 2));
    }
    return _defaultGradient;
}

@end

#pragma mark
#pragma mark - UIView Category Properties Access

@implementation UIView (ViewAdjust)

- (void)resizeToWidth:(CGFloat)width {
    CGFloat gradient = self.height / self.width;
    CGFloat newHeight = width * gradient;
    self.size = (CGSize){width, newHeight};
}

- (void)resizeToHeight:(CGFloat)height {
    CGFloat gradient = self.height / self.width;
    CGFloat newWidth = height / gradient;
    self.size = (CGSize){newWidth, height};
}

@end