//
//  ViewController.m
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/5.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import "ViewController.h"
#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    char info[1000]={0};
  sprintf(info, "%s\n", avcodec_configuration());
     printf("%s\n", avcodec_configuration());
}


@end
