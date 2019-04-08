Pod::Spec.new do |s|
  s.name         = "QIMOpenSSL"
  s.version      = "1.0.0"
  s.summary      = "OpenSSL for iOS"
  s.description  = "QIM Public OpenSSL is an SSL/TLS and Crypto toolkit."
  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.source       = { :git => "https://github.com/qunarcorp/libqimopenssl-ios.git", :tag => "#{s.version}"}

  s.author        = { "Qunar IM" => "qtalk@qunar.com" }

  s.ios.deployment_target = '6.0'
  s.ios.source_files        = 'include-ios/openssl/**/*.h'
  s.ios.public_header_files = 'include-ios/openssl/**/*.h'
  s.ios.header_dir          = 'openssl'
  s.ios.preserve_paths      = 'lib-ios/libcrypto.a', 'lib-ios/libssl.a'
  s.ios.vendored_libraries  = 'lib-ios/libcrypto.a', 'lib-ios/libssl.a'

  s.libraries = 'ssl', 'crypto'
  s.requires_arc = false
end
