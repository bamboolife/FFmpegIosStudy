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
#import <libavfilter/avfilter.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    char info[1000]={0};
    sprintf(info, "%s\n", avcodec_configuration());
    printf("%s\n", avcodec_configuration());
    //av_version_info();
    NSString * info_ns=[NSString stringWithFormat:@"%s",info];
    self.content.text=info_ns;
    
//    NSString *fromFile=[[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
//    NSString *toFile=@"/Users/sundy/Desktop/Output/video.gif";
//    int argc=4;
//    char **arguments=calloc(argc, sizeof(char*));
//    if (arguments!=NULL) {
//        arguments[0]="ffmpeg";
//        arguments[1]="-i";
//        arguments[2]=(char *)[fromFile UTF8String];
//        arguments[3]=(char *)[toFile UTF8String];
//        if (!ffmpeg_main(argc, arguments)) {
//            NSLog(@"生成s成功");
//        }
//    }
}


- (IBAction)protocolButton:(id)sender {
    //获取所有协议
    char info[40000]={0};
    struct URLProtocal *pup=NULL;
    //input
    struct URLProtocal**p_temp=&pup;
    avio_enum_protocols((void **)p_temp, 0);
    while ((*p_temp)!=NULL) {
         sprintf(info, "%s[In ][%10s]\n", info, avio_enum_protocols((void **)p_temp, 0));
    }
    pup=NULL;
    //output
    avio_enum_protocols((void **)p_temp, 1);
    while ((*p_temp)!=NULL) {
         sprintf(info, "%s[Out][%10s]\n", info, avio_enum_protocols((void **)p_temp, 1));
    }
    NSString *info_ns=[NSString stringWithFormat:@"%s",info];
    self.content.text=info_ns;
}

- (IBAction)avformatButton:(id)sender {
    void *opaque = NULL;
    char info[40000]={0};
    //解封装器 demuxer
   const AVInputFormat *if_temp=av_demuxer_iterate(&opaque);
   
    //AVInputFormat *if_temp=av_iformat_next(NULL);
   // AVOutputFormat *of_temp=av_oformat_next(NULL);
    //input  获取所有的解封装器
    while (if_temp!=NULL) {
        sprintf(info, "%s[In ]%10s\n", info, if_temp->name);
       // if_temp=if_temp->next;
        if_temp=av_demuxer_iterate(&opaque);
    }
    //Output  获取所有封装器
    opaque=NULL;
    //封装器 muxer
    const AVOutputFormat *of_temp=av_muxer_iterate(&opaque);
    while (of_temp != NULL){
        sprintf(info, "%s[Out]%10s\n", info, of_temp->name);
       // of_temp = of_temp->next;
        of_temp=av_muxer_iterate(&opaque);
    }
    //printf("%s", info);
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    self.content.text=info_ns;
}

- (IBAction)avcodecButton:(id)sender {
    char info[40000]={0};
    
    //AVCodec *c_temp=av_codec_next(NULL);
   void  *opaque=NULL;
   const AVCodec *c_temp=av_codec_iterate(&opaque);
    while (c_temp!=NULL) {
        if(c_temp->decode){
            // 获取所有解码器
         sprintf(info, "%s[Dec]", info);
        }
        else{
            // 获取所有编码器
         sprintf(info, "%s[Enc]", info);
        }
        //获取编解码器类型
        switch (c_temp->type) {
            case AVMEDIA_TYPE_VIDEO:
             sprintf(info, "%s[Video]", info);
             break;
            case AVMEDIA_TYPE_AUDIO:
              sprintf(info, "%s[Audio]", info);
              break;
            default:
              sprintf(info, "%s[Other]", info);
              break;
            }
        sprintf(info, "%s%10s\n", info, c_temp->name);
       // c_temp=c_temp->next;
        c_temp=av_codec_iterate(&opaque);
    }
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    self.content.text=info_ns;
}

- (IBAction)avfilterButton:(id)sender {
    char info[40000]={0};
    void  *opaque=NULL;
   // AVFilter *f_temp=(AVFilter *)avfilter_next(NULL);
    const  AVFilter *f_temp=av_filter_iterate(&opaque);
    while (f_temp!=NULL) {
        sprintf(info, "%s[%10s]\n", info, f_temp->name);
       // f_temp=f_temp->next;
        f_temp=av_filter_iterate(&opaque);
    }
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    self.content.text=info_ns;
}

- (IBAction)configureButton:(id)sender {
    char info[10000] = { 0 };
    sprintf(info, "%s\n", avcodec_configuration());
    //printf("%s", info);
    //self.content.text=@"Lei Xiaohua";
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    self.content.text=info_ns;
}

- (IBAction)bitStreamFilterButton:(id)sender {
    char info[10000] = { 0 };
    void  *opaque=NULL;
    const AVBitStreamFilter *bsf=av_bsf_iterate(&opaque);
    while (bsf!=NULL) {
        sprintf(info, "%s[%10s]\n", info, bsf->name);
        bsf=av_bsf_iterate(&opaque);
    }
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    self.content.text=info_ns;
}
@end
