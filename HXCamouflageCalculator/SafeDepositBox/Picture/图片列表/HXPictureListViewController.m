//
//  HXPictureListViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXPictureListViewController.h"

#import "HXPhotoAlbumListViewController.h"
#import "SHPhotoPreviewViewController.h"

#import "HXPhotoCollectionViewCell.h"
#import "HXNoAlbumsPointsCell.h"

#import "HXEditPhotoToolBar.h"

#import "BaseNavigationController.h"

//coreData
#import "CoreDataManager.h"
#import "PictureEntity.h"

@interface HXPictureListViewController () <UIActionSheetDelegate>

@property (nonatomic,strong) NSArray *cellDataSource;//cell相关data
@property (nonatomic,strong) UIButton *rightBarButton;
@property (nonatomic,strong) HXEditPhotoToolBar *toolBar; //底部bar

@end

@implementation HXPictureListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _pictureGroupEntity.name;
    
    UIBarButtonItem *item = [self ittemRightItemWithIcon:[UIImage imageNamed:@"add_photo"] title:nil selector:@selector(showAddPhotosActionSheet)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HXPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HXPhotoCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HXPictureGroupCell" bundle:nil] forCellWithReuseIdentifier:@"HXPictureGroupCell"];
    
    [self search];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(search) name:@"addPhotoRresh" object:nil];
}

#pragma mark - cellDataSource

- (NSArray *)cellDataSource {
    
    if (!_cellDataSource) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
        
        NSMutableArray *subarr = nil;
        NSDictionary *dict = nil;
        
        if (self.dataAry.count > 0) {
            //相册分类存在
            subarr = [NSMutableArray arrayWithCapacity:1];
            for (PictureEntity *picture in self.dataAry) {
                dict =  @{@"class":HXPhotoCollectionViewCell.class,
                          @"height":@([HXPhotoCollectionViewCell getCellFrame:[NSNumber numberWithInt:56]]),
                          @"data":picture};
                [subarr addObject:dict];
            }
            [arr addObject:subarr];
        } else {
            //提示Cell
            subarr = [NSMutableArray arrayWithCapacity:1];
            dict =  @{@"class":HXNoAlbumsPointsCell.class,
                      @"height":@([HXNoAlbumsPointsCell getCellFrame:[NSNumber numberWithInt:310]])};
            [subarr addObject:dict];
            [arr addObject:subarr];
            
        }
        
        _cellDataSource = arr;
    }
    return _cellDataSource;
}

#pragma mark UICollectionView

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataAry.count;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *section = self.cellDataSource[indexPath.section];
    NSDictionary *cellDict = section[indexPath.row];
    
    Class classs = cellDict[@"class"];

    BaseCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(classs) forIndexPath:indexPath];
    
    [cell setData:cellDict delegate:nil];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.frame.size.width - 5*6) / 5, (self.view.frame.size.width - 5*6) / 5);
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

//UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self gotoPhotoPreviewViewController:indexPath.item];
    
    [_toolBar setSelectPictureCount:1 delegate:self];
}

