Pod::Spec.new do |s|

  s.name         = "CombineX"
  s.version      = "0.0.1-beta.3"
  s.summary      = "Open source implementation for Apple's Combine."
  s.homepage     = "https://github.com/cx-org/CombineX"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Quentin Jin" => "luoxiustm@gmail.com" }

  s.swift_versions              = ['5.0']
  s.osx.deployment_target       = "10.10"
  s.ios.deployment_target       = "8.0"
  s.tvos.deployment_target      = "9.0"
  s.watchos.deployment_target   = "2.0"

  s.source = { :git => "https://github.com/cx-org/CombineX.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/CombineX/**/*.swift"

end
