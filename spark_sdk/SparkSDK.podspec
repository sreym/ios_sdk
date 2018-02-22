Pod::Spec.new do |s|
  s.name                  = 'SparkSDK'
  s.version               = '0.0.1'
  s.summary               = 'Spark features integration SDK'
  s.description           = 'Integrate favourite Spark features in your iOS apps'

  s.homepage              = 'https://holaspark.com'
  s.license               = { :type => 'holaspark.com' }
  s.author                = 'holaspark.com'
  s.source                = { :git => 'https://github.com/hola/spark_ios_sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files          = 'dist/spark_api.h'
  s.public_header_files   = 'dist/spark_api.h'
  s.vendored_libraries    = 'dist/libspark_sdk.a'
  s.libraries             = 'spark_sdk'
end
