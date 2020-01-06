# FFmpegIosStudy

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
