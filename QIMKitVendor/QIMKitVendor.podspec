
Pod::Spec.new do |s|


  s.name         = "QIMKitVendor"
  s.version      = "0.0.1-beta.1"
  s.summary      = "Qunar chat App 6.0+ version QIMKitVendor"

  s.description  = <<-DESC
                   Qunar QIMKitVendor解决方案

                   DESC

  s.homepage     = "http://www.qunar.com"
  s.license      = "Copyright 2015 Qunar.com"
  s.author        = { "qunar mobile" => "QIMKitVendor@qunar.com" }
  s.source       = { :git => "", :branch=> ''}
  s.ios.deployment_target   = '9.0'
  s.source_files = 'QIMKitVendor/QIMKitVendorPrivateLog.h'

  s.subspec 'Audio' do |audio|
    
    audio.source_files = 'QIMKitVendor/Audio/**/*.{h,m,c}', 'QIMKitVendor/Audio/include/**/*.{h,m,c}'
    audio.vendored_libraries = ['QIMKitVendor/Audio/opencore-amr/lib/libopencore-amrnb.a',
                                'QIMKitVendor/Audio/opencore-amr/lib/libopencore-amrwb.a']
    audio.requires_arc = false
    audio.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMAudioEnable=1'}
  end
  
  s.subspec 'ZBar' do |zbar|
      zbar.source_files = 'QIMKitVendor/QIMZBarSDK/Headers/ZBarSDK/zbar/*.{h,m,c}', 'QIMKitVendor/QIMZBarSDK/Headers/ZBarSDK/*.{h,m,c}', 'QIMKitVendor/QIMZBarSDK/libqrencode/**/*.{h,m,c}'
      zbar.vendored_libraries = ['QIMKitVendor/QIMZBarSDK/libzbar.a']
      zbar.pod_target_xcconfig = {"HEADER_SEARCH_PATHS" => "\"${PODS_ROOT}/Headers/Private/**\" \"${PODS_ROOT}/Headers/Private/QIMKitVendor/**\" \"${PODS_ROOT}/Headers/Public/QIMKitVendor/**\" \"${PODS_ROOT}/Headers/Public/QIMKitVendor/**\""}
      zbar.frameworks = 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'QuartzCore'
      zbar.libraries = 'iconv'
  end
  
  s.subspec 'Zip' do |zip|

      zip.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMZipEnable=1'}
      zip.source_files = ['QIMKitVendor/QIMZipArchive/**/*{h,m,c}']
      
  end

  s.subspec 'PinYin' do |pinyin|

    pinyin.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'QIMPinYinEnable=1'}
    pinyin.source_files = ['QIMKitVendor/QIMPinYin/**/*{h,m,c}']
    pinyin.resource_bundles = {'QIMPinYin' => ['QIMKitVendor/QIMPinYin/unicode_to_hanyu_qim_pinyin.txt']}
  end
  
  s.subspec 'JSON' do |json|
      
      json.public_header_files = 'QIMKitVendor/QIMJSON/**/*.{h,m,c}'
      json.source_files = ['QIMKitVendor/QIMJSON/**/*.{h,m,c}']
      
  end
  
  s.subspec 'DOG' do |dog|
      
      dog.public_header_files = 'QIMKitVendor/QIMWatchDog/**/*.{h,m,c}'
      dog.source_files = ['QIMKitVendor/QIMWatchDog/**/*.{h,m,c}']
      
  end
  
  s.subspec 'UUID' do |uuid|
      
      uuid.public_header_files = 'QIMKitVendor/QIMUUID/**/*.{h,m,c}'
      uuid.source_files = ['QIMKitVendor/QIMUUID/**/*.{h,m,c}']
      uuid.dependency 'UICKeyChainStore'
      
  end
  
  s.subspec 'DES' do |des|
      
      des.public_header_files = 'QIMKitVendor/QIMDES/**/*.{h,m,c}'
      des.source_files = ['QIMKitVendor/QIMDES/**/*.{h,m,c}']
      
  end
  
  s.subspec 'HTTP' do |http|
      
      http.public_header_files = 'QIMKitVendor/QIMHTTP/**/*.{h,m,c}'
      http.source_files = ['QIMKitVendor/QIMHTTP/**/*.{h,m,c}']
      http.dependency 'ASIHTTPRequest'
      
  end

  s.subspec 'GCD' do |gcd|
    
    gcd.public_header_files = 'QIMKitVendor/GCD/**/*.{h,m,c}'
    gcd.source_files = ['QIMKitVendor/GCD/**/*.{h,m,c}']
    gcd.requires_arc = false  
  end
  
  s.subspec 'Fabric' do |fabric|
      fabric.public_header_files = 'QIMKitVendor/QIMCrashlytics/Fabric/iOS/Fabric.framework/Headers/*h'
      fabric.source_files = 'QIMKitVendor/QIMCrashlytics/Fabric/iOS/Fabric.framework/Headers/*h'
      fabric.preserve_paths = 'QIMKitVendor/QIMCrashlytics/Fabric/iOS/Fabric.framework'
      fabric.vendored_frameworks = 'QIMKitVendor/QIMCrashlytics/Crashlytics/iOS/Crashlytics.framework', 'QIMKitVendor/QIMCrashlytics/Fabric/iOS/Fabric.framework'
      fabric.requires_arc = true
      fabric.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited)' }
  end
  
  s.subspec 'Crashlytics' do |crashlytics|
      crashlytics.source_files = 'QIMKitVendor/QIMCrashlytics/Crashlytics/iOS/Crashlytics.framework/Headers/*h'
      crashlytics.public_header_files = 'QIMKitVendor/QIMCrashlytics/Crashlytics/iOS/Crashlytics.framework/Headers/*h'
      crashlytics.vendored_frameworks = 'QIMKitVendor/QIMCrashlytics/Crashlytics/iOS/Crashlytics.framework'
      crashlytics.frameworks = 'Security', 'SystemConfiguration'
      crashlytics.libraries = 'z', 'c++'
  end
  
  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'CoreTelephony', 'AVFoundation'
  s.dependency 'ZipArchive'
  
end
