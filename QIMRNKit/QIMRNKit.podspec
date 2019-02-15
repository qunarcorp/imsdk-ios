
Pod::Spec.new do |s|

  s.name         = "QIMRNKit"
  s.version      = "0.0.1-beta.1"
  s.summary      = "Qunar chat App 6.0+ version QIMCommon"
  s.description  = <<-DESC
                   Qunar QIMCommon解决方案

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author       = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "http://gitlab.corp.qunar.com/qchat/qunarchat-oc.git", :branch=> 'qimsdk_newV2'}

  s.ios.deployment_target   = '9.0'

  s.platform     = :ios, "9.0"


  s.subspec 'RN' do |rn|
      puts '.......源码........'
      rn.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMRNEnable=1', "HEADER_SEARCH_PATHS" => "$(PROJECT_DIR)/node_modules/react-native"}
      rn.pod_target_xcconfig = {'OTHER_LDFLAGS' => '$(inherited)'}
      rn.source_files = ['QIMRNKit/rn_3rd/**/*{h,m,c}']
      rn.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Public/QIMRNKit/**\" \"$(PODS_ROOT)/boost-for-react-native\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/../node_modules\" \"$(PODS_ROOT)/../node_modules/react-native/ReactCommon/yoga\""}
      rn.resource = 'QIMRNKit/QIMRNKit.bundle'
  end

  s.frameworks = 'UIKit', 'Foundation'

end
