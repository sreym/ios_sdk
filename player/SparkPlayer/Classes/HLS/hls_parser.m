//
//  hola_hls_parser.m
//  hola-cdn-sdk
//
//  Created by alexeym on 28/07/16.
//  Copyright © 2017 hola. All rights reserved.
//

#import "hls_parser.h"
// #import "hola_log.h"
//#import "cdn_loader_delegate.h"

@interface HolaHLSParser()
{

NSMutableArray<HolaHLSLevelInfo*>* levels;
NSMutableArray<NSString*>* media_urls;
NSURL* master;

}
@end

typedef NS_ENUM(int, HolaLevelState) {
   HolaLevelStateTop = 0,
   HolaLevelStateInner
};

typedef NS_ENUM(int, HolaHLSEntry) {
   HolaHLSEntryHeader = 0,
   HolaHLSEntryPlaylist,
   HolaHLSEntrySegment,
   HolaHLSEntryKey,
   HolaHLSEntryUrl,
   HolaHLSEntryOther
};

typedef NS_ENUM(int, HolaHLSError) {
   HolaHLSErrorHeader = 0,
   HolaHLSErrorBandwidth,
   HolaHLSErrorDuration,
   HolaHLSErrorObvious
};

@implementation HolaHLSParser

+(NSString*)getOriginSchemeName:(HolaScheme)scheme {
    switch (scheme) {
    case HolaSchemeHTTP:
        return @"http";
    case HolaSchemeHTTPS:
        return @"https";
    }
}

+(NSString*)getCDNSchemeName:(HolaScheme)scheme andType:(HolaCDNScheme)type {
    switch (scheme) {
    case HolaSchemeHTTP:
        switch (type) {
        case HolaCDNSchemeFetch:
            return @"hcdnf";
        case HolaCDNSchemeRedirect:
            return @"hcdnr";
        case HolaCDNSchemeKey:
            return @"hcdnk";
        }
    case HolaSchemeHTTPS:
        switch (type) {
        case HolaCDNSchemeFetch:
            return @"hcdnfs";
        case HolaCDNSchemeRedirect:
            return @"hcdnrs";
        case HolaCDNSchemeKey:
            return @"hcdnks";
        }
    }
}

+(HolaScheme)mapScheme:(NSString*)scheme {
    NSArray<NSString*>* http = [NSArray arrayWithObjects:@"http", @"hcdnf", @"hcdnr", @"hcdnk", nil];
    NSArray<NSString*>* https = [NSArray arrayWithObjects:@"https", @"hcdnfs", @"hcdnrs", @"hcdnks", nil];

    if ([http containsObject:scheme]) {
        return HolaSchemeHTTP;
    }

    if ([https containsObject:scheme]) {
        return HolaSchemeHTTPS;
    }

    return HolaSchemeHTTP;
}

+(HolaCDNScheme)mapCDNScheme:(NSURL*)url {
    NSArray<NSString*>* fetch = [NSArray arrayWithObjects:@"http", @"https", @"hcdnf", @"hcdnfs", nil];
    NSArray<NSString*>* redirect = [NSArray arrayWithObjects:@"hcdnr", @"hcdnrs", nil];
    NSArray<NSString*>* key = [NSArray arrayWithObjects:@"hcdnk", @"hcdnks", nil];

    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString* scheme = components.scheme;

    if ([fetch containsObject:scheme]) {
        return HolaCDNSchemeFetch;
    }

    if ([redirect containsObject:scheme]) {
        return HolaCDNSchemeRedirect;
    }

    if ([key containsObject:scheme]) {
        return HolaCDNSchemeKey;
    }

    return HolaCDNSchemeFetch;
}

+(HolaScheme)isCDNScheme:(NSURL*)url {
    NSArray<NSString*>* cdn = [NSArray arrayWithObjects:@"hcdnf", @"hcdnr", @"hcdnk", @"hcdnfs", @"hcdnrs", @"hcdnks", nil];

    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString* scheme = components.scheme;

    if ([cdn containsObject:scheme]) {
        return YES;
    }

    return NO;
}

