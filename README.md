Startalk, The Best open sourced instant messenger software in the world!
* [Chinese Version(中文版)](https://github.com/qunarcorp/imsdk-ios/blob/master/README_zh_CN.md)

Public Cloud(Startalk App)
=====
Based on Startalk server and client-side, users can build their own domain,
Sign up an account, create new domains, add users, download client app, and configure navigation for domain,
After the 5 steps above, you own strong IM abilities.

Download client app [Download](https://im.qunar.com/new/#/download)

- Android

[![Startalk on Android](https://s.qunarzz.com/qtalk_official_web/pages/download/android.png)](https://qt.qunar.com/downloads/qtalk_android.apk)

- iOS

[![Startalk on iOS](https://qim.qunar.com/file/v2/download/temp/new/82a410a7a85627c123b1a7bd06745b4d.png?w=260&h=260)](https://qim.qunar.com/file/v2/download/temp/new/82a410a7a85627c123b1a7bd06745b4d.png?w=260&h=260)

Configure navigation for client app [Configure navigation](https://im.qunar.com/new/#/platform/access_guide/manage_nav?id=manage_nav_mb)

Private Cloud(Startalk SDK)
=====
Private Cloud is a way for decentralized deployment. Customers or enterprises would deploy the back end code on their own servers, embedding SDK into their own app. Every enterprise is an independent node; every node works independently, and the data would only be saved in the node.  

Please see the guide of embedding Android SDK and the configuration below.

## Requirements

- iOS 9.0 or later
- Xcode 10.0 or later

## Getting Started

- Read this Readme doc

## Communication
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/startalk).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.


## Example Run
```
1. pod install
2. open IMSDK-iOS.xcworkspace use Xcode10+
```
## How To Use

* Objective-C

```objective-c
#import "QIMSDK.h"
...
[QIMSDKUIHelper sharedInstanceWithRootNav:rootNav rootVc:rootVc];
...
BOOL success = [[QIMKit sharedInstance] qimNav_updateNavigationConfigWithDomain:@"qim.com" WithUserName:@"san.zhang"];
if (success = YES) {
  [[QIMKit sharedInstance] loginWithUserName:userName WithPassWord:userPwd];
} else {
  
}
...
UIView *sessionView = [[QIMSDKUIHelper sharedInstance] getQIMSessionListViewWithBaseFrame:self.view.bounds];
[self.view addSubview:sessionView];
```

- For details about how to use the library and clear examples, see [The detailed How to use](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%8F%A3%E6%96%87%E6%A1%A3%E8%AF%B4%E6%98%8E)

## Installation

There are four ways to use QIMSDK in your project:
- using CocoaPods
- manual install (build frameworks or embed Xcode Project)

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](http://cocoapods.org/#get_started) section for more details.

#### Podfile
```
source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
source 'git@github.com:CocoaPods/Specs.git'
platform :ios, '9.0'
pod 'QIMUIKit', '~> 4.0'
```

### Manual Installation Guide

See more on [Manual install Guide](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%85%A5%E6%96%87%E6%A1%A3)

### Import headers in your source files

In the source files where you need to use the library, import the umbrella header file:

```objective-c
#import "QIMSDK.h"
```

### Build Project

At this point your workspace should build without error. If you are having problem, post to the Issue and the
community can help you solve it.

Feedback
=====
-   qchat@qunar.com（Email）
