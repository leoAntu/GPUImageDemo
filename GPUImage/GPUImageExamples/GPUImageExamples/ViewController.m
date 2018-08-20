//
//  ViewController.m
//  GPUImageExamples
//
//  Created by 叮咚钱包富银 on 2018/7/31.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerPart1.h"
#import "ViewControllerP2.h"
#import "ViewControllerP3.h"
#import "ViewControllerP4.h"
#import "ViewControllerP5.h"
#import "ViewControllerP6.h"
#import "ViewControllerP7.h"
#import "ViewControllerP8.h"
#import "ViewControllerP9.h"
#import "ViewControllerP10.h"
#import "ViewControllerP11.h"
#import "ViewControllerP12.h"
#import "ViewControllerP13.h"
#import "ViewControllerP14.h"
#import "ViewControllerP15.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        ViewControllerPart1 *vc = [[ViewControllerPart1 alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.row == 1) {
        ViewControllerP2 *vc = [[ViewControllerP2 alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.row == 2) {
        ViewControllerP3 *vc = [[ViewControllerP3 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 3) {
        ViewControllerP4 *vc = [[ViewControllerP4 alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.row == 4) {
        ViewControllerP5 *vc = [[ViewControllerP5 alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.row == 5) {
        ViewControllerP6 *vc = [[ViewControllerP6 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 6) {
        ViewControllerP7 *vc = [[ViewControllerP7 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 7) {
        ViewControllerP8 *vc = [[ViewControllerP8 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 8) {
        ViewControllerP9 *vc = [[ViewControllerP9 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 9) {
        ViewControllerP10 *vc = [[ViewControllerP10 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 10) {
        ViewControllerP11 *vc = [[ViewControllerP11 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 11) {
        ViewControllerP12 *vc = [[ViewControllerP12 alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }

    if (indexPath.row == 12) {
        ViewControllerP13 *vc = [[ViewControllerP13 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 13) {
        ViewControllerP14 *vc = [[ViewControllerP14 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row == 14) {
        ViewControllerP15 *vc = [[ViewControllerP15 alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
}

@end
