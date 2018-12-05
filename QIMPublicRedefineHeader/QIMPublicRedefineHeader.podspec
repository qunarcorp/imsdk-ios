

Pod::Spec.new do |s|

s.name         = "QIMPublicRedefineHeader"
s.version      = "0.0.1-beta.1"
s.summary      = "Qunar chat App 6.0+ version QIMPublicRedefineHeader"

s.description  = <<-DESC
                Qunar QIMPublicRedefineHeader解决方案

                DESC

s.homepage     = "http://www.qunar.com"
s.license      = "Copyright 2015 Qunar.com"
s.author        = { "qunar mobile" => "QIMPublicRedefineHeader@qunar.com" }
s.source       = { :git => "", :branch=> ''}
s.ios.deployment_target   = '9.0'
s.source_files = 'QIMPublicRedefineHeader/**/*{h}'

s.dependency 'CocoaLumberjack'

end
