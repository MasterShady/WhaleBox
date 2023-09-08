# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'WhaleBox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Moya'
  pod 'SnapKit'
  pod 'Kingfisher'
  pod 'LookinServer', :configurations => ['Debug']
  pod 'ETNavBarTransparent'
  pod 'JXPhotoBrowser', '~> 3.0'
  pod 'JXSegmentedView', '~> 1.3.0'
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'MJRefresh'
  pod 'EmptyDataSet-Swift', '~> 5.0.0'
  pod 'YYKit', git: 'https://github.com/SAGESSE-CN/YYKit.git'
  pod 'Toaster'
  pod 'HandyJSON'
  pod 'JXPagingView/Paging'
  pod 'Moya/RxSwift'
  pod 'MBProgressHUD'
  pod 'ETNavBarTransparent'
  pod 'CLImagePickerTool'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
      if ['EZSwiftExtensions'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.0'
        end
      end
    end
    
    project.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
    end
  end
end
