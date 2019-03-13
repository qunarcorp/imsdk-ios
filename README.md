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

## Demo运行

1. 初始化项目:  
   在项目根目录执行 `bash InstallDemo.sh` 或 `npm install && pod install`
2. 使用XCode打开IMSDK-iOS.xcworkspace并运行;

## 集成
`imsdk-ios` 目前提供手动集成与Cocoapods集成的方式(IMSDK默认会依赖React-Native0.54版本), 具体步骤参考[集成文档](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%85%A5%E6%96%87%E6%A1%A3)

## 如何使用(主要接口)
首先需要对sdk进行初始化操作，之后配置导航Url，然后进行登录。
 ```init
  1. 在需要使用QIMSDK的地方引入头文件QIMSDK.h
     #import "QIMSDK.h"
  2. 初始化QIMSDK中的UI栈（如果需要在不同的地方进行scheme跳转，切换页面务必重新初始化QIMSDK的UI栈）
  
     [QIMSDKUIHelper sharedInstanceWithRootNav:rootNav rootVc:rootVc];
  ```
 ```config
  3. 配置导航地址

      BOOL success = [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithDomain:@"qim.com" WithUserName:@"san.zhang"];

  4. 账号密码登录账号

     [[QIMKit sharedInstance] loginWithUserName:@"san.zhang" WithPassWord:@"abcdef"];
  
  5. 获取消息对话列表页,贴到自定义VC的View上
     UIView *sessionView = [[QIMSDKHelper sharedInstance] getQIMSessionListViewWithBaseFrame:self.view.bounds];
     [self.view addSubview:sessionView];
  
  ```
  [其他接口参考](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%8F%A3%E6%96%87%E6%A1%A3%E8%AF%B4%E6%98%8E)

## 历史版本:
你可以在当前仓库的 [Release](https://github.com/qunarcorp/imsdk-ios/releases) 进行历史版本下载。

## 更新日志

你可以在 [这里](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDKDemo-Changelog) 查看IMSDK所有更新信息

## 问题反馈

-   qchat@qunar.com（邮件）
