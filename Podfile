# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
ENV["COCOAPODS_DISABLE_STATS"] = "true"
# 忽略cocoaPods警告
inhibit_all_warnings!

# source 'https://github.com/Lidalu/QIMOpenSSL.git'
source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
source 'git@github.com:CocoaPods/Specs.git'

target 'IMSDK-iOS' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for IMSDK-iOS
    pod 'QIMSDK', path: './QIMSDK'
    pod 'QIMUIKit', path: './QIMUIKit'
    pod 'QIMNoteUI', path: './QIMNoteUI'
    pod 'QIMUIVendorKit', path: './QIMUIVendorKit'
    pod 'QIMPublicRedefineHeader', path: './QIMPublicRedefineHeader'

    pod 'QIMKitVendor', path: './QIMKitVendor'
    pod 'QIMGeneralModule', path: './QIMGeneralModule'
    pod 'QIMCommon', path: './QIMCommon'
    pod 'QIMCommonCategories'
    pod 'QIMDataBase'
  
  
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

end

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
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) COCOAPODS=1 QIMWebRTCEnable=1 QIMNoteEnable=1 QIMLogEnable=1 QIMAudioEnable=1 QIMZipEnable=1 QIMPinYinEnable=1 QIMRNEnable=1'
        end
    end
end
