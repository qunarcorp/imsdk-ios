
Pod::Spec.new do |s|

  s.name         = "QIMGeneralModule"
  s.version      = "0.0.1-beta.1"
  s.summary      = "Qunar chat App 6.0+ version QIMGeneralModule"
  s.description  = <<-DESC
                   Qunar QIMGeneralModule公共模块

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author        = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "https://im.qunar.com", :branch=> 'qimsdk'}

  s.ios.deployment_target   = '9.0'

  s.platform     = :ios, "9.0"
  s.source_files = "QIMGeneralModule/QIMGeneralModuleFramework.h"

  s.subspec 'WebRTC' do |webrtc|
    
      webrtc.resources = "QIMGeneralModule/WebRTC/RTC/icons/*.{png,jpg}", "QIMGeneralModule/WebRTC/RTC/sound/*.{mp3,wav}"
      webrtc.source_files = 'QIMGeneralModule/WebRTC/**/*.{h,m,c}', 'QIMGeneralModule/WebRTC/RTC/**/*.{h,m,c}'
      webrtc.public_header_files = 'QIMGeneralModule/WebRTC/**/*.{h,m,c}' 'QIMGeneralModule/WebRTC/RTC/**/*.{h,m,c}'
      webrtc.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMWebRTCEnable=1'}
      webrtc.frameworks = 'VideoToolbox', 'GLKit', 'CoreTelephony', 'AVFoundation', 'UIKit', 'Foundation'
      webrtc.dependency 'SocketRocket'
      webrtc.dependency 'QIMOpenSSL'
      webrtc.dependency 'GoogleWebRTC'
      webrtc.libraries = 'stdc++', 'bz2', 'resolv'

  end

  s.subspec 'Note' do |note|

      note.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMNoteEnable=1'}
      note.public_header_files = 'QIMGeneralModule/QIMNotes/ARC/**/*{h,m,c}'
      note.source_files = ['QIMGeneralModule/QIMNotes/ARC/**/*{h,m,c}', 'QIMGeneralModule/QIMNotes/NoARC/**/*{h,m,c}']
      note.requires_arc = false
      note.requires_arc = ['QIMGeneralModule/QIMNotes/ARC/**/*{h,m,c}']
  end

  s.subspec 'Notify' do |notify|

      notify.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMNotifyEnable=1'}
      notify.source_files = ['QIMGeneralModule/QIMNotify/**/*{h,m,c}']
      notify.public_header_files = 'QIMGeneralModule/QIMNotify/**/*{h,m,c}'

  end

  s.subspec 'Log' do |log|

      log.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMLogEnable=1'}
      log.source_files = ['QIMGeneralModule/QIMLocalLog/**/*{h,m,c}']
      log.public_header_files = 'QIMGeneralModule/QIMLocalLog/**/*{h,m,c}'

  end
  
  s.subspec 'Calendars' do |calendar|
      calendar.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMCalendarEnable=1'}
      calendar.source_files = ['QIMGeneralModule/QIMCalendars/**/*{h,m,c}']
      calendar.public_header_files = 'QIMGeneralModule/QIMCalendars/**/*{h,m,c}'
  end
  
  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'CoreTelephony'

end
