Pod::Spec.new do |s|
  s.name                  = 'SparkLib'
  s.version               = '1.1.5'
  s.summary               = 'SparkLib integration SDK'
  s.description           = 'Integrate favorite SparkLib features in your iOS apps'

  s.homepage              = 'https://holaspark.com'
  s.license               = { :type => 'holaspark.com' }
  s.author                = 'holaspark.com'
  s.source                = { :git => 'https://github.com/hola/spark_ios_sdk.git', :tag => 'v1.86.774' }

  s.ios.deployment_target = '8.0'

  s.source_files          = 'lib/dist/SparkAPI.h'
  s.public_header_files   = 'lib/dist/SparkAPI.h'
  s.vendored_libraries    = 'lib/dist/libspark_sdk.a'
  s.libraries             = 'spark_sdk'
end
