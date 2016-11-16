//
//  HXPictureGroupListViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXPictureGroupListViewController.h"

#import "HXPictureListViewController.h"
#import "HXAddAlbumCategoryViewController.h"

#import "BaseNavigationController.h"

//view
#import "HXNoAlbumsPointsView.h"
#import "HXNoAlbumsPointsCell.h"
#import "HXPictureGroupCell.h"

//coreData
#import "CoreDataManager.h"
#import "PictureGroupEntity.h"

@interface HXPictureGroupListViewController ()

@property (nonatomic,strong) NSArray *cellDataSource;//cell相关data

@property (nonatomic,strong) HXNoAlbumsPointsView *noAlbumsPointsView; //无相册提示View

@end

@implementation HXPictureGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Albums";

    [self setRightItemWithIcon:[UIImage imageNamed:@"add_photo"] selector:@selector(addPictureGroup)];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"HXPictureGroupCell" bundle:nil] forCellReuseIdentifier:@"HXPictureGroupCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"HXNoAlbumsPointsCell" bundle:nil] forCellReuseIdentifier:@"HXNoAlbumsPointsCell"];

    [self queryAllPictureGroupList];
    
    self.noAlbumsPointsView.pointsLabel.text = @"CREATE YOUR FIRST ALBUM";
    [self.view addSubview:self.noAlbumsPointsView];
}

#pragma mark - cellDataSource

- (NSArray *)cellDataSource {
    
    if (!_cellDataSource) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
        
        NSMutableArray *subarr = nil;
        NSDictionary *dict = nil;
        
        if (self.dataAry.count > 0) {
            self.noAlbumsPointsView.hidden = YES;
            
            //相册分类存在
            subarr = [NSMutableArray arrayWithCapacity:1];
            for (PictureGroupEntity *pictureGroupEntity in self.dataAry) {
                dict =  @{@"class":HXPictureGroupCell.class,
                          @"height":@([HXPictureGroupCell getCellFrame:[NSNumber numberWithInt:90]]),
                          @"data":pictureGroupEntity};
                [subarr addObject:dict];
            }
            [arr addObject:subarr];
        } else {
            self.noAlbumsPointsView.hidden = NO;
            
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

#pragma mark UITableViewDataSource/UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.cellDataSource[section];
    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *section = self.cellDataSource[indexPath.section];
    NSDictionary *cellDict = section[indexPath.row];
    
    Class classs = cellDict[@"class"];
    
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(classs)];
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(classs)];
    }
    
    if (self.dataAry.count > 0) {
        [cell setSeperatorLineForIOS7:indexPath numberOfRowsInSection:section.count];
    }
    
    NSNumber *delFlag = cellDict[@"delegate"];
    
    id delegate = nil;
    
    if (delFlag && delFlag.boolValue) {
        delegate = self;
    }
    
    [cell setData:cellDict delegate:delegate];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = self.cellDataSource[indexPath.section];
    NSDictionary *cellDict = section[indexPath.row];
    float height = [cellDict[@"height"] floatValue];
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frameSizeWidth, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

//滑动删除 cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = self.cellDataSource[indexPath.section];
    NSDictionary *cellDict = section[indexPath.row];
    
    PictureGroupEntity *pictureGroupEntity = (PictureGroupEntity *)cellDict[@"data"];
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [self.dataAry removeObjectAtIndex:indexPath.row];
        [self deletePictureGroupWithId:pictureGroupEntity.groupId];
        
        [self refreshData];

    }];
    deleteRowAction.backgroundColor = UIColorFromHex(0xff3b30);
    
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        [self gotoAddAlbumCategoryViewController:pictureGroupEntity];

        [self refreshData];
    }];
    editRowAction.backgroundColor = UIColorFromHex(0xc7c7cc);
    
    return @[editRowAction,deleteRowAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *section = self.cellDataSource[indexPath.section];
    NSDictionary *cellDict = section[indexPath.item];
    
    PictureGroupEntity *pictureGroupEntity = (PictureGroupEntity *)cellDict[@"data"];
    NSLog(@"相册名:%@ 相册ID:%lld",pictureGroupEntity.name,pictureGroupEntity.groupId);
    [self gotoPictureListViewController:pictureGroupEntity];
}

#pragma mark - refreshData

/**
 *  刷新tableView
 */
- (void)refreshData {
    _cellDataSource = nil;
    [self.tableview reloadData];
}

#pragma mark - Action
#pragma mark -

//新建图片分组
- (void)addPictureGroup {
    [self gotoAddAlbumCategoryViewController:nil];
}

#pragma mark - goto
#pragma mark -

//去添加分类界面
- (void)gotoAddAlbumCategoryViewController:(PictureGroupEntity *)pictureGroupEntity {
    HXAddAlbumCategoryViewController *vc = [HXAddAlbumCategoryViewController new];
    vc.pictureGroupEntity = pictureGroupEntity;
    vc.completion = ^(HXAddAlbumCategoryViewController *vc,BOOL isRefresh) {
        if (isRefresh) {
            [self queryAllPictureGroupList];
        }
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

//去分类图片列表
- (void)gotoPictureListViewController:(PictureGroupEntity *)pictureGroupEntity {
    HXPictureListViewController *vc = [HXPictureListViewController new];
    vc.pictureGroupEntity = pictureGroupEntity;
    vc.completion = ^(HXPictureListViewController *vc,BOOL isRefresh) {
        if (isRefresh) {
            [self queryAllPictureGroupList];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 增 改 查 删 操作
#pragma mark -

//查询所有图片分类列表
- (void)queryAllPictureGroupList {

    self.dataAry = [NSMutableArray arrayWithArray:[kCoreDataManager selectAllAlbumCategory]];
    
    [self refreshData];
}

//编辑某个图片分类名
- (void)editPictureGroupName:(NSString *)groupName groupId:(NSInteger)groupId {
    
}

//删除某个图片分类
- (void)deletePictureGroupWithId:(NSInteger)groupId {
    [kCoreDataManager deleteAlbumCategoryWithGroupId:groupId];
}

#pragma mark - 懒加载
#pragma mark -

//无相册目录提示
- (HXNoAlbumsPointsView *)noAlbumsPointsView {
    if (!_noAlbumsPointsView) {
        _noAlbumsPointsView  = [[HXNoAlbumsPointsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _noAlbumsPointsView.backgroundColor = UIColorFromHex(0x549ef5);
        _noAlbumsPointsView.pointsLabel.textColor = [UIColor whiteColor];
    }
    return _noAlbumsPointsView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
