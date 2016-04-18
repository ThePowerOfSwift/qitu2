//
//  APageImgScrV.m
//  qitu
//
//  Created by 上海企图 on 16/4/18.
//  Copyright © 2016年 上海企图. All rights reserved.
//

#import "APageImgScrV.h"
#import "BorderView.h"
#import "UIImageView+WebCache.h"
#import "APageImgItem.h"

@interface APageImgScrV ()<UIScrollViewDelegate>
@property (nonatomic, strong) BorderView *borderView;
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation APageImgScrV
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGRect imgRect = CGRectMake(CREATOR_IMG_PADDING, CREATOR_IMG_PADDING, frame.size.width-2*CREATOR_IMG_PADDING, frame.size.height-2*CREATOR_IMG_PADDING);
        self.imgView = [[UIImageView alloc] initWithFrame:imgRect];
        [self addSubview:_imgView];
        
        CGRect borderRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.borderView = [[BorderView alloc] initWithFrame:borderRect];
        self.borderView.backgroundColor = [UIColor grayColor];
        [self addSubview:_borderView];
        
    }
    return self;
}

- (void)initImgViewWith:(APageImgItem *)imgItem {
    [self.imgView setImage:[UIImage imageNamed:imgItem.imgStr]];
    //[self.imgView sd_setImageWithURL:[NSURL URLWithString:imgItem.imgStr]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

}


@end