//显示添加照片弹层
- (void)showAddPhotosActionSheet {
    if (self.dataAry.count > 0) {
        [self.view addSubview:self.toolBar];
    } else {
        UIActionSheet *a = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library",@"Camera", nil];
        [a showInView:self.navigationController.view];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (buttonIndex) {
        case 0: {
            [self gotoPhotoAlbumListViewController];
        }
            break;
            
        case 1: {
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - HXEditPhotoToolBarDelegate 底部工具条代理事件

- (void)editPhotoCountView:(HXEditPhotoToolBar *)editPhotoCountView buttonAction:(UIButton *)sender {
    
}

#pragma mark - Go to
#pragma mark -

//照片预览界面
- (void)gotoPhotoPreviewViewController:(NSInteger)index {
    
    NSMutableArray *photos = [NSMutableArray new];
    
    [self.dataAry enumerateObjectsUsingBlock:^(PictureEntity *picture, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageWithData:picture.data];
        [photos addObject:image];
    }];
    
    SHPhotoPreviewViewController *vc = [[SHPhotoPreviewViewController alloc] initWithPhotos:photos index:index];
    vc.superTitle = self.title;
    __weak __typeof(self)weakSelf = self;
    vc.deleteCompletion = ^(SHPhotoPreviewViewController *vc, NSArray *photos,id currentDeleteImage) {
        __strong __typeof(self)self = weakSelf;
        [self.dataAry enumerateObjectsUsingBlock:^(PictureEntity *picture, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //删除的可能是一个url或者是一个image所以拿它和model里面的url或者image比较即可
            NSData *data = UIImagePNGRepresentation(currentDeleteImage);
            if ([picture.data isEqual:data]) {
                [self.dataAry removeObjectAtIndex:idx];
                [self deletePictureWithPictureId:picture.pictureId];
            }
        }];
        
        [self refreshData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

//去相册列表
- (void)gotoPhotoAlbumListViewController {
    HXPhotoAlbumListViewController *vc = [HXPhotoAlbumListViewController new];
    vc.groupId = _pictureGroupEntity.groupId;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - refreshData

/**
 *  刷新tableView
 */
- (void)refreshData {
    _cellDataSource = nil;
    [self.collectionView reloadData];
}

#pragma mark - 增 改 查 删 操作
#pragma mark -

//使用示例：
- (void)search {
    NSArray *ary = [kCoreDataManager selectAlbumCategoryPictureListWithGroupId:_pictureGroupEntity.groupId];
    self.dataAry = [NSMutableArray arrayWithArray:ary];
    [self refreshData];
    
    UIBarButtonItem *item;
    if (self.dataAry.count > 0) {
        item = [self ittemRightItemWithIcon:nil title:@"Edit" selector:@selector(showAddPhotosActionSheet)];
    } else {
        item = [self ittemRightItemWithIcon:[UIImage imageNamed:@"add_photo"] title:nil selector:@selector(showAddPhotosActionSheet)];
    }
    self.navigationItem.rightBarButtonItem = item;
}

//删除某个图片
- (void)deletePictureWithPictureId:(NSInteger)pictureId {
    [kCoreDataManager deletePictureWithPictureId:pictureId];
}

- (void)backAction:(UIButton *)sender {
    if (_completion) {
        _completion(self,YES);
    }
    [super backAction:sender];
}

- (UIBarButtonItem *)ittemRightItemWithIcon:(UIImage *)icon title:(NSString *)title selector:(SEL)selector {
    UIBarButtonItem *item;
    if (!icon && title.length == 0) {
        item = [[UIBarButtonItem new] initWithCustomView:[UIView new]];
        return item;
    }
    
    if (!_rightBarButton) {
        _rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBarButton.backgroundColor = [UIColor clearColor];
        _rightBarButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        if (selector) {
            [_rightBarButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    float leight = 0;
    
    if (icon) {
        [_rightBarButton setTitle:title forState:UIControlStateNormal];
        [_rightBarButton setTitle:title forState:UIControlStateHighlighted];
        [_rightBarButton setImage:icon forState:UIControlStateNormal];
        [_rightBarButton setImage:icon forState:UIControlStateHighlighted];
        leight = icon.size.width;
    } else if (title.length > 0) {
        [_rightBarButton setImage:nil forState:UIControlStateNormal];
        [_rightBarButton setImage:nil forState:UIControlStateHighlighted];
        [_rightBarButton setTitle:title forState:UIControlStateNormal];
        [_rightBarButton setTitle:title forState:UIControlStateHighlighted];
        CGSize titleSize = [title ex_sizeWithFont:_rightBarButton.titleLabel.font constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT)];
        leight = titleSize.width;
        _rightBarButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    [_rightBarButton setFrame:CGRectMake(0, 0, leight, 30)];
    item = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButton];
    return item;
}

//编辑图片工具条
- (HXEditPhotoToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [HXEditPhotoToolBar instanceView];
        _toolBar.frame = CGRectMake(0, CONTENT_HEIGHT - 45, self.view.frame.size.width, 45);
        [_toolBar setSelectPictureCount:0 delegate:self];
    }
    return _toolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addPhotoRresh" object:nil];
}

@end
