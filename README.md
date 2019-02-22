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

## Demo运行

1. 初始化项目:  
   在项目根目录执行 `bash InstallDemo.sh` 或 `npm install && pod install`
2. 使用XCode打开IMSDK-iOS.xcworkspace并运行;

## 集成
`imsdk-ios` 目前提供手动集成与Cocoapods集成的方式(IMSDK默认会依赖React-Native0.54版本)

### 手动集成
你可以通过[历史版本下载地址](https://github.com/qunarcorp/imsdk-ios/releases)下载最新版本，解压之后添加到工程中，具体步骤参考[集成文档](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDK-iOS%E6%8E%A5%E5%85%A5%E6%96%87%E6%A1%A3)

### Cocoapods集成
我们建议你通过 Cocoapods 来进行 QIMSDK 的集成

1. 先下载IMSDK中的QIMSDK文件夹到项目根目录下
2. 在 Podfile 中加入以下内容（**这里需要特别注意，如果你需要集成带React-Native的组件，那么请pod 'QIMUIKit'. 如果你不需要集成带React-Native的组件，那么请pod 'QIMUIKitNORN'**. ）:

	```	
	source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
    pod 'QIMSDK', path: './QIMSDK'
    
    pod 'QIMUIKit', '~> 2.0'
    
    pod 'QIMKitVendor'
    pod 'QIMGeneralModule'
    pod 'QIMCommonCategories'

    ``` 
    
    ### 注意！！！ 如果你集成的是QIMUIKitNORN，那么请从Podfile中移除以下依赖。
    
    ``` 
    project 'IMSDK-iOS.project'
    # 取决于你的工程如何组织，你的node_modules文件夹可能会在别的地方。
    # 请将:path后面的内容修改为正确的路径。

    pod 'yoga', :path => './node_modules/react-native/ReactCommon/yoga'
    # Third party deps podspec link
    #    pod 'DoubleConversion', :podspec => './node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
    #    pod 'glog', :podspec => './node_modules/react-native/third-party-podspecs/glog.podspec'
    pod 'Folly', :podspec => './node_modules/react-native/third-party-podspecs/Folly.podspec'

    pod 'React',
    :path => './node_modules/react-native',
    :subspecs => [
    'Core',
    'RCTImage',
    'RCTNetwork',
    'RCTText',
    'RCTWebSocket',
    'RCTLinkingIOS',
    'RCTSettings',
    'RCTVibration',
    'RCTAnimation',
    'ART',
    'RCTGeolocation',
    'RCTActionSheet',
    'DevSupport',
    'CxxBridge',
    # 添加其他你想在工程中使用的依赖。
    ]
    pod 'react-native-image-picker', :path => './node_modules/react-native-image-picker'
    pod 'RNSVG', :path => './node_modules/react-native-svg'
    pod 'RNVectorIcons', :path => './node_modules/react-native-vector-icons'
    
    ```
    
    ```    
   	
	post_install do |installer_representation|

    	installer_representation.pods_project.targets.each do |target|

        # 修复Pod resources中携带xcassets的情况。
        # https://github.com/CocoaPods/CocoaPods/issues/7003
        # https://github.com/CocoaPods/CocoaPods/pull/7020

        if target.name.include? "IMSDK-iOS" then
            puts "Adding app icons for #{target.name}"
            copy_pods_resources_path = "Pods/Target Support Files/#{target.name}/#{target.name}-resources.sh"
            string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
            assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
            text = File.read(copy_pods_resources_path)
            new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
            File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
        end

        target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) COCOAPODS=1 QIMWebRTCEnable=1 QIMNoteEnable=1 QIMLogEnable=1 QIMAudioEnable=1 QIMZipEnable=1 QIMPinYinEnable=1, QIMRNEnable=1'
        end
  	  end
    	end
 		end
	
	```    
     
    
2. 拷贝IMSDK-iOS根目录下的package.json文件到你项目根目录
3. 在项目根目录执行 `npm install && pod install`
4. 注意：IMSDK默认会依赖React-Native0.54版本，如果你不想依赖，可以在Podfile中移除 `pod QIMRNKit`, 并且在pod_install中移除`QIMRNEnable=1 `

## 历史版本:
你可以在当前仓库的 [Release](https://github.com/qunarcorp/imsdk-ios/releases) 进行历史版本下载。

## 更新日志

你可以在 [这里](https://github.com/qunarcorp/imsdk-ios/wiki/QIMSDKDemo-Changelog) 查看IMSDK所有更新信息

## 问题反馈

-   qchat@qunar.com（邮件）
