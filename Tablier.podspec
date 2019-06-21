Pod::Spec.new do |spec|
  spec.name = "Tablier"
  spec.version = "0.1.0"
  spec.summary = "A micro-framework for Table Driven Tests."
  spec.description = <<-DESC
    Tablier makes it easy to write Table Driven Tests in Swift.
  DESC

  spec.homepage = "https://github.com/akkyie/Tablier"
  spec.screenshots = "https://user-images.githubusercontent.com/1528813/59867231-9b508b00-93c8-11e9-8489-127d441c2a5b.png"

  spec.license      = "MIT"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Akio Yasui" => "akkyie01@gmail.com" }
  spec.social_media_url   = "https://twitter.com/akkyie"

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.9"
  spec.tvos.deployment_target = "9.0"
  spec.swift_version = "4.2"

  spec.source       = { :git => "https://github.com/akkyie/Tablier.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/Tablier"
  spec.requires_arc = true

  spec.framework  = "XCTest"
end
