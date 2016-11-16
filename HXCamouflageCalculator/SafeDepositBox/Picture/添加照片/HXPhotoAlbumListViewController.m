//
//  HXPhotoAlbumListViewController.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXPhotoAlbumListViewController.h"

#import "HXPhotoListViewController.h"

//view
#import "HXPictureGroupCell.h"

//coreData
#import "CoreDataManager.h"
#import "PictureGroupEntity.h"

@interface HXPhotoAlbumListViewController ()

@property (nonatomic,strong) NSArray *cellDataSource;//cell相关data

@end

@implementation HXPhotoAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Import photos";

    [self setLeftItemWithIcon:[UIImage imageNamed:@"close"] title:nil selector:@selector(closeButtonAction:)];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"HXPictureGroupCell" bundle:nil] forCellReuseIdentifier:@"HXPictureGroupCell"];
    
    [ASSETHELPER getGroupList:^(NSArray *groupAry) {
        self.dataAry = [NSMutableArray arrayWithArray:groupAry];
        [self refreshData];
    }];
}

#pragma mark - cellDataSource

- (NSArray *)cellDataSource {
    
    if (!_cellDataSource) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
        
        NSMutableArray *subarr = nil;
        __block NSDictionary *dict = nil;
        
        if (self.dataAry.count > 0) {
            //相册分类存在
            subarr = [NSMutableArray arrayWithCapacity:1];
            
            [self.dataAry enumerateObjectsUsingBlock:^(ALAssetsGroup *group, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = [ASSETHELPER getGroupInfo:idx];
                
                PictureGroupEntity *pictureGroupEntity = [PictureGroupEntity new];
                pictureGroupEntity.name = dic[@"name"];
                pictureGroupEntity.count = [dic[@"count"] integerValue];
                pictureGroupEntity.logoData = UIImagePNGRepresentation(dic[@"thumbnail"]);
                
                
                dict =  @{@"class":HXPictureGroupCell.class,
                          @"height":@([HXPictureGroupCell getCellFrame:[NSNumber numberWithInt:90]]),
                          @"data":pictureGroupEntity};

                [subarr addObject:dict];
            }];
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.dataAry.count > 0) {
        //相册分类存在
        NSDictionary *dic = [ASSETHELPER getGroupInfo:indexPath.row];

        NSString *name = dic[@"name"];
        [self gotoPictureListViewController:name index:indexPath.row];
    }
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

//关闭按钮
- (void)closeButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - goto
#pragma mark -

//去分类图片列表
- (void)gotoPictureListViewController:(NSString *)name index:(NSInteger)index {
    HXPhotoListViewController *vc = [HXPhotoListViewController new];
    vc.albumName = name;
    vc.groupId = _groupId;
    vc.photoAlbumIndex = index;
    vc.type = _type;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
