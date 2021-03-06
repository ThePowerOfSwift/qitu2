//
//  DiyTemplateMainVC.m
//  qitu
//
//  Created by 上海企图 on 16/3/31.
//  Copyright © 2016年 上海企图. All rights reserved.
//

#import "DiyTemplateMainVC.h"
//#import "SelectBgColor.h"
#import "DiyBottomBar.h"
#import "DiyMainBottomBar.h"
#import "DiyPageSortBottomBar.h"
#import "DiyOnePageCell.h"
#import "DiyAddPageView.h"
#import "DiyCollectionView.h"
#import "SelectImageVC.h"
#import "DiyTextContentView.h"
#import "DiyTextStyleView.h"
#import "UIColor+Hex.h"

static const CGFloat kBottomBar_MHeight = 50.0;
static const CGFloat kBottomBar_BHeight = 170.0;
static const CGFloat kCollectionView_Top = 5.0;

@interface DiyTemplateMainVC ()<DiyTextStyleViewDelegate, DiyMainBottomBar, DiyBottomBarDelegate, DiyShowDelgate, DiyPageSortDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, UIActionSheetDelegate, UITextViewDelegate>
{
    UIView *tapView;
    DIY_SEL_ITEM tapViewStyle;
    
    CGFloat cellW;
    CGFloat cellH;
    CGFloat cellPadding;
    NSArray *selColors;//供选择的颜色列表
    NSMutableArray *pagesArr;
    NSInteger _curPageIndex;

    DiyBottomBar *diyBottomBar;
    DiyMainBottomBar *diyMainBottomBar;
    DiyPageSortBottomBar *diyPageSortBottomBar;
    
    DiyTextContentView *txtContentV;
    DiyTextStyleView *txtStyleV;

    NSMutableArray *pageImgShotMArr;//页面截图数组
    ENUM_DIY_TYPE bottomStyle;
    
    UIView *_preSelectedElement;//上一次选中的图、文
    UIView *_selectedElement;//当前选中的图、文
}
@property (strong, nonatomic) DiyCollectionView *myCollectionView;
@end

@implementation DiyTemplateMainVC
- (void)viewDidLoad {
    [super viewDidLoad];
     pageImgShotMArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        UIImage *img = [UIImage imageNamed:@"Intro_2"];
        [pageImgShotMArr addObject:img];
    }
    [self loadData];
    [self initNavAndView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:@"CropOK" object:nil];
    [self registerForKeyboardNotifications];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [self freeKeyboardNotifications];
    [super viewDidDisappear:animated];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (DiyCollectionView *)myCollectionView {
    if (_myCollectionView != nil) {
        return _myCollectionView;
    }

    cellPadding = 45*kScreenWidth/320.0;
    cellW = kScreenWidth-2*cellPadding;
    cellH = cellW*36/23.0;
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.headerReferenceSize = CGSizeMake(33, cellH);
    flowLayout.footerReferenceSize = CGSizeMake(33, cellH);
    flowLayout.itemSize = CGSizeMake(cellW, cellH);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _myCollectionView = [[DiyCollectionView alloc]initWithFrame:CGRectMake(0, GLOBAL_NAVTOP_HEIGHT, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight) collectionViewLayout:flowLayout];
    _myCollectionView.dataSource = self;
    _myCollectionView.delegate = self;
    _myCollectionView.showsHorizontalScrollIndicator = NO;
    _myCollectionView.backgroundColor = RGBCOLOR(57, 57, 57);
    [_myCollectionView registerClass:[DiyOnePageCell class] forCellWithReuseIdentifier:@"DiyOnePageCell"];
    
    return _myCollectionView;
}

