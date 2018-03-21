//
//  hola_hls_parser.h
//  hola-cdn-sdk
//
//  Created by alexeym on 28/07/16.
//  Copyright © 2017 hola. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "hola_log.h"
#import "hls_segment_info.h"
#import "hls_level_info.h"

typedef NS_ENUM(int, HolaCDNScheme) {
   HolaCDNSchemeRedirect = 0,
   HolaCDNSchemeFetch,
   HolaCDNSchemeKey
};

typedef NS_ENUM(int, HolaScheme) {
   HolaSchemeHTTP = 0,
   HolaSchemeHTTPS
};

typedef NS_ENUM(int, HolaCDNErrorCode) {
   HolaCDNErrorCodeMissing = 0,
   HolaCDNErrorCodeUnprocessable = 0,
   HolaCDNErrorCodeBadRequest = 0,
   HolaCDNErrorCodeCancelled = 0
};

@interface HolaHLSParser : NSObject

+(HolaCDNScheme)mapCDNScheme:(NSURL*)url;
+(HolaScheme)mapScheme:(NSString*)scheme;
+(NSURL*)applyCDNScheme:(NSURL*)url andType:(HolaCDNScheme)type;
+(NSURL*)applyOriginScheme:(NSURL*)url;

//@property(readonly) HolaCDNLog* log;

-(NSString*)parse:(NSString*)url andData:(NSString*)data withError:(NSError**)error;
-(NSDictionary*)getSegmentInfo:(NSString*)url;
-(BOOL)isMedia:(NSString*)url;
-(NSArray<HolaHLSLevelInfo*>*)getLevelsInfo;

@end
