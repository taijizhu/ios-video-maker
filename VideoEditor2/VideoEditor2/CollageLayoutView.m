//
//  CollageView.m
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayoutView.h"
#import "VAsset.h"
#import "CollageLayoutViewPlusBadge.h"

@interface CollageLayoutView ()

//array of UIImageView
@property (strong, nonatomic) NSMutableArray* imageViews;
@property (strong, nonatomic) CollageLayoutViewPlusBadge* plusBadge;

@end

@implementation CollageLayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageViews = [NSMutableArray new];
        
        self.plusBadge = [[CollageLayoutViewPlusBadge alloc] initWithFrame:[self getFrameForPlusBagde]];
        self.plusBadge.hidden = YES;
        
        [self addSubview:self.plusBadge];
    }
    return self;
}

-(void) setAssets:(NSArray *)assets
{
    _assets = assets;
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView* imageView = self.imageViews[i];
        
        if (self.assets.count > 0) {
            NSInteger j = i % self.assets.count;
            VAsset* asset = self.assets[j];
            
            [asset getPreviewImageForSize:imageView.bounds.size withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
                imageView.image = resultImage;
            }];
            
        } else {
            imageView.image = nil;
        }
    }
    
    self.plusBadge.hidden = (self.assets.count > self.imageViews.count) ? NO : YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

-(void) setCollageLayout:(CollageLayout *)collageLayout
{
    _collageLayout = collageLayout;
    
    [self.plusBadge removeFromSuperview];

    while (self.collageLayout.frames.count > self.imageViews.count) {
        UIImageView* imageView = [UIImageView new];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
    
    while (self.collageLayout.frames.count < self.imageViews.count) {
        UIImageView* imageView = self.imageViews[self.imageViews.count - 1];
        [imageView removeFromSuperview];
        [self.imageViews removeLastObject];
    }
    
    [self addSubview:self.plusBadge];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
}

-(CGFloat) getLayoutWidth {
    CGFloat layoutSize = 1;
    
    for (NSInteger i = 0; i < self.collageLayout.frames.count; i++) {
        CGRect rect = [self.collageLayout.frames[i] CGRectValue];
        
        layoutSize = MAX(layoutSize, rect.origin.x + rect.size.width);
    }
    
    return layoutSize;
}

-(CGFloat) getLayoutHeight {
    CGFloat layoutSize = 1;
    
    for (NSInteger i = 0; i < self.collageLayout.frames.count; i++) {
        CGRect rect = [self.collageLayout.frames[i] CGRectValue];
        
        layoutSize = MAX(layoutSize, rect.origin.y + rect.size.height);
    }
    
    return layoutSize;
}

-(CGRect) getFrameForPlusBagde
{
    CGFloat size  = 30;
    
    return CGRectMake(self.bounds.size.width - (size * 2), size, size, size);
}

-(void)layoutSubviews {
    CGFloat xScale = self.bounds.size.width / [self getLayoutWidth];
    CGFloat yScale = self.bounds.size.height / [self getLayoutHeight];
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        CGRect rect = [self.collageLayout.frames[i] CGRectValue];
        CGRect frame = CGRectMake(rect.origin.x * xScale, rect.origin.y * yScale, rect.size.width * xScale, rect.size.height * yScale);
        
        imageView.frame = frame;
    }
    
    self.plusBadge.frame = [self getFrameForPlusBagde];
}

@end
