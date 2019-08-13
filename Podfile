# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
ENV["COCOAPODS_DISABLE_STATS"] = "true"
# 忽略cocoaPods警告
inhibit_all_warnings!

source 'https://github.com/qunarcorp/libqimkit-ios-cook.git'
source 'git@github.com:CocoaPods/Specs.git'

target 'IMSDK-iOS' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for IMSDK-iOS
 
    pod 'QIMUIKit', '~> 4.0'
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
    end
end