- (void)initNavAndView {
    [self setNavTitle:_myTitle];
    [self setNavBackBarSelector:@selector(navBack)];
    [self setNavRightBarBtnTitle:@"预览" selector:@selector(navPreview)];
    
    self.view.backgroundColor = RGBCOLOR(57, 57, 57);
    
    [self.view addSubview:self.myCollectionView];
    
     //视图上移回归初始位置辅助视图
    tapView = [[UIView alloc] initWithFrame:_myCollectionView.bounds];
    tapView.hidden = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tapView addGestureRecognizer:tapGesture];
    [self.view addSubview:tapView];
    
     //点击页面背景底部工具栏视图
    diyMainBottomBar = [[DiyMainBottomBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-kBottomBar_MHeight, kScreenWidth, kBottomBar_MHeight) actionHandler:self];
    diyMainBottomBar.pageNum = [pagesArr count]-1;
    [self.view addSubview:diyMainBottomBar];
   
     //点击图片、文字底部工具栏视图
    diyBottomBar = [[DiyBottomBar alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_MHeight)];
    [diyBottomBar setActionHandler:self];
    [self.view addSubview:diyBottomBar];
    
    //添加页面排序视图
    diyPageSortBottomBar = [[DiyPageSortBottomBar alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_BHeight) withImages:pageImgShotMArr];
    diyPageSortBottomBar.imgDataType = 0;
    diyPageSortBottomBar.delegate = self;
    [self.view addSubview:diyPageSortBottomBar];
    
    //添加文本内容视图
    txtContentV = [[DiyTextContentView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_MHeight+30)];
    [txtContentV setDiyTextContentHandler:self selector:@selector(textContentDoneAction)];
    [self.view addSubview:txtContentV];
    
    //添加文本样式视图
    selColors = @[@"#040404", @"#FFFFFF", @"#25CDCF", @"#167FA3", @"#17AFEE",
                  @"#59C2F2", @"#3B7FBC", @"#0A4CA9", @"#5248FE", @"#6228F2",
                  @"#676BFB", @"#7751F1", @"#952CBE", @"#CA32AF", @"#F12084"];
    txtStyleV = [[DiyTextStyleView alloc] initWithColors:selColors];
    txtStyleV.colorIdx = 0;
    txtStyleV.textAlign = ENUM_DIY_TEXTMIDDLE;
    txtStyleV.fontSizeSlider.value = 15;
    txtStyleV.delegate = self;
    [txtStyleV.fontSizeSlider addTarget:self action:@selector(sliderFontSizeChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:txtStyleV];
    
//    DiyBottomBar *diyBottomBar = [[DiyBottomBar alloc] initWithFrame:CGRectMake(0, 105, kScreenWidth, 50)];
//    bgColors = @[@"#040404", @"#FFFFFF", @"#25CDCF", @"#167FA3", @"#17AFEE",
//                 @"#59C2F2", @"#3B7FBC", @"#0A4CA9", @"#5248FE", @"#6228F2",
//                 @"#676BFB", @"#7751F1", @"#952CBE", @"#CA32AF", @"#F12084"];
//    SelectBgColor *bgColorView = [[SelectBgColor alloc] initWithColors:bgColors];
//    bgColorView.colorIdx = 1;
//    [bgColorView.slider addTarget:self action:@selector(changeAlphaValue) forControlEvents:UIControlEventValueChanged];
//    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-155, kScreenWidth, 155)];
//    [bottomView addSubview:bgColorView];
//    [bottomView addSubview:diyBottomBar];
//    [self.view addSubview:bottomView];
//    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)navBack {
    
}
- (void)navPreview {

}

- (void)textContentDoneAction {
    [txtContentV.textTV resignFirstResponder];
}
-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    // Move
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    NSLog(@"keyboard..%f..%f..%f..%f",keyboardFrame.origin.x, keyboardFrame.origin.y, keyboardFrame.size.width, keyboardFrame.size.height);
    _myCollectionView.frame = CGRectMake(0, kCollectionView_Top, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
    CGRect tempRect = txtContentV.frame;
    tempRect.origin.y = kScreenHeight-keyboardFrame.size.height-kBottomBar_MHeight-30;
    txtContentV.frame = tempRect;
    [UIView commitAnimations];
}
-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    // Move
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    _myCollectionView.frame = CGRectMake(0, GLOBAL_NAVTOP_HEIGHT, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
    txtContentV.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_MHeight);
    [UIView commitAnimations];
}

