//
//  AppDelegate.m
//  HXCamouflageCalculator
//
//  Created by 黄轩 on 16/10/9.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarController.h"
#import "HXCalculatorViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) BaseTabBarController *baseTabBar;
@property (strong, nonatomic) HXCalculatorViewController *calculatorVc;

@end

@implementation AppDelegate

//界面切换
- (void)cutViewController:(BOOL)show {
    if (show) {
        if (!_baseTabBar) {
            _baseTabBar = [BaseTabBarController new];
        }
        _baseTabBar.selectedIndex = 0;
        self.window.rootViewController = _baseTabBar;
    } else {
        if (!_calculatorVc) {
            _calculatorVc = [HXCalculatorViewController new];
        }
        self.window.rootViewController = _calculatorVc;
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self cutViewController:YES];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //APP进入后台
    [self cutViewController:NO];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
