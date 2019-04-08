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

QIMKitVendor是对于一些第三方组件的二次封装库

## 集成环境
* 编译版本 : iOS SDK 9.0 及以上。
* 操作系统 : iOS 9.0 及以上。

## 集成说明

### Cocoapods 集成

我们建议你通过 [Cocoapods](https://cocoapods.org/) 来进行 `QIMKitVendor` 的集成,在 `Podfile` 中加入以下内容:

```shell
source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
pod 'QIMKitVendor'
```

### 手动集成

1. 下载QIMGeneralModule文件夹内的所有内容
2. 将QIMGeneralModule内的源文件，资源文件添加（拖放）到你的工程
3. 为`QIMKitVendor/Audio/**/*.{h,m,c}, QIMKitVendor/Audio/include/**/*.{h,m,c}, 'QIMKitVendor/GCD/**/*.{h,m,c}'`添加编译参数`-fno-objc-arc`。
4. 链接以下系统依赖项
    * UIKit
    * Foundation
    * UIKit
    * AVFoundation
    * CoreTelephony
5. 链接QIMSDK依赖项
    * QIMCommonCategories
    
## 问题反馈

-   qchat@qunar.com（邮件）
