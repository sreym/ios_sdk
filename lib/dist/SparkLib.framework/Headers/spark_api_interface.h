//
//  spark_api_interface.h
//  spark_sdk
//
//  Created by alexeym on 28/03/2018.
//  Copyright © 2018 WebSpark. All rights reserved.
//

#ifndef spark_api_interface_h
#define spark_api_interface_h

#import <UIKit/UIKit.h>

// Protocol for communicating with Thumbnails feature
@protocol SparkThumbnailsDelegate
-(UIView*)get_thumbnail_container;
@end

#endif /* spark_api_interface_h */
