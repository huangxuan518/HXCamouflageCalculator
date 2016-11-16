//
//  HXAddAlbumCategoryViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXAddAlbumCategoryViewController.h"
#import "HXPhotoAlbumListViewController.h"

#import "HXAlbumNameCell.h"
#import "HXAlbumCoverImageCell.h"
#import "HXAlbumOtherCell.h"

#import "BaseNavigationController.h"

//coreData
#import "CoreDataManager.h"

@interface HXAddAlbumCategoryViewController () <UIAlertViewDelegate>

@property (nonatomic,strong) NSArray *cellDataSource;//cell相关data

@property (nonatomic,copy) NSString *albumName;//图片分类名
@property (nonatomic,strong) NSData *coverImageData;//封面图

@end

@implementation HXAddAlbumCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_pictureGroupEntity) {
        self.title = @"Edit Album";
        
        _albumName = _pictureGroupEntity.name;
        _coverImageData = _pictureGroupEntity.logoData;
        
    } else {
        self.title = @"New Album";
    }
    
    [self setLeftItemWithIcon:[UIImage imageNamed:@"close"] title:nil selector:@selector(closeButtonAction:)];
    [self setRightItemWithIcon:[UIImage imageNamed:@"complet"] selector:@selector(coppletionButtonAction:)];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"HXAlbumNameCell" bundle:nil] forCellReuseIdentifier:@"HXAlbumNameCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"HXAlbumCoverImageCell" bundle:nil] forCellReuseIdentifier:@"HXAlbumCoverImageCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"HXAlbumOtherCell" bundle:nil] forCellReuseIdentifier:@"HXAlbumOtherCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCoverImageCompletNotificationCenter:) name:@"selectCoverImageCompletNotificationCenter" object:nil];
}

- (void)selectCoverImageCompletNotificationCenter:(NSNotification *)noti {
    _coverImageData = noti.object;
    [self refreshData];
}

#pragma mark - cellDataSource

- (NSArray *)cellDataSource {
    
    if (!_cellDataSource) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
        
        NSMutableArray *subarr = nil;
        NSDictionary *dict = nil;
        
        //section 1
        subarr = [NSMutableArray arrayWithCapacity:1];
        dict =  @{@"class":HXAlbumNameCell.class,
                  @"height":@([HXAlbumNameCell getCellFrame:nil]),
                  @"albumName":kSafeString(_albumName),
                  @"delegate":@YES};
        [subarr addObject:dict];
        [arr addObject:subarr];
        
        //section 2
        subarr = [NSMutableArray arrayWithCapacity:1];
        dict =  @{@"class":HXAlbumCoverImageCell.class,
                  @"height":@([HXAlbumCoverImageCell getCellFrame:nil]),
                  @"coverImageData":_coverImageData ? _coverImageData : UIImagePNGRepresentation([UIImage imageNamed:@"defaule"])};
        [subarr addObject:dict];

        dict =  @{@"class":HXAlbumOtherCell.class,
                  @"height":@([HXAlbumOtherCell getCellFrame:nil]),
                  @"title":@"Security"};
        [subarr addObject:dict];
        
        dict =  @{@"class":HXAlbumOtherCell.class,
                  @"height":@([HXAlbumOtherCell getCellFrame:nil]),
                  @"title":@"Sorting"};
        [subarr addObject:dict];
        
        [arr addObject:subarr];
        
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

    [cell setSeperatorLineForIOS7:indexPath numberOfRowsInSection:section.count];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *section = self.cellDataSource[indexPath.section];
    NSDictionary *cellDict = section[indexPath.row];
    
    if (cellDict[@"coverImageData"]) {
        [self gotoPhotoAlbumListViewController];
    }
}

#pragma mark - 增 改 查 删 操作
#pragma mark -

//添加图片分类
- (void)addPictureGroup {
    if (_pictureGroupEntity) {
        [kCoreDataManager updateAlbumCategoryWithGroupId:_pictureGroupEntity.groupId name:_albumName coverImageData:_coverImageData count:nil];
    } else {
        [kCoreDataManager insertAlbumCategoryWithName:_albumName coverImageData:_coverImageData];
    }
    
    if (_completion) {
        _completion(self,YES);
    }
    
    [self closeButtonAction:nil];
}

#pragma mark - Action

//关闭按钮
- (void)closeButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//完成按钮
- (void)coppletionButtonAction:(UIButton *)sender {
    [self addPictureGroup];
}

#pragma mark HXAlbumNameCellDelegate 输入框事件

- (void)currencyFirstCell:(HXAlbumNameCell *)cell textField:(UITextField *)textField {
    NSLog(@"%@",textField.text);
    _albumName = textField.text;
}

#pragma mark - goto

//去相册列表
- (void)gotoPhotoAlbumListViewController {
    HXPhotoAlbumListViewController *vc = [HXPhotoAlbumListViewController new];
    vc.groupId = _pictureGroupEntity.groupId;
    vc.type = 1;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - refreshData

/**
 *  刷新tableView
 */
- (void)refreshData {
    _cellDataSource = nil;
    [self.tableview reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectCoverImageCompletNotificationCenter" object:nil];
}

@end
