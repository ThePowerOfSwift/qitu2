//
//  QTSlideBtnView.m
//  qitu
//
//  Created by 上海企图 on 16/3/28.
//  Copyright © 2016年 上海企图. All rights reserved.
//

#import "QTSlideBtnView.h"
#import "Masonry.h"
/**
 *  screen -->> width/height
 */

#define ButtonSpace     kScreenWidth * 20/414
#define BaseTag         10000
#define kSlideBtn_H 35
#define kSlideLine_H 3
#define TITLEFONT 16*kScreenHeight/736

/**
 *  clolor
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface QTSlideBtnView ()<UIScrollViewDelegate>

@property(nonatomic, strong)UIImageView *lineView;

@property(nonatomic, strong)NSMutableArray *titleContentOrigin_X_Arr;

@property(nonatomic, strong)NSMutableArray *titleContentSize_Width_Arr;

@end

@implementation QTSlideBtnView{
    NSInteger BeforeButtonTag;
    NSInteger contentSize_width;
    NSInteger centerWordLocation_X;
}

- (id)initWithcontroller:(UIViewController *)VC TitleArr:(NSArray *)titleArr
{
    self = [super init];
    if (self) {
        self.frame = [self getViewFrame];
        self.backgroundColor = UIColorFromRGB(0xf5f5f5);
        self.pagingEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [VC.view addSubview:self];
        self.titleContentOrigin_X_Arr = [[NSMutableArray alloc] initWithCapacity:0];
        self.titleContentSize_Width_Arr = [[NSMutableArray alloc] initWithCapacity:0];
        self.titleArr = titleArr;
        [self confingSubviews];
        [self locateCenterWordPosition];
    }
    return self;
}

-(CGRect)getViewFrame
{
    CGRect frame = CGRectZero;
    frame.size.height = kSlideBtn_H;
    frame.size.width = kScreenWidth;
    frame.origin.x = 0;
    frame.origin.y = 0;
    return frame;
}

-(void)confingSubviews
{
    float contentWidth = 0.0;
    float Origin_X = ButtonSpace/2;
    for (int i = 0; i < self.titleArr.count; i ++) {
        UIButton *titleBt = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = [self.titleArr objectAtIndex:i];
        [titleBt setTag:BaseTag + i];
        if (i == 0) {
            titleBt.selected = YES;
            BeforeButtonTag = i;
        }
        [titleBt setTitle:title forState:UIControlStateNormal];
        titleBt.titleLabel.font = [UIFont systemFontOfSize:TITLEFONT];
        [titleBt setTitleColor:UIColorFromRGB(0x868686) forState:UIControlStateNormal];
        [titleBt setTitleColor:UIColorFromRGB(0x5c8aea) forState:UIControlStateSelected];
        [titleBt addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [titleBt setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:TITLEFONT + 1]};
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(ButtonSpace*11, kSlideBtn_H) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        [self addSubview:titleBt];
        
        [titleBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(Origin_X);
            make.top.equalTo(self.mas_top);
            make.height.mas_equalTo(kSlideBtn_H-5);
            make.width.mas_equalTo(textSize.width);
        }];
        [self.titleContentOrigin_X_Arr addObject:@(Origin_X)];
        contentWidth += (textSize.width + ButtonSpace);
        Origin_X += textSize.width + ButtonSpace;
        [self.titleContentSize_Width_Arr addObject:@(textSize.width)];
    }
    contentSize_width = contentWidth + ButtonSpace/2;
    self.contentSize = CGSizeMake(contentSize_width, kSlideBtn_H);
    
    [self addSubview:self.lineView];
    self.lineView.frame = CGRectMake([self.titleContentOrigin_X_Arr[0] floatValue], kSlideBtn_H - kSlideLine_H, [self.titleContentSize_Width_Arr[0] floatValue], kSlideLine_H);
    
}

-(UIImageView *)lineView
{
    if (_lineView == nil) {
        _lineView = [[UIImageView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0x5c8aea);
    }
    return _lineView;
}

- (void)selectType:(UIButton *)bt
{
    __weak typeof(self) weakself = self;
    CGFloat Origin_X = [self.titleContentOrigin_X_Arr[bt.tag - BaseTag] floatValue];
    if (BeforeButtonTag != bt.tag - BaseTag) {
        [self changeBeforeBtStatus:^{
            if (BeforeButtonTag < bt.tag - BaseTag) {
                /**
                 *  整体往左滚
                 */
                if (Origin_X < centerWordLocation_X) {
                    //no any reaction
                    NSLog(@"no any reaction");
                }else if (self.contentSize.width - Origin_X < kScreenWidth - centerWordLocation_X){
                    [self setContentOffset:CGPointMake(self.contentSize.width - kScreenWidth, 0)  animated:YES];
                }else{
                    [self setContentOffset:CGPointMake(Origin_X -centerWordLocation_X, 0)  animated:YES];
                }
                
            }else{
                /**
                 *  整体往右滚
                 */
                if (Origin_X < centerWordLocation_X) {
                    [self setContentOffset:CGPointMake(0, 0)  animated:YES];
                }else if (contentSize_width - Origin_X - 2 *ButtonSpace < centerWordLocation_X){
                    // no any reaction
                    NSLog(@"no any reaction");
                }else{
                    [self setContentOffset:CGPointMake(Origin_X - centerWordLocation_X, 0)  animated:YES];
                }
            }
            NSInteger index = bt.tag - BaseTag;
            bt.selected = !bt.selected;
            [weakself startAnimation:index];
        }];
        if (self.sbBlock) {
            self.sbBlock(bt.tag - BaseTag);
        }
        
    }else{
        return;
    }
}

