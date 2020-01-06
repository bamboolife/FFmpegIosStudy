//
//  DecoderViewController.m
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/6.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import "DecoderViewController.h"
#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
#import <libswscale/swscale.h>
#import <libavutil/imgutils.h>
@interface DecoderViewController ()

@end

@implementation DecoderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickDecodeButton:(id)sender {
    AVCodecParameters *avCodecParameters;
    
    char input_str_full[500]={0};
    char output_str_full[500]={0};
    char info[1000]={0};
    
    clock_t time_start, time_finish;
    double  time_duration = 0.0;
    
    NSString *input_str= [NSString stringWithFormat:@"res.bundle/%@",self.inputPath.text];
    NSString *output_str= [NSString stringWithFormat:@"res.bundle/%@",self.outputPath.text];
    NSString *input_nsstr=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:input_str];
    NSString *output_nsstr=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:output_str];
     //NSString *output_nsstr = @"/Users/sundy/Desktop/Output/test.yuv";
    
//    NSString *myBundlePath=[[NSBundle mainBundle] pathForResource:@"res" ofType:@"bundle"];
//    NSBundle *myBundle=[NSBundle bundleWithPath:myBundlePath];
//    NSString *videoPath=[myBundle pathForResource:@"sintel" ofType:@"mov"];
//    NSLog(@"%@",videoPath);
    
