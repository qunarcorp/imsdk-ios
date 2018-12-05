
Pod::Spec.new do |s|

  s.name         = "QIMCommon"
  s.version      = "0.0.1-beta.1"
  s.summary      = "Qunar chat App 6.0+ version QIMCommon"
  s.description  = <<-DESC
                   Qunar QIMCommon解决方案

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author        = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "https://im.qunar.com", :branch=> 'qimsdk'}

  s.ios.deployment_target   = '9.0'

  $lib = ENV['use_lib']
  if $lib

        puts '---------QIMCommonSDK二进制-------'

       s.source_files = 'ios_libs/Headers/**/*.h'
       s.vendored_libraries = ['ios_libs/Frameworks/libQIMCommon.a']
       s.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Private/QIMCommon/**\" \"${PODS_ROOT}/Headers/Public/QIMCommon/**\" \"${PODS_ROOT}/Headers/Public/QIMCommon/**\""}

        s.frameworks = 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'AudioToolbox', 'AVFoundation', 'UserNotifications', 'CoreTelephony','QuartzCore', 'CoreGraphics', 'Security'
        s.libraries = 'sqlite3.0', 'stdc++', 'bz2'

        s.dependency 'QIMOpenSSL'
        s.dependency 'ASIHTTPRequest'
        s.dependency 'YYCache'
        s.dependency 'YYModel'
        s.dependency 'ProtocolBuffers'
        s.dependency 'CocoaAsyncSocket'
        s.dependency 'UICKeyChainStore'
        s.dependency 'AvoidCrash'

        s.dependency 'CocoaLumberjack'

    else

        puts '---------QIMCommonSDK二进制-------'

        s.source_files = 'ios_libs/Headers/**/*.h'
        s.vendored_libraries = ['ios_libs/Frameworks/libQIMCommon.a']
        s.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Private/QIMCommon/**\" \"${PODS_ROOT}/Headers/Public/QIMCommon/**\" \"${PODS_ROOT}/Headers/Public/QIMCommon/**\""}

        s.frameworks = 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'AudioToolbox', 'AVFoundation', 'UserNotifications', 'CoreTelephony','QuartzCore', 'CoreGraphics', 'Security'
        s.libraries = 'sqlite3.0', 'stdc++', 'bz2'

        s.dependency 'QIMOpenSSL'
        s.dependency 'ASIHTTPRequest'
        s.dependency 'YYCache'
        s.dependency 'YYModel'
        s.dependency 'ProtocolBuffers'
        s.dependency 'CocoaAsyncSocket'
        s.dependency 'UICKeyChainStore'
        s.dependency 'AvoidCrash'

        s.dependency 'CocoaLumberjack'

    end

end
