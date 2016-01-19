//
//  ViewController.m
//  ImageGrid
//
//  Created by HungWeiTai on 2015/11/5.
//  Copyright © 2015年 IFIT LTD. All rights reserved.
//

#import "ImageGridViewController.h"
#import "UIView+PropertiesAccess.h"
#import "ImageGridView.h"

#define RANDOM_COLOR ((arc4random() % 256) / 255.0)

#define COLOR(r, g, b) [UIColor colorWithRed:r green:g blue:b alpha:1.0]

@interface ImageGridViewController () <ImageGridViewDataSource>

@end

@implementation ImageGridViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    ImageGridView *imageGridView = [[ImageGridView alloc] initWithFrame:self.view.frame dataSource:self];
    [self.view addSubview:imageGridView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ dealloc...", NSStringFromClass([self class]));
}

//Choose the fit one to append
/*s
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
*/

#pragma mark - ImageGridViewDataSource

- (NSUInteger)numberOfImages {
    return 100;
}

- (CGFloat)imageGridView:(ImageGridView *)imageGridView widthOfImageAtIndex:(NSUInteger)index {
    return 150.0 + (arc4random() % 21);
}

- (CGFloat)imageGridView:(ImageGridView *)imageGridView heightOfImageAtIndex:(NSUInteger)index {
    return 90.0 + (arc4random() % 21);
}

- (UIImage *)imageGridView:(ImageGridView *)imageGridView imageAtIndex:(NSUInteger)index {
    return nil;
}

- (UIColor *)imageGridView:(ImageGridView *)imageGridView backgroundColorAtIndex:(NSUInteger)index {
    return COLOR(RANDOM_COLOR, RANDOM_COLOR, RANDOM_COLOR);
}

@end