
Pod::Spec.new do |s|

  s.name         = "QIMUIKit"
  s.version      = "2.0.21"
  s.summary      = "QIM App UI 9.0+ version"
  s.description  = <<-DESC
                   QIM UI

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author       = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "https://github.com/qunarcorp/libqimuikit-ios.git", :tag=> s.version.to_s}

  s.ios.deployment_target   = '9.0'

  s.platform     = :ios, "9.0"

  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'DEBUGLOG=1'}
  s.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Private/QIMUIKit/**\" \"${PODS_ROOT}/Headers/Public/**\""}
  $debug = ENV['debug']

  s.subspec 'PublicUIHeader'  do |ph|
    ph.public_header_files = "QIMUIKit/QIMNotificationManager*.{h}", "QIMUIKit/QIMJumpURLHandle*.{h}", "QIMUIKit/QIMFastEntrance*.{h}", "QIMUIKit/QIMAppWindowManager*.{h}", "QIMUIKit/QIMCommonUIFramework*.*{h}", "QIMUIKit/QIMRemoteNotificationManager*.{h}"
    ph.source_files = "QIMUIKit/QIMNotificationManager*.{h,m,c,mm}", "QIMUIKit/QIMJumpURLHandle*.{h,m,c,mm}", "QIMUIKit/QIMFastEntrance*.{h,m,c,mm}", "QIMUIKit/QIMAppWindowManager*.{h,m,c,mm}", "QIMUIKit/QIMCommonUIFramework*.*{h,m,c,mm}", "QIMUIKit/QIMRemoteNotificationManager*.{h,m,c,mm}"
  end

  s.subspec 'QIMAppUI' do |app|
    app.public_header_files = "QIMUIKit/Application/**/*.{h}"
    app.source_files = "QIMUIKit/Application/**/*.{h,m,c,mm}"
    app.dependency 'QIMUIKit/PublicUIHeader'
  end

  s.subspec 'QIMGeneralUI' do |generalUI|
    generalUI.public_header_files = "QIMUIKit/General/**/*.{h}"
    generalUI.source_files = "QIMUIKit/General/**/*.{h,m,c,mm}"
    generalUI.dependency 'QIMUIKit/PublicUIHeader'
  end

  s.subspec 'QIMMeUI' do |me|
    me.public_header_files = "QIMUIKit/Me/**/*.{h}"
    me.source_files = "QIMUIKit/Me/**/*.{h,m,c,mm}"
    me.dependency 'QIMUIKit/PublicUIHeader'
  end

  s.subspec 'QIMUISDK' do |uisdk|
    uisdk.public_header_files = "QIMSDK/QIMSDK/**/*.{h}"
    uisdk.source_files = "QIMSDK/QIMSDK/*.{h,m}"
  end
    
  s.subspec 'QIMCells' do |cells|
      cells.public_header_files = "QIMUIKit/QTalkMessageBaloon/**/*.{h}"
      cells.source_files = "QIMUIKit/QTalkMessageBaloon/**/*.{h,m,c}"
      cells.resource_bundles = {'QIMSourceCode' => ['QIMUIKit/QTalkMessageBaloon/**/*.{html,js,css}']}
      cells.dependency 'QIMUIKit/PublicUIHeader'
  end

  s.subspec 'ImagePicker' do |imagePicker|
      imagePicker.public_header_files = "QIMUIKit/QTalkImagePicker/**/*{h}"
      imagePicker.source_files = "QIMUIKit/QTalkImagePicker/**/*{h,m,c}"
      imagePicker.dependency 'QIMUIKit/PublicUIHeader'
  end

  s.subspec 'QIMMWPhotoBrowser' do |photoBrowser|
      photoBrowser.source_files = ['QIMUIKit/General/Verders/QIMMWPhotoBrowser/**/*{h,m}']
      photoBrowser.frameworks = 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MediaPlayer'
      photoBrowser.weak_frameworks = 'Photos'

      photoBrowser.dependency 'MBProgressHUD'
      photoBrowser.dependency 'DACircularProgress'

      # SDWebImage
      # 3.7.2 contains bugs downloading local files
      # https://github.com/rs/SDWebImage/issues/1109
      photoBrowser.dependency 'SDWebImage'
      photoBrowser.dependency 'QIMUIKit/PublicUIHeader'
      photoBrowser.resource = ['QIMUIKit/General/Verders/QIMMWPhotoBrowser/Assets']
  end

  s.subspec 'QIMUIVendorKit' do |vendorkit|
    vendorkit.source_files = ['QIMUIVendorKit/QIMButton/**/*{h,m}', 'QIMUIVendorKit/QIMArrowView/**/*{h,m}', 'QIMUIVendorKit/QIMColorPicker/**/*{h,m,c}', 'QIMUIVendorKit/QIMDaePickerView/**/*{h,m}', 'QIMUIVendorKit/QIMGDPerformanceView/**/*{h,m}', 'QIMUIVendorKit/QIMXMenu/**/*{h,m}', 'QIMUIVendorKit/QIMPopVC/**/*{h,m}']
    vendorkit.resource = ['QIMUIVendorKit/QIMArrowView/QIMArrowCellTableViewCell.xib', 'QIMUIVendorKit/QIMDaePickerView/QIMWSDatePickerView.xib']
  end


  s.subspec 'QIMNote' do |note|
    note.public_header_files = "QIMNoteUI/QTalkTodoList/**/*.{h}", "QIMNoteUI/QTEvernotes/**/*.{h}", "QIMNoteUI/QTPassword/**/*.{h}"
    note.source_files = "QIMNoteUI/**/*.{h,m,c}"
    note.resource = ["QIMNoteUI/CKEditor5.bundle", "QIMNoteUI/QTPassword/EditPasswordView.xib"]
    note.dependency 'QIMUIKit/QIMUIVendorKit'
    note.dependency 'QIMUIKit/PublicUIHeader'
  end

  s.subspec 'QIMRN' do |rn|
    puts '.......QIMRN源码........'
    rn.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMRNEnable=1', "HEADER_SEARCH_PATHS" => "$(PROJECT_DIR)/node_modules/react-native"}
    rn.pod_target_xcconfig = {'OTHER_LDFLAGS' => '$(inherited)'}
    rn.source_files = ['QIMRNKit/rn_3rd/**/*{h,m,c}']
    rn.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Public/QIMRNKit/**\" \"$(PODS_ROOT)/boost-for-react-native\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/../node_modules\" \"$(PODS_ROOT)/../node_modules/react-native/ReactCommon/yoga\""}
    rn.resource = 'QIMRNKit/QIMRNKit.bundle'
    rn.frameworks = 'UIKit', 'Foundation'
  end
  
  s.subspec 'QIMUIKit-NORN' do |norn|
    puts '.......引用QIMUIKit-NORN源码........'
    norn.resources = "QIMUIKit/QIMUIKitResources/片段/*", "QIMUIKit/Application/ViewController/Login/QIMLoginViewController.xib", "QIMUIKit/QIMUIKitResources/Audio/*", "QIMUIKit/QIMUIKitResources/Certificate/*", "QIMUIKit/QIMUIKitResources/Fonts/*", "QIMUIKit/QIMUIKitResources/Stickers/*", "QIMUIKit/QIMUIKitResources/QIMUIKit.xcassets", "QIMUIKit/QIMUIKitResources/QIMI18N.bundle"
    norn.dependency 'QIMUIKit/PublicUIHeader'
    norn.dependency 'QIMUIKit/QIMUISDK'
    norn.dependency 'QIMUIKit/QIMAppUI'
    norn.dependency 'QIMUIKit/QIMGeneralUI'
    norn.dependency 'QIMUIKit/QIMMeUI'
    norn.dependency 'QIMUIKit/QIMCells'
    norn.dependency 'QIMUIKit/ImagePicker'
    norn.dependency 'QIMUIKit/QIMMWPhotoBrowser'
    norn.dependency 'QIMUIKit/QIMUIVendorKit'
    norn.dependency 'QIMUIKit/QIMNote'
  end
  
  s.subspec 'QIMUIKit-FULL' do |full|
    puts '.......引用QIMUIKit-FULL源码........'
    full.resources = "QIMUIKit/QIMUIKitResources/片段/*", "QIMUIKit/Application/ViewController/Login/QIMLoginViewController.xib", "QIMUIKit/QIMUIKitResources/Audio/*", "QIMUIKit/QIMUIKitResources/Certificate/*", "QIMUIKit/QIMUIKitResources/Fonts/*", "QIMUIKit/QIMUIKitResources/Stickers/*", "QIMUIKit/QIMUIKitResources/QIMUIKit.xcassets", "QIMUIKit/QIMUIKitResources/QIMI18N.bundle", "QIMRNKit/QIMRNKit.bundle"
    full.dependency 'QIMUIKit/PublicUIHeader'
    full.dependency 'QIMUIKit/QIMUISDK'
    full.dependency 'QIMUIKit/QIMAppUI'
    full.dependency 'QIMUIKit/QIMGeneralUI'
    full.dependency 'QIMUIKit/QIMMeUI'
    full.dependency 'QIMUIKit/QIMCells'
    full.dependency 'QIMUIKit/ImagePicker'
    full.dependency 'QIMUIKit/QIMMWPhotoBrowser'
    full.dependency 'QIMUIKit/QIMUIVendorKit'
    full.dependency 'QIMUIKit/QIMNote'
    full.dependency 'QIMUIKit/QIMRN'
  end
  
  s.dependency 'MJRefresh'
  s.dependency 'YLGIFImage'
  s.dependency 'SwipeTableView'
  s.dependency 'LCActionSheet'
  s.dependency 'MDHTMLLabel'
  s.dependency 'MMMarkdown'
  s.dependency 'MGSwipeTableCell'
  s.dependency 'NJKWebViewProgress'
  s.dependency 'FDFullscreenPopGesture'
  s.dependency 'AMapSearch'
  s.dependency 'AMapLocation'
  s.dependency 'AMap3DMap'
  s.dependency 'MMPickerView'
  s.dependency 'SCLAlertView-Objective-C'
  s.dependency 'MMMarkdown'
  s.dependency 'Toast' 
  s.dependency 'YYKeyboardManager'

 if $debug
  puts 'debug QIMUIKit'

else

  puts '线上release QIMUIKit'
  s.dependency 'QIMCommon', '~> 2.0.2'
  s.dependency 'QIMGeneralModule'
end

  s.default_subspec = 'QIMUIKit-FULL'
  s.frameworks = 'UIKit','MessageUI', 'Foundation', 'JavaScriptCore', 'AVFoundation', 'OpenGLES', 'MobileCoreServices', 'AssetsLibrary', 'QuartzCore', 'CoreMotion', 'CoreText'
  s.libraries = 'stdc++', 'bz2', 'resolv', 'icucore', 'xml2'

end
