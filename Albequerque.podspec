Pod::Spec.new do |s|
  s.name         = "Albequerque"
  s.version      = "0.0.1"
  s.summary      = "An iOS library to provide access to Jeppesen Journey Planner."
  s.homepage     = "http://github.com/BakedSoftware/Albequerque"

  s.license      = 'MIT'
  s.author       = { "Kayle Gishen" => "Kayle@bakedsoftware.com" }
  s.source       = { :git => "https://github.com/BakedSoftware/Albequerque.git", :tag => "0.0.1" }

  s.platform     = :ios, '5.0'
  s.source_files = 'Albequerque/**/*.{h,m}'
  s.frameworks = 'CoreLocation', 'UIKit', 'Foundation'
  s.requires_arc = true

  s.dependency 'JSONKit'
end
