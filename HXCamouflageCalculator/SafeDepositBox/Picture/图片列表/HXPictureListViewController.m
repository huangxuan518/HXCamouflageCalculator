//
//  HXPictureListViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXPictureListViewController.h"

#import "HXPhotoAlbumListViewController.h"

#import "HXPhotoCollectionViewCell.h"
#import "HXNoAlbumsPointsCell.h"

#import "BaseNavigationController.h"

//coreData
#import "CoreDataManager.h"
#import "PictureEntity.h"

@interface HXPictureListViewController () <UIActionSheetDelegate>

@property (nonatomic,strong) NSArray *cellDataSource;//cell相关data

@end

@implementation HXPictureListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _pictureGroupEntity.name;
    
    [self setRightItemWithIcon:[UIImage imageNamed:@"add_photo"] selector:@selector(showAddPhotosActionSheet)];
    
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
}

//显示添加照片弹层
- (void)showAddPhotosActionSheet {
    UIActionSheet *a = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library",@"Camera", nil];
    [a showInView:self.navigationController.view];
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

#pragma mark - Go to
#pragma mark -

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
}

- (void)backAction:(UIButton *)sender {
    if (_completion) {
        _completion(self,YES);
    }
    [super backAction:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addPhotoRresh" object:nil];
}

@end
