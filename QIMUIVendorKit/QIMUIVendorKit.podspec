Pod::Spec.new do |s|

    s.name         = "QIMUIVendorKit"
    s.version      = "0.0.1-beta.1"
    s.summary      = "Qunar chat App 6.0+ version QIMUIVendorKit"

    s.description  = <<-DESC
    Qunar QIMUIVendorKit解决方案

    DESC

    s.homepage     = "http://www.qunar.com"
    s.license      = "Copyright 2015 Qunar.com"
    s.author        = { "qunar mobile" => "QIMUIVendorKit@qunar.com" }
    s.source       = { :git => "", :branch=> ''}
    s.ios.deployment_target   = '9.0'

    bundlefiles = 'QIMUIVendorKit/React/assets'

    s.subspec 'QIMButton' do |button|
        button.source_files = ['QIMUIVendorKit/QIMButton/**/*{h,m}']
    end
    
    s.subspec 'QIMArrowView' do |arrow|
        arrow.source_files = ['QIMUIVendorKit/QIMArrowView/**/*{h,m}']
        arrow.resource = ['QIMUIVendorKit/QIMArrowView/QIMArrowCellTableViewCell.xib']
    end

    s.subspec 'QIMColorPicker' do |colorPicker|
        colorPicker.source_files = ['QIMUIVendorKit/QIMColorPicker/**/*{h,m,c}']
    end

    s.subspec 'QIMDaePickerView' do |picker|
        picker.source_files = ['QIMUIVendorKit/QIMDaePickerView/**/*{h,m}']
        picker.resource = ['QIMUIVendorKit/QIMDaePickerView/QIMWSDatePickerView.xib']

    end

    s.subspec 'QIMGDPerformanceView' do |performance|
        performance.source_files = ['QIMUIVendorKit/QIMGDPerformanceView/**/*{h,m}']
    end

    s.subspec 'QIMXMenu' do |menu|
        menu.source_files = ['QIMUIVendorKit/QIMXMenu/**/*{h,m}']
    end
    
    s.subspec 'QIMPopVC' do |pop|
        pop.source_files = ['QIMUIVendorKit/QIMPopVC/**/*{h,m}']
    end

end

