# QTalk IM SDK
## 概述
提供im通讯能力，包含单聊、群聊，通知推送。支持发送文本、图片、表情、语音、文件、地理位置….支持音视频通话。
## 项目结构

* QIMSDK
  * QIMCommon (IM模块)
     * ios_libs(静态库文件)
  * QIMUIKit (UI模块，扩展UI模块，密码箱，笔记本UI模块 )
  * QIMGeneralModule (日历，日志，笔记本，全局通知，音视频模块)
  * QIMKitVendor (音频，ZBar，Zip，Pinyin，JSON解析，HTTP等组件)

## 集成
`imsdk-ios ` 目前仅提供手动集成的方式

### 手动集成
你可以通过[历史版本下载地址](https://github.com/qunarcorp/imsdk-ios/releases)下载最新版本，解压之后添加到工程中，具体步骤参考[集成文档](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%85%A5%E6%96%87%E6%A1%A3)

## 历史版本:
你可以在当前仓库的 [Release](https://github.com/qunarcorp/imsdk-ios/releases) 进行历史版本下载。

## Demo运行

1. 初始化项目:  
   在项目根目录执行 `npm install & pod install`
2. 使用XCode打开IMSDK-iOS.xcworkspace并运行;

## 问题反馈

-   qchat@qunar.com（邮件）
