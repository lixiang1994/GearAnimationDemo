//
//  SettingViewController.m
//  Gear
//
//  Created by 李响 on 2017/9/18.
//  Copyright © 2017年 lee. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *animationDuration;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
}

#pragma mark - 确认按钮点击事件

- (IBAction)barButtonAction:(id)sender {
    
    NSDictionary *info = @{@"animationDuration" : self.animationDuration.text.length ? self.animationDuration.text : @"2" ,
                           
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishSet" object:self userInfo:info];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate , UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textcell"];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
