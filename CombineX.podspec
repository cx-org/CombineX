Pod::Spec.new do |s|

  s.name         = "CombineX"
  s.version      = "0.0.1"
  s.summary      = "CombineX is an open source implementation for Apple's Combine specs."
  s.homepage     = "https://github.com/luoxiu/CombineX"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Quentin Jin" => "jianstm@gmail.com" }

  s.source       = { :git => "https://github.com/luoxiu/CombineX.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/CombineX/**/*.swift"

  s.swift_versions = ['5.0']

end
