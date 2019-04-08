
Pod::Spec.new do |s|

  s.name         = "QIMCommonCategories"
  s.version      = "2.0.0"
  s.summary      = "Qunar chat App 6.0+ version QIMCommonCategories"
  s.description  = <<-DESC
                   Qunar QIMCommonCategories解决方案

                   DESC

  s.homepage     = "https://im.qunar.com"
  s.license      = "Copyright 2018 im.qunar.com"
  s.author        = { "Qunar IM" => "qtalk@qunar.com" }

  s.source       = { :git => "https://github.com/qunarcorp/libqimcommoncategories-ios.git", :tag => s.version.to_s}

  s.ios.deployment_target   = '9.0'


  s.platform     = :ios, "9.0"

  s.public_header_files = "QIMCommonCategories/**/*.{h}"
  s.source_files = "QIMCommonCategories/**/*.{h,m,c}"
  s.xcconfig = {'BITCODE_GENERATION_MODE' => 'bitcode'}
  s.frameworks = 'UIKit', 'Foundation', 'CoreFoundation', 'ImageIO'
end
