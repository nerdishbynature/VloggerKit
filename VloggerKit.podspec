Pod::Spec.new do |s|
  s.name             = "VloggerKit"
  s.version          = "0.1.0"
  s.summary          = "A Swift API Client for GitHub and GitHub Enterprise"
  s.description      = <<-DESC
                        You are looking at a Swift API Client for YouTube.
                        This is very unofficial and not maintained by Google.
                        DESC
  s.homepage         = "https://github.com/nerdishbynature/vloggerkit"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Piet Brauer" => "piet@nerdishbynature.com" }
  s.source           = { :git => "https://github.com/nerdishbynature/vloggerkit.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/pietbrauer"
  s.module_name     = "VloggerKit"
  s.dependency "NBNRequestKit", "~> 0.3.0"
  s.requires_arc = true
  s.source_files = "VloggerKit/*.swift"
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
end