#pragma mark - LoadData
- (void)loadData {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    NSError *error;
    NSDictionary *jsonSerialData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (!jsonSerialData && error) {
        NSLog(@"Error:%@", error);
    }
    
    pagesArr = [NSMutableArray array];
    NSArray *scenesArr = jsonSerialData[@"scene"];
    NSInteger scenesCount = [scenesArr count];
    for (NSInteger i = 0; i < scenesCount; i++) {
        NSDictionary *aPageDic = scenesArr[i];
        NSArray *aPageArr = aPageDic[@"content"];
        DiyAPageItem *apageItem = [[DiyAPageItem alloc] init];
        apageItem.pageType = DIY_PAGETYPE_SHOW;
        apageItem.bgColor = aPageDic[@"bgcolor"];
        apageItem.bgImgUrl = aPageDic[@"bgpic"];
        apageItem.bgpicwidth = [aPageDic[@"bgpicwidth"] integerValue];
        apageItem.bgpicheight = [aPageDic[@"bgpicheight"] integerValue];
        NSMutableArray *imgArr = [NSMutableArray array];
        NSMutableArray *textArr = [NSMutableArray array];
        for (NSDictionary *pDic in aPageArr) {
            NSString *type = pDic[@"type"];
            if ([type isEqualToString:@"img"]) {
                APageImgItem *imgItem = [APageImgItem mj_objectWithKeyValues:pDic];
                [imgArr addObject:imgItem];
            }else if ([type isEqualToString:@"text"]){
                APageTextItem *textItem = [APageTextItem mj_objectWithKeyValues:pDic];
                [textArr addObject:textItem];
            }
        }
        apageItem.imgsMArr = imgArr;
        apageItem.textMArr = textArr;
        [pagesArr addObject:apageItem];
    }
    
    DiyAPageItem *apageItem = [[DiyAPageItem alloc] init];
    apageItem.pageType = DIY_PAGETYPE_ADD;
    [pagesArr addObject:apageItem];
    NSLog(@"***pagesArr:%@", pagesArr);
}
#pragma mark - 裁剪图片后的通知回调
- (void)notificationHandler: (NSNotification *)notification {
    
    NSDictionary *info = notification.object;
    UIImage *image = info[@"image"];
    NSString *destImgPath = info[@"imgPath"];
    NSLog(@"&&&%@, destImgPath:%@", notification.object, destImgPath);
    if ([_selectedElement isKindOfClass:[APageImgView class]]) {
        APageImgView *imgView = (APageImgView *)_selectedElement;
        [imgView updateImage:image withSize:image.size];
    }
}
#pragma mark - 视图回归原位
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"nihao");
    tapView.hidden = YES;
    switch (tapViewStyle) {
        case DIY_SEL_PAGE:
        {
            [UIView animateWithDuration:0.5 animations:^{
                diyPageSortBottomBar.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_BHeight);
                _myCollectionView.frame = CGRectMake(0, GLOBAL_NAVTOP_HEIGHT, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
            }];
        }
            break;
        case DIY_SEL_BACKGROUND:
        {
            
        }
            break;
        case DIY_SEL_ADDITEM:
        {
            
        }
            break;
        case DIY_SEL_TEXTSTYLE:
        {
            [UIView animateWithDuration:0.5 animations:^{
                txtStyleV.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kTextStyleViewH);
                _myCollectionView.frame = CGRectMake(0, GLOBAL_NAVTOP_HEIGHT, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
            }];
        }
            break;
        default:
            break;
    }
}
#pragma mark - DiyMainBottomAction
- (void)diySelectDiyMainBarBtn:(UIButton *)btn {
    NSLog(@"***DiyMainBottomAction:%@", @(btn.tag));
    switch (btn.tag) {
        case 30://页面
        {
            tapView.hidden = NO;
            tapViewStyle = DIY_SEL_PAGE;
            [UIView animateWithDuration:0.5 animations:^{
                diyPageSortBottomBar.frame = CGRectMake(0, kScreenHeight-kBottomBar_BHeight, kScreenWidth, kBottomBar_BHeight);
                _myCollectionView.frame = CGRectMake(0, kCollectionView_Top, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
            }];
        }
            break;
        case 31://背景
        {
            tapView.hidden = NO;
            tapViewStyle = DIY_SEL_BACKGROUND;
        }
            break;
        case 32://添加
        {
            tapView.hidden = NO;
            tapViewStyle = DIY_SEL_ADDITEM;
        }
            break;
        case 33://音乐
        {
            
        }
            break;

        default:
            break;
    }
}
#pragma mark - DiyBottomBarDelegate
- (void)didSelectDiyBottomBtn:(UIButton *)btn {
    switch (btn.tag) {
        case 40:
        {
            if (bottomStyle == ENUM_DIYIMAGE) {
                //删除
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定删除图片？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                [actionSheet showInView:self.view];
                
            }else if (bottomStyle == ENUM_DIYTEXT) {
                //删除
            }
        }
            break;
        case 41:
        {
            if (bottomStyle == ENUM_DIYIMAGE) {
                //更换图片
                SelectImageVC *nextView = [[SelectImageVC alloc] init];
                nextView.imgSize = _selectedElement.frame.size;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:nextView];
                [self presentViewController:nav animated:YES completion:nil];
                
            }else if (bottomStyle == ENUM_DIYTEXT) {
                //文字内容
                [txtContentV.textTV becomeFirstResponder];
            }

        }
            break;
        case 42:
        {
            if (bottomStyle == ENUM_DIYIMAGE) {
                //裁剪图片
                
            }else if (bottomStyle == ENUM_DIYTEXT) {
                //文字样式
                tapView.hidden = NO;
                tapViewStyle = DIY_SEL_TEXTSTYLE;
                [UIView animateWithDuration:0.5 animations:^{
                    txtStyleV.frame = CGRectMake(0, kScreenHeight-kTextStyleViewH, kScreenWidth, kTextStyleViewH);
                    _myCollectionView.frame = CGRectMake(0, kCollectionView_Top, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
                }];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - DiyTextStyleViewDelegate
- (void)didSelectBgColor:(NSInteger)colorIdx {
    NSString *colorHexStr = selColors[colorIdx];
    if (_selectedElement != nil && [_selectedElement isKindOfClass:[APageTextLabel class]]) {
        APageTextLabel *textLbl = (APageTextLabel *)_selectedElement;
        textLbl.textColor = [UIColor colorWithHexString:colorHexStr];
    }
}
- (void)didSelectTextAlign:(ENUM_DIY_TEXTALIGN)textAlign {
    APageTextLabel *textLbl = nil;
    if (_selectedElement != nil && [_selectedElement isKindOfClass:[APageTextLabel class]]) {
        textLbl = (APageTextLabel *)_selectedElement;
    }
    
    switch (textAlign) {
        case ENUM_DIY_TEXTLEFT:
        {
            textLbl.textAlignment = NSTextAlignmentLeft;
        }
            break;
        case ENUM_DIY_TEXTMIDDLE:
        {
            textLbl.textAlignment = NSTextAlignmentCenter;
        }
            break;
        case ENUM_DIY_TEXTRIGHT:
        {
            textLbl.textAlignment = NSTextAlignmentRight;
        }
            break;
        default:
            break;
    }
}
- (void)sliderFontSizeChange:(UISlider *)slider {
    UIFont *txtFont = [UIFont systemFontOfSize:slider.value];
    if (_selectedElement != nil && [_selectedElement isKindOfClass:[APageTextLabel class]]) {
        APageTextLabel *textLbl = (APageTextLabel *)_selectedElement;
        textLbl.font = txtFont;
    }
}
#pragma mark - DiyShowDelgate
- (void)showImgBottomView:(UIView *)element {
    NSLog(@"showImgBottom View");
    
    if (_selectedElement != nil) {
        _preSelectedElement = _selectedElement;
        _selectedElement = nil;
    }
    
    _selectedElement = element;
    
    if (_preSelectedElement && _preSelectedElement == _selectedElement) {
        return;
    }
    
    [self clearOverBorders];
    
    bottomStyle = ENUM_DIYIMAGE;
    [diyBottomBar reloadDiyBottom:bottomStyle];
    [UIView animateWithDuration:0.5 animations:^{
        diyMainBottomBar.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_MHeight);
        diyBottomBar.frame = CGRectMake(0, kScreenHeight-kBottomBar_MHeight, kScreenWidth, kBottomBar_MHeight);
    }];
}
- (void)showTextBottomView:(UIView *)element {
    if (_selectedElement != nil) {
        _preSelectedElement = _selectedElement;
        _selectedElement = nil;
    }
    
    _selectedElement = element;
    
    if (_preSelectedElement && _preSelectedElement == _selectedElement) {
        return;
    }
    
    [self clearOverBorders];
    
    bottomStyle = ENUM_DIYTEXT;
    [diyBottomBar reloadDiyBottom:bottomStyle];
    [UIView animateWithDuration:0.5 animations:^{
        diyMainBottomBar.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_MHeight);
        diyBottomBar.frame = CGRectMake(0, kScreenHeight-kBottomBar_MHeight, kScreenWidth, kBottomBar_MHeight);
    }];
}
- (void)showMainBottomView:(UIView *)element {
    if (_selectedElement != nil) {
        _preSelectedElement = _selectedElement;
        _selectedElement = nil;
    }
    
    _selectedElement = element;
    
    if (_preSelectedElement && _preSelectedElement == _selectedElement) {
        return;
    }
    
    [self clearOverBorders];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        diyMainBottomBar.frame = CGRectMake(0, kScreenHeight-kBottomBar_MHeight, kScreenWidth, kBottomBar_MHeight);
        diyBottomBar.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_MHeight);
    }];
}
- (void)clearOverBorders {
    if (_preSelectedElement != nil) {
        
        if ([_preSelectedElement isKindOfClass:[APageImgView class]]) {
            APageImgView *imgView = (APageImgView *)_preSelectedElement;
            imgView.hasBorder = NO;
            /*
            DiyAPageItem *pageItem = imgView.pageItem;
            NSLog(@"diyAPageItem:%@", pageItem.imgsMArr);
            APageImgItem *imgItem = pageItem.imgsMArr[0];
            NSLog(@"imgItemw:%@, h:%@, x:%@, y:%@", @(imgItem.imgWidth), @(imgItem.imgHeight), @(imgItem.img_x), @(imgItem.img_y));*/
        }else if ([_preSelectedElement isKindOfClass:[APageTextLabel class]]) {
            APageTextLabel *textLbl = (APageTextLabel *)_preSelectedElement;
            textLbl.hasBorder = NO;
        }
        else {
           
        }
    }else {
       
    }
}
#pragma mark - DiyPageSortDelegate
- (void)pickImage {
    NSLog(@"pickImage");
    tapView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        diyPageSortBottomBar.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kBottomBar_BHeight);
        _myCollectionView.frame = CGRectMake(0, GLOBAL_NAVTOP_HEIGHT, kScreenWidth, kScreenHeight-GLOBAL_NAVTOP_HEIGHT-kBottomBar_MHeight);
    }];
}
- (void)tapImageAction:(NSInteger)index {
    CGFloat pageSize = cellW+12;
    CGFloat scOffsetX = index*pageSize;
    CGPoint scOffsetPoint = _myCollectionView.contentOffset;
    scOffsetPoint.x = scOffsetX;
    [_myCollectionView setContentOffset:scOffsetPoint animated:YES];
}
#pragma mark -add Page, add Form Action
- (void)addPageAndFormAction:(UIButton *)sender {
    if (sender.tag == 80) {
        //add page
        NSLog(@"add page");
    }else {
        //add form
        NSLog(@"add form");
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [pagesArr count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    static NSString *identify = @"DiyOnePageCell";
    DiyOnePageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    DiyAPageItem *OnePageItem = pagesArr[row];
    if (OnePageItem.pageType == DIY_PAGETYPE_SHOW) {
        cell.myDelegate = self;
        cell.tag = DIY_CELL_TAG+row;
        cell.aPageItem = OnePageItem;
    }else {
        cell.aPageItem = OnePageItem;
        [cell.addView setaddBtnHandler:self withSelector:@selector(addPageAndFormAction:)];
    }

    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(-50, 12, 50, 12);
}

#pragma mark - UIScrollViewDelegate

- (CGPoint)nearestTargetOffsetForOffset:(CGPoint)offset
{
    CGFloat pageSize = cellW+12;
    _curPageIndex = round(offset.x/pageSize);
    CGFloat targetX = offset.x;
    if (targetX > _curPageIndex*pageSize+20) {
        if (_curPageIndex<[pagesArr count]) {
            _curPageIndex++;
        }
        targetX = _curPageIndex*pageSize;
       
    }else if (targetX < _curPageIndex*pageSize-20){
        if (_curPageIndex > 0) {
            _curPageIndex--;
        }
        targetX = _curPageIndex*pageSize;
    }
    return CGPointMake(targetX, offset.y);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint targetOffset = [self nearestTargetOffsetForOffset:*targetContentOffset];
    NSLog(@"targetOffset:%@", NSStringFromCGPoint(targetOffset));
    targetContentOffset->x = targetOffset.x;
    targetContentOffset->y = targetOffset.y;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"**%@", @(buttonIndex));
    if (buttonIndex == 0) {
       //执行删除操作
    }
}
@end
