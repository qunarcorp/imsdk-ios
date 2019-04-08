公有云（Startalk APP）
=====
基于Startalk服务器及客户端，用户可建立属于自己的域,

注册账号、新建域、添加域用户、下载客户端、配置域导航，

仅需5步，您就可以拥有强大的im能力，

客户端下载[下载](https://im.qunar.com/new/#/download)

客户端导航配置[配置导航](https://im.qunar.com/new/#/platform/access_guide/manage_nav?id=manage_nav_mb)

私有云（Startalk SDK）
=====
Startalk私有云是一种去中心化的部署方式，

用户或企业将Startalk后端代码完全部署在自己的服务器上，

选择SDK嵌入自己的APP中，

每个公司都是一个单独的节点，每个节点独立运营，数据只保存在节点中

## 介绍

QIMGeneralModule是在依赖[QIMCommon](https://github.com/qunarcorp/libqimcommon-ios)基础上实现的笔记本，密码箱，音视频通话，日历，日志记录等功能组件。

为了方便其他开发者不用依赖整套UI使用到笔记本，密码箱，音视频通话等功能，我从中拆分出以下独立组件：

  * QIMCalendars — 高性能的 iOS 日历组件。

  * QIMLocalLog — 高性能的 iOS日志记录框架。

  * QIMNotes — 史上最安全的密码箱，基于CKeditor5框架的富文本编辑器
  * QIMNotify - 全局通知条。
  * WebRTC - 高性能的音视频框架。

## 集成环境
* 编译版本 : iOS SDK 9.0 及以上。
* 操作系统 : iOS 9.0 及以上。

## 集成说明

### Cocoapods 集成

我们建议你通过 [Cocoapods](https://cocoapods.org/) 来进行 `QIMGeneralModule` 的集成,在 `Podfile` 中加入以下内容:

```shell
source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
pod 'QIMGeneralModule'
```

### 手动集成（不推荐！！！）

1. 下载QIMGeneralModule文件夹内的所有内容
2. 将QIMGeneralModule内的源文件，资源文件添加（拖放）到你的工程
3. 为`QIMGeneralModule/QIMNotes/NoARC/**/*.{h,m,c,mm}`添加编译参数`-fno-objc-arc`。
4. 链接以下系统依赖项
    * UIKit
    * Foundation
    * CoreFoundation
    * stdc++
    * bz2
    * resolv
    * CoreTelephony
    * AVFoundation
5. 链接以下第三方库
    * SCLAlertView-Objective-C
    * Masonry
6. 链接QIMSDK依赖项
    * QIMCommon
    * QIMOpenSSL
    * QIMKitVendor
    * QIMCommonCategories
    
## 问题反馈

-   qchat@qunar.com（邮件）
