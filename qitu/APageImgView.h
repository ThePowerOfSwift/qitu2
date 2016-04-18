//
//  APageImgView.h
//  qitu
//
//  Created by 上海企图 on 16/4/18.
//  Copyright © 2016年 上海企图. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderView.h"
@class APageImgItem;

@interface APageImgView : UIView
@property (strong, nonatomic) BorderView *borderView;
@property (strong, nonatomic) UIImageView *imgView;
- (void)initImgViewWith:(APageImgItem *)imgItem;
@end