
Pod::Spec.new do |s|

  s.name         = "QIMSDK"
  s.version      = "0.0.1-beta.1"
  s.summary      = "Qunar chat App 6.0+ version QIMSDK"
  s.description  = <<-DESC
                   Qunar QIMSDK公共模块

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author        = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "https://im.qunar.com", :branch=> 'qimsdk'}

  s.ios.deployment_target   = '9.0'

  s.public_header_files = "QIMSDK/**/*.{h}"
  s.source_files = "QIMSDK/*.{h,m}"
  s.frameworks = 'Foundation', 'UIKit'

end
