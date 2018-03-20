Pod::Spec.new do |s|
  s.name                  = 'SparkLib'
  s.version               = '1.3.0'
  s.summary               = 'SparkLib integration SDK'
  s.description           = 'Integrate favorite SparkLib features in your iOS apps'

  s.homepage              = 'https://holaspark.com'
  s.license               = { :type => 'holaspark.com' }
  s.author                = 'holaspark.com'
  s.source                = { :git => 'https://github.com/hola/spark_ios_sdk.git', :tag => 'v1.88.213' }

  s.ios.deployment_target = '8.0'

  s.vendored_frameworks    = 'lib/dist/SparkLib.framework'
end
