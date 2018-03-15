source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, "10.0"
use_frameworks!

def shared_pods
    pod 'Appirater'
    pod 'Crashlytics'
    pod 'Fabric'
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FacebookShare', :git => 'https://github.com/1amageek/facebook-sdk-swift'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'FirebaseUI/Storage'
    pod 'GoogleSignIn'
    pod 'hpple'
    pod 'MBProgressHUD'
    pod 'MMDrawerController'
    pod 'MMDrawerController+Storyboard'
    pod 'Networking'
    pod 'ReachabilitySwift'
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
    pod 'TwitterKit'
    pod 'TwitterCore'
    pod 'WhirlyGlobe'
    pod 'WhirlyGlobeResources'
end

target "Flag Ceremony" do
    shared_pods
end

target "Flag CeremonyTests" do
    shared_pods
end

target "Flag CeremonyUITests" do
    shared_pods
end
