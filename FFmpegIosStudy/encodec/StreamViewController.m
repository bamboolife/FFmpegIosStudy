//
//  StreamViewController.m
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/7.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import "StreamViewController.h"
#import <libavformat/avformat.h>
#import <libavutil/log.h>
#import <libavutil/time.h>
#import <libavutil/mathematics.h>
#import <libavcodec/avcodec.h>

@interface StreamViewController ()

@end

@implementation StreamViewController

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
-(void)avError:(int) errNum{
    char buf[1024];
    //获取错误信息
    av_strerror(errNum, buf, sizeof(buf));
    printf("发生异常:%s",buf);
    return;
}
- (IBAction)streamButton:(id)sender {
    char input_url[500]={0};
    char output_url[500]={0};
    
    NSString *input_str= [NSString stringWithFormat:@"res.bundle/%@",self.inputPath.text];
    NSString *input_nsstr=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:input_str];
    NSString *out_str=self.outPath.text;
    
    sprintf(input_url,"%s" ,[input_nsstr UTF8String]);
    sprintf(output_url, "%s",[out_str UTF8String]);
    printf("%s\n",input_url);
    printf("%s\n",output_url);
    char in_filename[500]={0};
    char out_filename[500]={0};
    
    strcpy(in_filename,input_url);
    strcpy(out_filename,output_url);
    
    //初始化网络
    avformat_network_init();
    
    AVFormatContext *ifmt_ctx=NULL;
    int ret;
    //打开文件
    ret=avformat_open_input(&ifmt_ctx, in_filename, 0, 0);
    if(ret<0){
        printf("打开文件失败");
        [self avError:ret];
        return;
    }
    //查找流信息
    ret=avformat_find_stream_info(ifmt_ctx, 0);
    if(ret<0){
        printf("找不到流信息");
        [self avError:ret];
        return;
    }
     int video_stream_index=-1;
    //查找视频流索引
    for (int i=0; ifmt_ctx->nb_streams; i++) {
        AVCodecParameters *p=ifmt_ctx->streams[i]->codecpar;
        if(p->codec_type==AVMEDIA_TYPE_VIDEO){
               video_stream_index=i;
               break;
           }
    }
    //打印视频视频信息
    //0打印所有  inUrl 打印时候显示，
    av_dump_format(ifmt_ctx, 0, input_url, 0);
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //              输出流处理部分
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //如果是输入文件 flv可以不传，可以从文件中判断。如果是流则必须传
    //创建输出上下文
    AVFormatContext *ofmt_ctx=NULL;

    ret=avformat_alloc_output_context2(&ofmt_ctx, NULL, "flv", out_filename);//RTMP
     //avformat_alloc_output_context2(&ofmt_ctx, NULL, "mpegts", out_filename);//UDP
  if (!ofmt_ctx) {
         printf( "Could not create output context\n");
         ret = AVERROR_UNKNOWN;
      [self avError:ret];
      return;
     }
    if(ret<0){
        printf("创建输出上下文失败");
        [self avError:ret];
        return;
    }
   AVOutputFormat *ofmt=NULL;
   ofmt=ofmt_ctx->oformat;
    //根据输入封装格式中的流创建输出流
    for (int i=0;i<ifmt_ctx->nb_streams; i++) {
        //获取输入视频流
        AVStream *in_stream=ifmt_ctx->streams[i];
        //为输出上下文添加音视频流（初始化一个音视频流容器）
       // AVCodecContext *codec_ctx_in=avcodec_alloc_context3(NULL);
        //avcodec_parameters_to_context(codec_ctx_in, ifmt_ctx->streams[i]->codecpar);
        
        
        AVStream *out_stream=avformat_new_stream(ofmt_ctx, NULL);
        if (!out_stream) {
            printf("创建输出书视频流失败");
            ret=AVERROR_UNKNOWN;
            [self avError:ret];
            return;
        }
        //复制编解码上下文
        ret=avcodec_parameters_copy(out_stream->codecpar, in_stream->codecpar);
        if(ret<0){
            printf("copy 编解码上下文失败");
            [self avError:ret];
            return;
        }

        AVCodecContext *codec_ctx_out=avcodec_alloc_context3(NULL);
        avcodec_parameters_to_context(codec_ctx_out,ofmt_ctx->streams[i]->codecpar);
         codec_ctx_out->codec_tag=0;
               if (ofmt_ctx->oformat->flags&AVFMT_GLOBALHEADER) {
                   codec_ctx_out->flags|=AV_CODEC_FLAG_GLOBAL_HEADER;
               }
    
        
    }
   
    //打印输出信息
    av_dump_format(ofmt_ctx, 0, output_url, 1);
    ///////////////////////////////////////////////////////////////////////////////////
    //                   准备推流
    ///////////////////////////////////////////////////////////////////////////////////
   
    if (!(ofmt->flags&AVFMT_NOFILE)) {
       ret=avio_open(&ofmt_ctx->pb, output_url, AVIO_FLAG_WRITE);
        if (ret<0) {
            printf("不能打开推流地址");
            [self avError:ret];
            return;
        }
    }
    printf("avio_open success");
    ret=avformat_write_header(ofmt_ctx, NULL);
    if (ret<0) {
        printf("写入头信息失败");
        [self avError:ret];
        return;
    }
    
    AVPacket *pkt=(AVPacket *)alloca(sizeof(AVPacket));
    //推流每一帧数据
    //int64_t pts  [ pts*(num/den)  第几秒显示]
    //int64_t dts  解码时间 [P帧(相对于上一帧的变化) I帧(关键帧，完整的数据) B帧(上一帧和下一帧的变化)]  有了B帧压缩率更高。
    //获取当前的时间戳  微妙
    long long start_time=av_gettime();
    long long frame_index=0;
    while (1) {
        //输入输出视频流
        AVStream *in_stream, *out_stream;
        //获取解码前数据 得到一个AVPacket
        ret = av_read_frame(ifmt_ctx, pkt);
        if (ret<0) {
            break;
        }
        /*
        PTS（Presentation Time Stamp）显示播放时间
        DTS（Decoding Time Stamp）解码时间
        */
        //没有显示时间（比如未解码的 H.264 ）
        if (pkt->pts == AV_NOPTS_VALUE) {
            //AVRational time_base：时基。通过该值可以把PTS，DTS转化为真正的时间。
            AVRational time_base1 = ifmt_ctx->streams[video_stream_index]->time_base;

            //计算两帧之间的时间
            /*
            r_frame_rate 基流帧速率  （不是太懂）
            av_q2d 转化为double类型
            */
            int64_t calc_duration =(double) AV_TIME_BASE / av_q2d(ifmt_ctx->streams[video_stream_index]->r_frame_rate);

            //配置参数
            pkt->pts = (double) (frame_index * calc_duration) / (double) (av_q2d(time_base1) * AV_TIME_BASE);
            pkt->dts = pkt->pts;
            pkt->duration = (double) calc_duration / (double) (av_q2d(time_base1) * AV_TIME_BASE);
        }
        
        //延时
        if (pkt->stream_index == video_stream_index) {
            AVRational time_base = ifmt_ctx->streams[video_stream_index]->time_base;
            AVRational time_base_q = {1, AV_TIME_BASE};
            //计算视频播放时间
            int64_t pts_time = av_rescale_q(pkt->dts, time_base, time_base_q);
            //计算实际视频的播放时间
            int64_t now_time = av_gettime() - start_time;

            AVRational avr = ifmt_ctx->streams[video_stream_index]->time_base;
          
            printf("avr.num=%d,avr.den=%d,pkt.dts=%lld,pkt.pts=%lld,pts_time=%lld",avr.num,avr.den,pkt->dts,pkt->pts,pts_time);
            if (pts_time > now_time) {
                //睡眠一段时间（目的是让当前视频记录的播放时间与实际时间同步）
                av_usleep((unsigned int) (pts_time - now_time));
            }
        }
        in_stream = ifmt_ctx->streams[pkt->stream_index];
        out_stream = ofmt_ctx->streams[pkt->stream_index];
        //计算延时后，重新指定时间戳
        pkt->pts = av_rescale_q_rnd(pkt->pts, in_stream->time_base, out_stream->time_base,(AV_ROUND_NEAR_INF |AV_ROUND_PASS_MINMAX));
        pkt->dts = av_rescale_q_rnd(pkt->dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
        pkt->duration = (int) av_rescale_q(pkt->duration, in_stream->time_base,out_stream->time_base);
       
        //字节流的位置，-1 表示不知道字节流位置
        pkt->pos = -1;

        if (pkt->stream_index == video_stream_index) {
            printf("Send %lld video frames to output URL\n", frame_index);
            frame_index++;
        }
    
        //向输出上下文发送（向地址推送）
        ret = av_interleaved_write_frame(ofmt_ctx, pkt);

        if (ret < 0) {
            printf("发送数据包出错\n");
            break;
        }
        //释放
        av_packet_unref(pkt);
    }
    
       avformat_close_input(&ifmt_ctx);
       /* close output */
       if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE)) {
           avio_close(ofmt_ctx->pb);
       }
       avformat_free_context(ofmt_ctx);
       avformat_free_context(ifmt_ctx);
}
@end
