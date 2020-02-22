Pod::Spec.new do |s|

  s.name         = "CombineX"
  s.version      = "0.2.0"
  s.summary      = "Open source implementation for Apple's Combine."
  s.homepage     = "https://github.com/cx-org/CombineX"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Quentin Jin" => "luoxiustm@gmail.com", "ddddxxx" => "dengxiang2010@gmail.com" }

  s.swift_versions              = ['5.0']
  s.osx.deployment_target       = "10.10"
  s.ios.deployment_target       = "8.0"
  s.tvos.deployment_target      = "9.0"
  s.watchos.deployment_target   = "2.0"

  s.source = { :git => "https://github.com/cx-org/CombineX.git", :tag => "#{s.version}" }

  s.subspec "CXLibc" do |ss|
    ss.source_files = "Sources/CXLibc/**/*.swift"
  end

  s.subspec "CXUtility" do |ss|
    ss.source_files = "Sources/CXUtility/**/*.swift"
  end

  s.subspec "CXNamespace" do |ss|
    ss.source_files = "Sources/CXNamespace/**/*.swift"
  end

  s.subspec "Main" do |ss|
    ss.source_files = "Sources/CombineX/**/*.swift"
    ss.dependency "CombineX/CXLibc"
    ss.dependency "CombineX/CXUtility"
    ss.dependency "CombineX/CXNamespace"
    # ss.dependency "Runtime"
  end

  s.subspec "CXFoundation" do |ss|
    ss.source_files = "Sources/CXFoundation/**/*.swift"
    ss.dependency "CombineX/CXUtility"
    ss.dependency "CombineX/CXNamespace"
    ss.dependency "CombineX/Main"
  end

  s.default_subspec = 'Main'

end
