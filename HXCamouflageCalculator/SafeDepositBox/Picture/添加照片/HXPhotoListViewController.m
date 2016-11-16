//
//  HXPhotoListViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXPhotoListViewController.h"

#import "HXPhotoCollectionViewCell.h"
#import "HXSelectPhotoCountView.h"

//coreData
#import "CoreDataManager.h"
#import "PictureEntity.h"

@interface HXPhotoListViewController () <HXSelectPhotoCountViewDelegate>

@property (nonatomic,strong) NSArray *cellDataSource;//cell相关data

@property (nonatomic,strong) HXSelectPhotoCountView *selectPhotoCountView; //数量
@property (nonatomic,strong) NSMutableArray *selectedAssets;
@property (nonatomic,assign) int selectNumbers;
@property (nonatomic,strong) UIButton *rightBarButton;

@end

@implementation HXPhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLeftItemWithIcon:[UIImage imageNamed:@"back_more"] title:@"" selector:@selector(backAction:)];
    self.title = _albumName;
    
    if (_type > 0) {
        //单选
        [self setRightItemWithIcon:[UIImage imageNamed:@"complet"] selector:@selector(updatePictureGroup)];
    } else {
        UIBarButtonItem *item = [self ittemRightItemWithTitle:@"Select all" selector:@selector(selectAllPhotoButtonAction:)];
        self.navigationItem.rightBarButtonItem = item;
        
        [self.view addSubview:self.selectPhotoCountView];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HXPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HXPhotoCollectionViewCell"];
    
    [ASSETHELPER getPhotoListOfGroupByIndex:_photoAlbumIndex result:^(NSArray *photoAry) {
        
        [photoAry enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dict =  @{@"asset":asset,
                                    @"select":@NO};
            [self.dataAry addObject:dict];
        }];
        
        [self.collectionView reloadData];
    }];
}

#pragma mark UICollectionView

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataAry.count;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"HXPhotoCollectionViewCell";

    BaseCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setData:self.dataAry[indexPath.row] delegate:nil];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.frame.size.width - 5*5) / 4, (self.view.frame.size.width - 5*5) / 4);
}

// 设置每个cell上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 0, 5);
}

//// 设置最小行间距，也就是前一行与后一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

