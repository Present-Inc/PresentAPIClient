Pod::Spec.new do |s|
  s.name        = "SwiftyJSON"
  s.version     = "2.1.1"
  s.summary     = "SwiftyJSON makes it easy to deal with JSON data in Swift"
  s.homepage    = "https://github.com/SwiftyJSON/SwiftyJSON"
  s.license     = { :type => "MIT" }
  s.authors     = { "lingoer" => "lingoerer@gmail.com", "tangplin" => "tangplin@gmail.com" }

  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "7.0"
  s.source   = { :git => "https://github.com/SwiftyJSON/SwiftyJSON.git", :tag => "2.1.1" }
  s.source_files = "Source/*.swift"
end
