
Pod::Spec.new do |s|

    s.name         = "QIMNoteUI"
    s.version      = "0.0.1-beta.1"
    s.summary      = "Qunar chat App 6.0+ version QIMCommon"
    s.description  = <<-DESC
                    Qunar QIMNoteUI解决方案

    DESC

    s.homepage     = "https://im.qunar.com"
    s.license      = "Copyright 2018 im.qunar.com"
    s.author       = { "Qunar IM" => "qtalk@qunar.com" }

    s.source       = { :git => "https://im.qunar.com", :branch=> 'qimsdk'}

    s.ios.deployment_target   = '9.0'

    s.platform     = :ios, "9.0"

    s.public_header_files = "QIMNoteUI/QTalkTodoList/**/*.{h}", "QIMNoteUI/QTEvernotes/**/*.{h}", "QIMNoteUI/QTPassword/**/*.{h}"
    s.source_files = "QIMNoteUI/**/*.{h,m,c}"
    s.resource = ["QIMNoteUI/CKEditor5.bundle", "QIMNoteUI/QTPassword/EditPasswordView.xib", "QIMNoteUI/QTalkTodoList/Model/*.{plist}"]

    s.frameworks = 'UIKit','MessageUI', 'Foundation', 'JavaScriptCore', 'AVFoundation', 'OpenGLES', 'MobileCoreServices', 'AssetsLibrary', 'QuartzCore', 'CoreMotion', 'CoreText'
#s.libraries = 'stdc++', 'bz2', 'resolv', 'icucore', 'xml2'

end