// 设置最小列间距，也就是左行与右一行的中间最小间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataAry[indexPath.item];
    ALAsset *asset = dic[@"asset"];
    BOOL select = [dic[@"select"] boolValue];
    
    NSDictionary *dict = nil;
    
    if (select) {
        dict =  @{@"asset":asset,
                  @"select":@NO};
        [self.selectedAssets removeObject:asset];
    } else {
        if (_type > 0) {
            //单选
            [self.selectedAssets removeAllObjects];
            
            NSMutableArray *ary = [NSMutableArray new];
            [self.dataAry enumerateObjectsUsingBlock:^(NSDictionary *someDic, NSUInteger idx, BOOL * _Nonnull stop) {
                ALAsset *asset = someDic[@"asset"];
                NSDictionary *oneDic =  @{@"asset":asset,
                          @"select":@NO};
                [ary addObject:oneDic];
            }];
            self.dataAry = ary;
        }
        
        dict =  @{@"asset":asset,
                  @"select":@YES};
        [self.selectedAssets addObject:asset];
    }
    
    self.dataAry[indexPath.item] = dict;
    
    if (_type > 0) {
        //单选需要刷新所有
        [UIView performWithoutAnimation:^{
            [self.collectionView reloadData];
        }];
    } else {
        [UIView performWithoutAnimation:^{
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }
    
    self.selectNumbers = (int)self.selectedAssets.count;
    
    [self refreshCount];
}

#pragma mark - 确定添加照片代理
#pragma mark -

- (void)selectPhotoCountView:(HXSelectPhotoCountView *)selectPhotoCountView addButtonAction:(UIButton *)sender {
    [self addPicture];
}

#pragma mark - Action
#pragma mark -

//添加图片分类
- (void)updatePictureGroup {
    
    [self.selectedAssets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *image = UIImagePNGRepresentation([ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_FULL_RESOLUTION]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCoverImageCompletNotificationCenter" object:image];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//添加数据
- (void)addPicture
{
    NSMutableArray *ary = [NSMutableArray new];
    
    [self.selectedAssets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PictureEntity *picture = [PictureEntity new];
        
        NSData *image = UIImagePNGRepresentation([ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_SCREEN_SIZE]);
        
        //为了使图片分类ID不重复，我们采取当前时间戳作为ID进行存储
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        
        [picture setName:[NSString stringWithFormat:@"图片%ld",(long)dateString.integerValue]];
        [picture setData:image];
        [picture setTime:[NSDate date]];
        [picture setGroupId:_groupId];
        
        [ary addObject:picture];
    }];
    
    [kCoreDataManager insertPictureAry:ary];
    
    //发通知刷新界面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addPhotoRresh" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//刷新照片选择数量View
- (void)refreshCount {
    
    if (self.selectNumbers > 0) {
        self.selectPhotoCountView.hidden = NO;
       self.selectPhotoCountView.pointsLabel.text = [NSString stringWithFormat:@"Import selected (%d)",self.selectNumbers];
    } else {
        self.selectPhotoCountView.hidden = YES;
    }
    
    if (self.selectNumbers == self.dataAry.count) {
        [_rightBarButton setTitle:@"Deselect all" forState:UIControlStateNormal];
        [_rightBarButton setTitle:@"Deselect all" forState:UIControlStateHighlighted];
    } else {
        [_rightBarButton setTitle:@"Select all" forState:UIControlStateNormal];
        [_rightBarButton setTitle:@"Select all" forState:UIControlStateHighlighted];
    }
}

- (void)selectAllPhotoButtonAction:(UIButton *)sender {
    
    if ([_rightBarButton.titleLabel.text isEqualToString:@"Select all"]) {
        [self selectAllPhoto:YES];
    } else {
        [self selectAllPhoto:NO];
    }
    
    [self refreshCount];
}

- (void)selectAllPhoto:(BOOL)photoSelect {
    if (photoSelect) {
        self.selectNumbers = (int)self.dataAry.count;
    } else {
        self.selectNumbers = 0;
    }
    
    [self.selectedAssets removeAllObjects];
    
    [self.dataAry enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        ALAsset *asset = dic[@"asset"];
        BOOL select = [dic[@"select"] boolValue];
        
        NSDictionary *dict = nil;
        
        if (photoSelect) {
            if (!select) {
                dict =  @{@"asset":asset,
                          @"select":@YES};
                self.dataAry[idx] = dict;
            }
            [self.selectedAssets addObject:asset];
        } else {
            if (select) {
                dict =  @{@"asset":asset,
                          @"select":@NO};
                self.dataAry[idx] = dict;
            }
        }
    }];
    
    [self.collectionView reloadData];
}

- (UIBarButtonItem *)ittemRightItemWithTitle:(NSString *)title selector:(SEL)selector {
    UIBarButtonItem *item;
    if (title.length == 0) {
        item = [[UIBarButtonItem new] initWithCustomView:[UIView new]];
        return item;
    }
    _rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarButton.backgroundColor = [UIColor clearColor];
    _rightBarButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    if (selector) {
        [_rightBarButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    [_rightBarButton setTitle:title forState:UIControlStateNormal];
    [_rightBarButton setTitle:title forState:UIControlStateHighlighted];
    CGSize titleSize = [title ex_sizeWithFont:_rightBarButton.titleLabel.font constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT)];
    float leight = titleSize.width;
    [_rightBarButton setFrame:CGRectMake(0, 0, leight, 30)];
    _rightBarButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    item = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButton];
    return item;
}

#pragma mark - 懒加载
#pragma mark -

- (NSMutableArray *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray new];
    }
    return _selectedAssets;
}

//选择相片数量
- (HXSelectPhotoCountView *)selectPhotoCountView {
    if (!_selectPhotoCountView) {
        _selectPhotoCountView  = [[HXSelectPhotoCountView alloc] initWithFrame:CGRectMake(0, CONTENT_HEIGHT - 40, self.view.frame.size.width, 40)];
        _selectPhotoCountView.backgroundColor = [UIColor whiteColor];
        _selectPhotoCountView.pointsLabel.textColor = UIColorFromHex(0x007aff);
        _selectPhotoCountView.hidden = YES;
        _selectPhotoCountView.delegate = self;
        //创建需要的毛玻璃特效类型
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        //毛玻璃view 视图
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //设置模糊透明度
        effectView.alpha = 0.8f;
        //添加到要有毛玻璃特效的控件中
        effectView.frame = _selectPhotoCountView.bounds;
        [_selectPhotoCountView addSubview:effectView];
        [_selectPhotoCountView sendSubviewToBack:effectView];
    }
    return _selectPhotoCountView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