+(NSURL*)applyCDNScheme:(NSURL*)url andType:(HolaCDNScheme)type {
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    HolaScheme scheme = [HolaHLSParser mapScheme:components.scheme];

    [components setScheme:[HolaHLSParser getCDNSchemeName:scheme andType:type]];

    return [components URL];
}

+(NSURL*)applyOriginScheme:(NSURL*)url {
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    HolaScheme scheme = [HolaHLSParser mapScheme:components.scheme];

    [components setScheme:[HolaHLSParser getOriginSchemeName:scheme]];

    return [components URL];
}

-(instancetype)init {
    self = [super init];

    if (self) {
        //_log = [HolaCDNLog logWithModule:@"Parser"];

        levels = [NSMutableArray new];
        media_urls = [NSMutableArray new];
    }

    return self;
}

-(void)dealloc {
    //[_log info:@"Dealloc"];
}

-(NSString*)getM3UAttribute:(NSString*)name fromLine:(NSString*)line {
    NSRange bwPos = [line rangeOfString:name];
    if (bwPos.location == NSNotFound) {
        return nil;
    }

    NSRange toEnd = NSMakeRange(bwPos.location, line.length-bwPos.location);
    NSRange bwEnd = [line rangeOfString:@"," options:NSCaseInsensitiveSearch range:toEnd];
    if (bwEnd.location == NSNotFound) {
        return [line substringFromIndex:bwPos.location+bwPos.length+1];
    }

    NSRange toBwEnd = NSMakeRange(bwPos.location+bwPos.length+1, bwEnd.location - (bwPos.location+bwPos.length+1));
    return [line substringWithRange:toBwEnd];
}

-(NSString*)parse:(NSString*)url andData:(NSString*)data withError:(NSError**)error {
    HolaHLSLevelInfo* level = [HolaHLSLevelInfo new];
    HolaHLSSegmentInfo* segment = [HolaHLSSegmentInfo new];

    HolaLevelState state = [self getUrlState:url];

    switch (state) {
    case HolaLevelStateTop:
        level = [HolaHLSLevelInfo new];
        break;
    case HolaLevelStateInner:
        level = [self getUrlLevel:url];
        break;
    }

    master = [NSURL URLWithString:url];

    if (![data hasPrefix:@"#EXTM3U"]) {
        *error = [NSError errorWithDomain:@"org.hola.hola-cdn-sdk" code:HolaHLSErrorHeader userInfo:nil];
        return nil;
    }

    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    NSMutableArray<NSString*>* lines = [[data componentsSeparatedByCharactersInSet:separator] mutableCopy];
    lines = [lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]].mutableCopy;
    for (int i = 0; i < lines.count; i+=1) {
        NSString* line = lines[i];

        HolaHLSEntry type = [self getEntryType:line];

        switch (type) {
        case HolaHLSEntryPlaylist:
        {
            NSString* bitrateString = [self getM3UAttribute:@"BANDWIDTH" fromLine:line];
            if (bitrateString == nil) {
                *error = [NSError errorWithDomain:@"org.hola.hola-cdn-sdk" code:HolaHLSErrorBandwidth userInfo:nil];
                return nil;
            }
            level.bitrate = [NSNumber numberWithInt:bitrateString.intValue];

            NSString* resolution = [self getM3UAttribute:@"RESOLUTION" fromLine:line];
            if (resolution != nil) {
                level.resolution = resolution;
            }
            break;
        }
        case HolaHLSEntrySegment:
        {
            if (state == HolaLevelStateTop) {
                state = HolaLevelStateInner;

                level.bitrate = [NSNumber numberWithInt:1];
                level.url = url;

                master = [NSURL URLWithString:url];
                [levels addObject:level];
            }

            NSRange toEnd = NSMakeRange(8, line.length-8);
            NSRange durEnd = [line rangeOfString:@"," options:NSCaseInsensitiveSearch range:toEnd];
            NSRange toDurEnd;
            if (durEnd.location == NSNotFound) {
                toDurEnd = toEnd;
            } else {
                toDurEnd = NSMakeRange(8, durEnd.location-8);
            }

            segment.duration = [NSNumber numberWithDouble:[line substringWithRange:toDurEnd].doubleValue];
            break;
        }
        case HolaHLSEntryUrl:
        {
            NSURL* levelUrl = [NSURL URLWithString:line relativeToURL:master];
            NSString* levelUrlString = levelUrl.absoluteString;

            NSURL* cdnLevelUrl;
            if (state == HolaLevelStateTop) {
                level.url = levelUrlString;
                [levels addObject:level];
                level = [HolaHLSLevelInfo new];
                cdnLevelUrl = [HolaHLSParser applyCDNScheme:levelUrl andType:HolaCDNSchemeFetch];
            } else {
                segment.url = levelUrlString;
                segment.level = level;
                [level.segments addObject:segment];
                [media_urls addObject:levelUrlString];
                segment = [HolaHLSSegmentInfo new];
                cdnLevelUrl = [HolaHLSParser applyCDNScheme:levelUrl andType:HolaCDNSchemeRedirect];
            }

            lines[i] = cdnLevelUrl.absoluteString;
            break;
        }
        case HolaHLSEntryKey:
        {
            NSRange keyPos = [line rangeOfString:@"URI="];
            if (keyPos.location == NSNotFound) {
                break;
            }

            NSRange keyPosEnd = NSMakeRange(keyPos.location+keyPos.length+1, line.length-(keyPos.location+keyPos.length+1));
            NSRange keyEnd = [line rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:keyPosEnd];
            if (keyEnd.location == NSNotFound) {
                break;
            }

            NSRange keyRange = NSMakeRange(keyPosEnd.location, keyEnd.location-keyPosEnd.location);
            NSString* keyUrlString = [line substringWithRange:keyRange];
            NSURL* keyUrl = [NSURL URLWithString:keyUrlString relativeToURL:master];

            NSURL* customKeyUrl = [HolaHLSParser applyCDNScheme:keyUrl andType:HolaCDNSchemeKey];
            lines[i] = [line stringByReplacingCharactersInRange:keyRange withString:customKeyUrl.absoluteString];
            break;
        }
        default:
            break;
        }
    }

    return [lines componentsJoinedByString:@"\n"];
}