-(void)startAnimation:(NSInteger)index
{
    [UIView animateWithDuration:0.2 animations:^{
        self.lineView.frame = CGRectMake([self.titleContentOrigin_X_Arr[index] floatValue], kSlideBtn_H - kSlideLine_H, [self.titleContentSize_Width_Arr[index] floatValue], kSlideLine_H);
        NSLog(@"当前分类--->>%@",self.titleArr[index]);
    } completion:^(BOOL finished) {
        BeforeButtonTag = index;
    }];
    
}

-(void)locateCenterWordPosition
{
    for (int i = 0; i < self.titleContentOrigin_X_Arr.count; i ++) {
        NSInteger origin_x = [self.titleContentOrigin_X_Arr[i] integerValue];
        NSInteger contentWidth = [self.titleContentSize_Width_Arr[i] integerValue];
        if (origin_x < kScreenWidth/2 && origin_x + contentWidth > kScreenWidth/2) {
            centerWordLocation_X = origin_x;
        }
    }
}

- (void)changeBeforeBtStatus:(void(^)())block
{
    UIButton *beforeBt = (UIButton *)[self viewWithTag:BaseTag + BeforeButtonTag];
    beforeBt.selected = !beforeBt.selected;
    if (block) {
        block();
    }
}

-(void)setSBScrollViewContentOffset:(NSInteger)index
{
    CGFloat Origin_X = [self.titleContentOrigin_X_Arr[index] floatValue];
    UIButton *nowBt = (UIButton *)[self viewWithTag:BaseTag + index];
    
    if (BeforeButtonTag < nowBt.tag - BaseTag) {
        /**
         *  整体往左滚
         */
        if (Origin_X < centerWordLocation_X) {
            //no any reaction
            NSLog(@"no any reaction");
        }else if (self.contentSize.width - Origin_X < kScreenWidth - centerWordLocation_X){
            [self setContentOffset:CGPointMake(self.contentSize.width - kScreenWidth, 0)  animated:YES];
        }else{
            [self setContentOffset:CGPointMake(Origin_X -centerWordLocation_X, 0)  animated:YES];
        }
        
    }else{
        /**
         *  整体往右滚
         */
        if (Origin_X < centerWordLocation_X) {
            [self setContentOffset:CGPointMake(0, 0)  animated:YES];
        }else if (contentSize_width - Origin_X - 2 *ButtonSpace < centerWordLocation_X){
            // no any reaction
            NSLog(@"no any reaction");
        }else{
            [self setContentOffset:CGPointMake(Origin_X - centerWordLocation_X, 0)  animated:YES];
        }
    }
    __weak typeof(self) weakself = self;
    [self changeBeforeBtStatus:^{
        UIButton *nowBt = (UIButton *)[self viewWithTag:BaseTag + index];
        nowBt.selected = !nowBt.selected;
        [weakself startAnimation:index];
    }];
}

@end
