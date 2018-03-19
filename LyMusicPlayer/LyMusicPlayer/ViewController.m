//
//  ViewController.m
//  LyMusicPlayer
//
//  Created by Lying on 2018/2/3.
//  Copyright © 2018年 Ly. All rights reserved.
//

#import "ViewController.h"
#import "LyMusicManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBtn:(id)sender {
    [self presentViewController:[LyMusicManager sharedManager].musicPlayerContrller animated:YES completion:nil];
}

@end
