Pod::Spec.new do |s|
  s.name         = "Swell"
  s.version      = "0.5.0"
  s.summary      = "A logging utility for Swift and Objective C"

  s.description  = <<-DESC
                   A miminal but flexible logging utility. Supports multiple loggers. Each logger can have their own log level. 
                   Loggers can be configured through a plist file.
                   DESC

  s.homepage     = "https://github.com/hubertr/Swell"
  s.license      = { :type => "Apache License", :file => "LICENSE" }
  s.author             = { "Hubert Rabago" => "undetected2@gmail.com" }

  s.platform     = :ios, "7.0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/hubertr/Swell.git", :tag => s.version }

  s.source_files  = "Swell/*.swift"
  s.framework  = "Foundation"
  s.requires_arc = true
end
