Pod::Spec.new do |s|

  s.name         = "CombineX.swift"
  s.module_name  = "CombineX"
  s.version      = "0.0.1-beta.3"
  s.summary      = "Open source implementation for Apple's Combine specs."
  s.homepage     = "https://github.com/luoxiu/CombineX"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Quentin Jin" => "luoxiustm@gmail.com" }

  s.swift_versions              = ['5.0']
  s.osx.deployment_target       = "10.12"
  s.ios.deployment_target       = "10.0"
  s.tvos.deployment_target      = "10.0"
  s.watchos.deployment_target   = "3.0"

  s.source = { :git => "https://github.com/luoxiu/CombineX.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/CombineX/**/*.swift"

end