-(NSDictionary*)getSegmentInfo:(NSString*)url {
    for (HolaHLSLevelInfo* level in levels) {
        for (HolaHLSSegmentInfo* segment in level.segments) {
            if ([segment.url hasSuffix:url]) {
                return [segment getInfo];
            }
        }
    }

    return [NSDictionary new];
}

-(BOOL)isMedia:(NSString*)url {
    return [media_urls containsObject:url];
}

-(NSDictionary*)getLevels {
    NSMutableDictionary* response = [NSMutableDictionary new];

    for (HolaHLSLevelInfo* level in levels) {
        if ([level.segments count] == 0) {
            continue;
        }

        response[level.url] = [level getInfo];
    }

    return response;
}

-(HolaLevelState)getUrlState:(NSString*)url {
    for (HolaHLSLevelInfo* level in levels) {
        if ([url hasSuffix:level.url]) {
            return HolaLevelStateInner;
        }
    }

    return HolaLevelStateTop;
}

-(HolaHLSLevelInfo*)getUrlLevel:(NSString*)url {
    for (HolaHLSLevelInfo* level in levels) {
        if ([url hasSuffix:level.url]) {
            return level;
        }

        for (HolaHLSSegmentInfo* segment in level.segments) {
            if ([url hasSuffix:segment.url]) {
                return level;
            }
        }
    }

    return [HolaHLSLevelInfo new];
}

-(HolaHLSEntry)getEntryType:(NSString*)entry {
    if ([entry hasPrefix:@"#EXTM3U"]) {
        return HolaHLSEntryHeader;
    }

    if ([entry hasPrefix:@"#EXT-X-STREAM-INF"]) {
        return HolaHLSEntryPlaylist;
    }

    if ([entry hasPrefix:@"#EXTINF"]) {
        return HolaHLSEntrySegment;
    }

    if ([entry hasPrefix:@"#EXT-X-KEY"]) {
        return HolaHLSEntryKey;
    }

    if ([entry length] == 0) {
        return HolaHLSEntryOther;
    }

    if (![entry hasPrefix:@"#"]) {
        return HolaHLSEntryUrl;
    }

    return HolaHLSEntryOther;
}

-(NSArray<HolaHLSLevelInfo*>*)getLevelsInfo {
    return levels;
}

@end
