
Pod::Spec.new do |s|

  s.name         = "QIMUIKit"
  s.version      = "0.0.1-beta.1"
  s.summary      = "Qunar chat App 6.0+ version QIMCommon"
  s.description  = <<-DESC
                   Qunar QIMCommon解决方案

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author       = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "", :branch=> 'qimsdk_newV2'}

  s.ios.deployment_target   = '9.0'

  s.platform     = :ios, "9.0"

  s.public_header_files = "QIMUIKit/**/*"
# s.prefix_header_file = "QIMUIKit/QIMUIKit.pch"

  s.source_files = "QIMUIKit/Application/**/*.{h,m,c}", "QIMUIKit/General/**/*.{h,m,c}", "QIMUIKit/Me/**/*.{h,m,c}", "QIMUIKit/QIMNotificationManager.*", "QIMUIKit/QIMJumpURLHandle.*", "QIMUIKit/QIMFastEntrance.*", "QIMUIKit/QIMAppWindowManager.*", "QIMUIKit/QIMCommonUIFramework.h", "QIMUIKit/QIMRemoteNotificationManager.*", "QIMUIKit/QIMMWPhotoTableViewController.*"
  s.vendored_libraries = "QIMCommon/QIMSDKUI/opencore-amr/lib/*.a"
  s.resources = "QIMUIKit/QIMUIKitResources/片段/*", "QIMUIKit/Application/ViewController/Login/QIMLoginViewController.xib", "QIMUIKit/QIMUIKitResources/Audio/*", "QIMUIKit/QIMUIKitResources/Certificate/*", "QIMUIKit/QIMUIKitResources/Fonts/*", "QIMUIKit/QIMUIKitResources/Stickers/*", "QIMUIKit/QIMUIKitResources/QIMUIKit.xcassets", "QIMUIKit/QIMUIKitResources/QIMI18N.bundle"
  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'DEBUGLOG=1'}
  s.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Private/QIMUIKit/**\" \"${PODS_ROOT}/Headers/Public/**\""}

  non_arc_files = 'QIMUIKit/General/Verders/CoretText/NSAttributedString+Attributes.*{h,m}'
  mwphoto_files = 'QIMUIKit/General/Verders/QIMMWPhotoBrowser/**/*'
  s.exclude_files = non_arc_files
  s.exclude_files = mwphoto_files


  # 需要创建一个subspec,将mrc的文件添加到subspec中,注意如果需要的话在主spec中设置exclude_files来排除一下,不要让两个Spec都包含 mrc 的文件。
    s.subspec 'NOARC' do |mrc|
        mrc.requires_arc = false
        mrc.public_header_files = non_arc_files
        mrc.source_files = non_arc_files
    end
    
    s.subspec 'QIMCells' do |cells|
        cells.public_header_files = "QIMUIKit/QTalkMessageBaloon/**/*.{h,m,c}"
        cells.source_files = "QIMUIKit/QTalkMessageBaloon/**/*.{h,m,c}"
        cells.resource_bundles = {'QIMSourceCode' => ['QIMUIKit/QTalkMessageBaloon/**/*.{html,js,css}']}
    end
  
    s.subspec 'ImagePicker' do |imagePicker|
        imagePicker.public_header_files = "QIMUIKit/QTalkImagePicker/**/*{h,m,c}"
        imagePicker.source_files = "QIMUIKit/QTalkImagePicker/**/*{h,m,c}"
    end

    s.subspec 'QIMMWPhotoBrowser' do |photoBrowser|
        photoBrowser.source_files = ['QIMUIKit/General/Verders/QIMMWPhotoBrowser/**/*{h,m}']
        photoBrowser.frameworks = 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MediaPlayer'
        photoBrowser.weak_frameworks = 'Photos'

        photoBrowser.dependency 'MBProgressHUD', '~> 0.9'
        photoBrowser.dependency 'DACircularProgress', '~> 2.3'

        # SDWebImage
        # 3.7.2 contains bugs downloading local files
        # https://github.com/rs/SDWebImage/issues/1109
        photoBrowser.dependency 'SDWebImage', '~> 3.7', '!= 3.7.2'
        photoBrowser.resource = ['QIMUIKit/General/Verders/QIMMWPhotoBrowser/Assets']
    end

    s.subspec 'QIMNot' do |note|
      note.public_header_files = "QIMNoteUI/QTalkTodoList/**/*.{h}", "QIMNoteUI/QTEvernotes/**/*.{h}", "QIMNoteUI/QTPassword/**/*.{h}"
      note.source_files = "QIMNoteUI/**/*.{h,m,c}"
      note.resource = ["QIMNoteUI/CKEditor5.bundle", "QIMNoteUI/QTPassword/EditPasswordView.xib"]

    end


    s.subspec 'QIMUIVendorKit' do |vendorkit|
      vendorkit.source_files = ['QIMUIVendorKit/QIMButton/**/*{h,m}', 'QIMUIVendorKit/QIMArrowView/**/*{h,m}', 'QIMUIVendorKit/QIMColorPicker/**/*{h,m,c}', 'QIMUIVendorKit/QIMDaePickerView/**/*{h,m}', 'QIMUIVendorKit/QIMGDPerformanceView/**/*{h,m}', 'QIMUIVendorKit/QIMXMenu/**/*{h,m}', 'QIMUIVendorKit/QIMPopVC/**/*{h,m}']
      vendorkit.resource = ['QIMUIVendorKit/QIMArrowView/QIMArrowCellTableViewCell.xib', 'QIMUIVendorKit/QIMDaePickerView/QIMWSDatePickerView.xib']
    end
    
    s.dependency 'MJRefresh'
    s.dependency 'YLGIFImage'
    s.dependency 'FDFullscreenPopGesture'
    s.dependency 'MGSwipeTableCell'
    s.dependency 'NJKWebViewProgress'
    s.dependency 'AMapSearch'
    s.dependency 'AMapLocation'
    s.dependency 'AMap3DMap'
    s.dependency 'MMPickerView'
    s.dependency 'SCLAlertView-Objective-C'
    s.dependency 'MMMarkdown'
    s.dependency 'LCActionSheet'
    s.dependency 'MDHTMLLabel'
    s.dependency 'SwipeTableView'
    s.dependency 'Toast'

    s.frameworks = 'UIKit','MessageUI', 'Foundation', 'JavaScriptCore', 'AVFoundation', 'OpenGLES', 'MobileCoreServices', 'AssetsLibrary', 'QuartzCore', 'CoreMotion', 'CoreText'
    s.libraries = 'stdc++', 'bz2', 'resolv', 'icucore', 'xml2'

end