//    NSString *fromFile=[[NSBundle mainBundle] pathForResource:@"res.bundle/sintel.mov" ofType:nil];
//    NSLog(@"视频地址=%@",fromFile);
    
    sprintf(input_str_full,"%s",[input_nsstr UTF8String]);
    sprintf(output_str_full,"%s",[output_nsstr UTF8String]);
    
    printf("Input Path:%s\n",input_str_full);
    printf("Output Path:%s\n",output_str_full);
    
    AVFormatContext *avFormatContext=avformat_alloc_context();
    
    //1打开视频
    if(avformat_open_input(&avFormatContext, input_str_full, NULL, NULL)!=0){
        printf("打开视频失败");
        return;
    }
    /**
    在一些格式当中没有头部信息，如flv格式，h264格式，这个时候调用avformat_open()在打开文件之后就没有参数，也就无法获取到里面的信息。这个时候就可以调用此函数，因为它会试着去探测文件的格式，
       但是如果格式当中没有头部信息，那么它只能获取到编码、宽高这些信息，还是无法获得总时长。如果总时长无法获取到，则仍需要把整个文件读一遍，计算一下它的总帧数。
     */
    //2查找流信息
    if(avformat_find_stream_info(avFormatContext, NULL)<0){
        printf("找不到视频流信息");
        return;
    }
    //查找流索引
    int video_stream_index=-1;
    for (int i=0; i<avFormatContext->nb_streams; i++) {
        avCodecParameters=  avFormatContext->streams[i]->codecpar;
        if(avCodecParameters->codec_type==AVMEDIA_TYPE_VIDEO){
            video_stream_index=i;
            break;
        }
    }
    
    if(video_stream_index==-1){
        printf("未找到视频流索引位置");
        return;
    }
    avCodecParameters=avFormatContext->streams[video_stream_index]->codecpar;
    //查找编码器
    AVCodec *avCodec=avcodec_find_decoder(avCodecParameters->codec_id);
    if(avCodec==NULL){
        printf("为找到视频编码器");
        return;
    }
    
    //获取编码器上下文
    AVCodecContext *aVCodecContext=avcodec_alloc_context3(NULL);
    avcodec_parameters_to_context(aVCodecContext,avCodecParameters);
    //打开解码器
    if(avcodec_open2(aVCodecContext, avCodec, NULL)!=0){
        printf("打开解码器失败");
        return;
    }
    printf("解码器是%s",avCodec->name);
    
    //视频图像的转换
    struct SwsContext *swsContext=sws_getContext(avCodecParameters->width, avCodecParameters->height, aVCodecContext->pix_fmt, avCodecParameters->width, avCodecParameters->height, AV_PIX_FMT_YUV420P,SWS_BITEXACT, NULL, NULL, NULL);
   
    // 用于存放解码之后的像素数据
    AVFrame *avFrame=av_frame_alloc();
    // 创建缓冲区
    //创建一个yuv420视频像素数据格式缓冲区(一帧数据)
    AVFrame* avframe_yuv420p = av_frame_alloc();
    //给缓冲区设置类型->yuv420类型
    //得到YUV420P缓冲区大小
    int buffer_size=av_image_get_buffer_size(AV_PIX_FMT_YUV420P, aVCodecContext->width, aVCodecContext->height, 1);
   
    //  开辟一块内存空间
    uint8_t *out_buffer = (uint8_t *)av_malloc(buffer_size);
    
    //  向avframe_yuv420p->填充数据
    av_image_fill_arrays(avframe_yuv420p->data, avframe_yuv420p->linesize, out_buffer, AV_PIX_FMT_YUV420P, aVCodecContext->width, aVCodecContext->height, 1);
    
       sprintf(info,   "[Input     ]%s\n", [input_str UTF8String]);
       sprintf(info, "%s[Output    ]%s\n",info,[output_str UTF8String]);
       sprintf(info, "%s[Format    ]%s\n",info, avFormatContext->iformat->name);
       sprintf(info, "%s[Codec     ]%s\n",info, aVCodecContext->codec->name);
       sprintf(info, "%s[Resolution]%dx%d\n",info, aVCodecContext->width,aVCodecContext->height);
    
    
    /*
     VPacket是FFmpeg中很重要的一个数据结构，它保存了解复用（demuxer)之后，解码（decode）之前的数据（仍然是压缩后的数据）和关于这些数据的一些附加的信息，如显示时间戳（pts），解码时间戳（dts）,数据时长（duration），所在流媒体的索引（stream_index）等等。对于视频（Video）来说，AVPacket通常包含一个压缩的Frame；而音频（Audio）则有可能包含多个压缩的Frame。并且，一个packet也有可能是空的，不包含任何压缩数据data，只含有边缘数据side data（side data,容器提供的关于packet的一些附加信息，例如，在编码结束的时候更新一些流的参数,在另外一篇av_read_frame会介绍）
     AVPacket的大小是公共的ABI(Public ABI)一部分，这样的结构体在FFmpeg很少，由此也可见AVPacket的重要性，它可以被分配在栈空间上（可以使用语句AVPacket pkt;在栈空间定义一个Packet），并且除非libavcodec 和libavformat有很大的改动，不然不会在AVPacket中添加新的字段。
     */
    AVPacket *pkt=(AVPacket *)alloca(sizeof(AVPacket));
    FILE *file_yuv420p=fopen(output_str_full, "wb+");
    if(file_yuv420p==NULL){
        printf("不能d打开c输出文件");
    }
    int frame_current_index=0;
    int y_size;
    int ret;
    time_start=clock();
    //从流中读取读取数据到Packet中
    while (av_read_frame(avFormatContext, pkt)>=0) {
        //判断是不是视频
        if(pkt->stream_index==video_stream_index){
            // 每读取一帧数据，立马解码一帧数据
            // 解码之后得到视频的像素数据->YUV
            int sf= avcodec_send_packet(aVCodecContext, pkt);
            if (sf!=0) {
                printf("读取帧数据失败");
                return;
            }
            //解码
            ret=avcodec_receive_frame(aVCodecContext, avFrame);
            if(ret==0){
                // 解码成功
                // 此处无法保证视频的像素格式是一定是YUV格式
                // 将解码出来的这一帧数据，统一转类型为YUV
                sws_scale(swsContext, (const uint8_t const *)avFrame->data, avFrame->linesize, 0, aVCodecContext->height, avframe_yuv420p->data, avframe_yuv420p->linesize);
                y_size=aVCodecContext->width*aVCodecContext->height;
                fwrite(avframe_yuv420p->data[0],1,y_size,file_yuv420p);    //Y
                fwrite(avframe_yuv420p->data[1],1,y_size/4,file_yuv420p);  //U
                fwrite(avframe_yuv420p->data[2],1,y_size/4,file_yuv420p);  //V
                //Output info
                char pictype_str[10]={0};
                switch(avFrame->pict_type){
                    case AV_PICTURE_TYPE_I:sprintf(pictype_str,"I");break;
                    case AV_PICTURE_TYPE_P:sprintf(pictype_str,"P");break;
                    case AV_PICTURE_TYPE_B:sprintf(pictype_str,"B");break;
                    default:sprintf(pictype_str,"Other");break;
                }
                printf("Frame Index: %5d. Type:%s\n",frame_current_index,pictype_str);
                frame_current_index++;
            }
        }
       av_packet_unref(pkt);
    }
    
    time_finish=clock();
    time_duration=(double)(time_finish-time_start);
    sprintf(info, "%s[Time      ]%fus\n",info,time_duration);
    sprintf(info, "%s[Count     ]%d\n",info,frame_current_index);
    
    //释放资源
    //av_packet_free(&pkt);
    fclose(file_yuv420p);
    av_frame_free(&avFrame);
    av_frame_free(&avframe_yuv420p);
    free(out_buffer);
    avcodec_close(aVCodecContext);
    avformat_free_context(avFormatContext);
    sws_freeContext(swsContext);
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    self.content.text=info_ns;
}
@end
