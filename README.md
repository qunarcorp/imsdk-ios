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
## 项目结构

* QIMSDK (UI模块)
* QIMRNKit (RN模块)

## 集成
`imsdk-ios` 目前提供手动集成与Cocoapods集成的方式

### 手动集成
你可以通过[历史版本下载地址](https://github.com/qunarcorp/imsdk-ios/releases)下载最新版本，解压之后添加到工程中，具体步骤参考[集成文档](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%85%A5%E6%96%87%E6%A1%A3)

### Cocoapods集成
我们建议你通过 Cocoapods 来进行 QIMSDK 的集成,
1. 在 Podfile 中加入以下内容:
 `
  
    source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
    
    pod 'QIMUIKit'
  `
    
2. 拷贝IMSDK-iOS根目录下的package.json文件到你项目根目录
3. 在项目根目录执行 `npm install && pod install`

## 历史版本:
你可以在当前仓库的 [Release](https://github.com/qunarcorp/imsdk-ios/releases) 进行历史版本下载。

## Demo运行

1. 初始化项目:  
   在项目根目录执行 `bash InstallDemo.sh` 或 `npm install && pod install`
2. 使用XCode打开IMSDK-iOS.xcworkspace并运行;

## 更新日志

你可以在 [这里](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDKDemo-Changelog) 查看IMSDK所有更新信息

## 问题反馈

-   qchat@qunar.com（邮件）
