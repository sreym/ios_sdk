# Spark Feature Library

The Spark feature library is a toolset for enriching and enhancing the user exeprience of your native apps with features like Video previews, floating player, watch next suggestions, etc - see the [Full available feature set](https://holaspark.com)

The library also includes:
- VPAID addon
- [Control Panel](https://holaspark.com/?need_login=1) configuration of all features
- [External APIs](https://docs.google.com/document/d/1Rh8TWTDyBdkLnnr4RVnRNZ1bSltT5NIn5dcNpdxxdQE/edit#heading=h.uo3s9j23kuim) for manual feature control
- Tools for generating [Rich Notifications](https://docs.google.com/document/d/1Rh8TWTDyBdkLnnr4RVnRNZ1bSltT5NIn5dcNpdxxdQE/#heading=h.6i9oua7b4xma) with video previews

**Requirements**
- [Registering with Spark](https://holaspark.com) to receive a customer id that will be used to activate the library

Note: An [Android version](https://github.com/hola/spark_android_sdk) is also available.

## Installation
- Using [CocoaPods](https://cocoapods.org):
Add the following line to your Podfile:
```
pod 'SparkLib', '~> 1.1'
```

- Manual installation:

-- Copy **libspark_sdk.a** and **SparkAPI.h** to your project's folder, e.g.:
```
<myapproot>
  <myapp>
  <myapp>.xcodeproj
  spark_sdk
    libspark_sdk.a
    SparkAPI.h
```
-- Add the new folder to XCode project\
-- Open your app configuration settings\
-- Switch to "Build Phases" > "Link Binary With Libraries" > "+" > "Add other"\
-- Select libspark_sdk.a

## Usage

Initialize Spark SDK with your acquired customer id:
```objc
// Objective-C example
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
    SparkAPI *api = [SparkAPI getAPI:@"<customer_id>"];
    ...
}
```
```swift
// Swift example
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
{
    let api = SparkAPI.getAPI("<customer_id>")
    ...
}
```

NOTE: providing customer id is required only for the first provisioning call, in all subsequent calls from all around your project you can omit it and call without it:
```objc
// Objective-C example
- (IBAction)onSomeButtonClicked:(UIButton *)sender
{
    SparkAPI *api = [SparkAPI getAPI:nil];
    ...
}
```
```objc
// Swift example
@IBAction func onSomeButtonClicked(sender: UIButton){
{
    let api = SparkAPI.getAPI(nil);
    ...
}
```

If you have any questions, email us at support@holaspark.com
