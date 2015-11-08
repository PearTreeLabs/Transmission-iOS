workspace 'Transmission'

target "TransmissionEngine-iOS" do
  platform :ios, "7.0"

  pod 'AFNetworking', '~> 1.3.3'
  pod 'AFHTTPRequestOperationLogger', '~> 1.0.0'
  pod 'MagicalRecord', '2.1'
  pod 'SVProgressHUD', '~> 1.0' # Remove this dependency, no UI in engine

end
  
target "Transmission-iOS" do
  platform :ios, "7.0"

  pod 'AFNetworking', '~> 1.3.3' # Remove this dependency, networking should come from the engine
  pod 'BPFoundation'
  pod 'FormatterKit', '~> 1.3.1'
  # pod 'MagicalRecord', '2.1'
  pod 'PTLURLProtocol'  # This should move to a test target
  # pod 'SVProgressHUD', '~> 1.0'

end

