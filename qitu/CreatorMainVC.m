//
//  CreatorMainVC.m
//  qitu
//
//  Created by 上海企图 on 16/3/26.
//  Copyright © 2016年 上海企图. All rights reserved.
//

#import "CreatorMainVC.h"
#import "BuyTemplateMainVC.h"
#import "CreatorCollectionCell.h"
#import "BuyTemplateContentVC.h"
#import "TemplatePreviewVC.h"
#import "QTSlideBtnView.h"
#import "QTBigScrollView.h"
#import "CategoryItem.h"
#import "StoreTemplateItem.h"

@interface CreatorMainVC ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UIImageView *navTitleImgV;
    CGFloat cellW;
    CGFloat cellH;
    NSArray *collectionArr;
}
@property (strong, nonatomic) UICollectionView *leftView;
@property (strong, nonatomic) BuyTemplateMainVC *rightVC;
@property (strong, nonatomic) UIView *rightView;
@property (nonatomic, strong) NSArray *categoryArr;

@end

@implementation CreatorMainVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavAndView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI
- (void)initNavAndView {
    UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 180, 40)];
    navTitleImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 180, 29)];
    navTitleImgV.image = [UIImage imageNamed:@"maka_mubanstore_buy"];
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
    btnLeft.tag = 20;
    [btnLeft addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(90, 0, 90, 40)];
    btnRight.tag = 21;
    [btnRight addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [navTitleView addSubview:navTitleImgV];
    [navTitleView addSubview:btnLeft];
    [navTitleView addSubview:btnRight];
    [self.navigationItem setTitleView:navTitleView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initialLeftUI];
    [self.mainScrollView addSubview:_leftView];
    [self getCategoryNetAction];
//    self.rightVC = [[BuyTemplateMainVC alloc] init];
//    [self.mainScrollView addSubview:_rightVC.view];
//    BuyTemplateContentVC *nextVC = [[BuyTemplateContentVC alloc] init];
//    nextVC.categoryId = -1;
//    [self.mainScrollView addSubview:nextVC.view];
    self.mainScrollView.contentSize = CGSizeMake(2*kScreenWidth, kContentH);
    
    cellW = (kScreenWidth-24*3-16)/3;
    cellH = cellW*307/190 + 25;
}

- (void)initialLeftUI {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _leftView = [[UICollectionView alloc]initWithFrame:CGRectMake(8, 0, kScreenWidth-16, kContentH) collectionViewLayout:flowLayout];
    _leftView.backgroundColor = RGBCOLOR(234, 234, 234);
    
    //设置代理
    self.leftView.delegate = self;
    self.leftView.dataSource = self;
    
    self.leftView.backgroundColor = [UIColor whiteColor];
    
    //注册cell和ReusableView（相当于头部）
    [self.leftView registerClass:[CreatorCollectionCell class] forCellWithReuseIdentifier:@"CollectionCell"];
}

- (void)confingSlideBtnView
{
    QTSlideBtnView *s = [[QTSlideBtnView alloc] initWithcontroller:self TitleArr:_categoryArr];
    QTBigScrollView *b = [[QTBigScrollView alloc] initWithcontroller:self TitleArr:_categoryArr];
    
    __weak typeof(s) Sweak = s;
    __weak typeof(b) Bweak = b;
    b.Bgbolck = ^(NSInteger index){
        [Sweak setSBScrollViewContentOffset:index];
    };
    s.sbBlock = ^(NSInteger index){
        [Bweak setBgScrollViewContentOffset:index];
    };
    
    self.rightView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kContentH)];
    [self.rightView addSubview:s];
    [self.rightView addSubview:b];
    [self.mainScrollView addSubview:_rightView];
}

#pragma mark - Net Request
- (void)getCategoryNetAction {
    QTAPIClient *QTClient = [QTAPIClient sharedClient];
    NSInteger interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *url = [NSString stringWithFormat:@"%@?timestamp=%@", kCategoryApp, @(interval)];
    [QTClient GET:url parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSArray *dataArr = responseObject[@"data"];
              self.categoryArr = [CategoryItem mj_objectArrayWithKeyValuesArray:dataArr];
              [self confingSlideBtnView];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              // 请求失败
              NSLog(@"%@", [error localizedDescription]);
          }];
}

#pragma mark - Action
- (void)touchUpInside:(UIButton *)sender {
    NSInteger tag = sender.tag;
    switch (tag) {
        case 20:
        {
        
        }
            break;
        case 21:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - QTBuyMainDelegate
- (void)revealNavPush:(StoreTemplateItem *)item {
    TemplatePreviewVC *nextVC = [[TemplatePreviewVC alloc] init];
    nextVC.webTitle = item.title;
    nextVC.templateId = item.ID;
    nextVC.mode = @"storeTemplate";
    [nextVC setHidesBottomBarWhenPushed:YES];
    [super.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [collectionArr count]+1;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"CollectionCell";
    CreatorCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    if (!cell) {
        NSLog(@"无法创建CollectionViewCell时打印，自定义的cell就不可能进来了。");
    }
    NSInteger row = indexPath.row;
    if (row == 0) {
        cell.imgView.image = [UIImage imageNamed:@"maka_muban_normal"];
        cell.text.text = @"通用版式";
    }else {
        //cell.imgView.image =
    }
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellW, cellH);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 12, 0, 12);
}
//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"选择%ld",indexPath.row);
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - UIScrollViewDelegate



@end
