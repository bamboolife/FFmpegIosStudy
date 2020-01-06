# FFmpegIosStudy
### 编译iOS下FFmpeg
- FFmpeg可以多平台使用，如果要在ios平台使用，需要编译成ios能用的库
### 编译前的准备
#### （1）安装 gas-preprocessor
安装步骤（依次执行执行下面的命令）
```
sudo git clone https://github.com/bigsen/gas-preprocessor.git  /usr/local/bin/gas
sudo cp /usr/local/bin/gas/gas-preprocessor.pl /usr/local/bin/gas-preprocessor.pl
sudo chmod 777 /usr/local/bin/gas-preprocessor.pl
sudo rm -rf /usr/local/bin/gas/
```
#### （2）安装 yams
- yasm是汇编编译器，因为ffmpeg中为了提高效率用到了汇编指令，所以编译时需要安装
- 安装步骤（依次执行下面命令）：
```
curl http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz -o yasm-1.2.0.gz
tar -zxvf yasm-1.2.0.gz
cd yasm-1.2.0
./configure && make -j 4 && sudo make install 
```
#### (3)编写FFmpeg编译脚本
- 这里我使用的是github上开源的一个ios库编译脚本（FFmpeg-iOS-build-script.sh）
- 此脚本是一个自动编译脚本，脚本会自动从github中把源码下到本地并且编译出ios可用的库，支持各种架构
####  脚本下载地址：
```
git clone https://github.com/kewlbear/FFmpeg-iOS-build-script.git
```
### 自动编译脚本，参数配置简单说明
- 可以指定FFmpeg编译的版本，修改`FF_VERSION="4.1"`
#### 配置FFmpeg编译选项
修改配置 build-ffmpeg.sh 脚本里面 CONFIGURE_FLAGS 后面的内容即可。

配置的一些参数是为了更好的选择自己需要的功能，进行精简和优化ffmpeg。
我们可以手动看一下，在ffmpeg源码目录下，终端执行 ./configure --help列出全部参数 。下面简单列出部分参数：

#### 标准选项参数
```
--help ：          // 打印帮助信息 ./configure --help > ffmpegcfg.txt
--prefix=PREFIX ：// 安装程序到指定目录[默认：空]
--bindir=DIR ：  // 安装程序到指定目录[默认：/bin]
--datadir=DIR ：// 安装数据文件到指定目录[默认：/share/ffmpeg]
--incdir=DIR ：// 安装头文件到指定目录[默认：/include]
--mandir=DIR ：// 安装man page到指定路径[默认：/share/man]
```
#### 配置选项参数
```
--disable-static ：// 不构建静态库[默认：关闭]
--enable-shared ：// 构建共享库
--enable-gpl ：  // 允许使用GPL代码。
--enable-nonfree ：// 允许使用非免费代码。
--disable-doc ：  // 不构造文档
--disable-avfilter  ：// 禁止视频过滤器支持
--enable-small  ：   // 启用优化文件尺寸大小（牺牲速度）
--cross-compile  ： // 使用交叉编译
--disable-hwaccels  ：// 禁用所有硬件加速(本机不存在硬件加速器，所有不需要)
--disable-network  ：//  禁用网络


--disable-ffmpeg  --disable-ffplay  --disable-ffprobe  --disable-ffserver
// 禁止ffmpeg、ffplay、ffprobe、ffserver 

--disable-avdevice --disable-avcodec --disable-avcore
// 禁止libavdevice、libavcodec、libavcore 


--list-decoders ： // 显示所有可用的解码器
--list-encoders ： // 显示所有可用的编码器
--list-hwaccels ： // 显示所有可用的硬件加速器            
--list-protocols ： // 显示所有可用的协议                                  
--list-indevs ：   // 显示所有可用的输入设备
--list-outdevs ： // 显示所有可用的输出设备
--list-filters ：// 显示所有可用的过滤器
--list-parsers ：// 显示所有的解析器
--list-bsfs ：  // 显示所有可用的数据过滤器   


--disable-encoder=NAME ： // 禁用XX编码器 | disables encoder NAME
--enable-encoder=NAME ： // 用XX编码器 | enables encoder NAME
--disable-decoders ：   // 禁用所有解码器 | disables all decoders

--disable-decoder=NAME ： // 禁用XX解码器 | disables decoder NAME
--enable-decoder=NAME ： // 启用XX解码器 | enables decoder NAME
--disable-encoders ：   // 禁用所有编码器 | disables all encoders

--disable-muxer=NAME ： // 禁用XX混音器 | disables muxer NAME
--enable-muxer=NAME ： // 启用XX混音器 | enables muxer NAME
--disable-muxers ：   // 禁用所有混音器 | disables all muxers

--disable-demuxer=NAME ： // 禁用XX解轨器 | disables demuxer NAME
--enable-demuxer=NAME ： // 启用XX解轨器 | enables demuxer NAME
--disable-demuxers ：   // 禁用所有解轨器 | disables all demuxers

--enable-parser=NAME ：  // 启用XX剖析器 | enables parser NAME
--disable-parser=NAME ： // 禁用XX剖析器 | disables parser NAME
--disable-parsers ：    // 禁用所有剖析器 | disa
```
### 最后开始运行脚本生成ios库
```
./buils-ffmpeg.sh
```

### 编译ffmpeg iOS静态库出错总结

#### 错误一：xcrun -sdk iphoneos clang is unable to create an executable file.
C compiler test failed.
```
xcrun -sdk iphoneos clang is unable to create an executable file.
C compiler test failed.
```
解决方法：
如果xcode更新到了最新版，所以直接第三步就可以了
>第一步
<br>1）检查你的 git 版本
<br>2）确保你使用的是最新的 git 版本
<br>第二步
<br>1）在日志文件（ffmpeg-armv7/ffbuild/config.log）中使用关键字（xcrun: error）搜索错误详情
<br>2）例如：你会发现 “xcrun: error: SDK "iphoneos” 不能被定位到
<br>第三步
<br>1）在终端输入 sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/
<br>2）输入 mac 登录密码
<br>3）重试
#### 错误二： unknown directive .arch armv7-a
```
src/libavutil/arm/asm.S:50:9: error: unknown directive
        .arch armv7-a
        ^
```
解决方法：从Xcode 10 已经减弱了对 32 位的支持, 解决方法:
你就不要编译 armv7 的版本喽，要不然使用老版本的Xcode进行编译
