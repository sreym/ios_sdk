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

@protocol SparkModule
-(void)start;
-(void)get_state;
-(void)set_state;
@end

// Protocol for communicating with Thumbnails feature
@protocol SparkThumbnailsDelegate
-(UIView*)get_thumbnail_container;
@end

// Protocol for communicating with SparkPlayer
@protocol SparkLibPlayerDelegate
@optional
-(id<SparkThumbnailsDelegate>)get_thumbnails_delegate;
@end

#endif /* spark_api_interface_h */
