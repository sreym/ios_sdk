//
//  xmlhttprequest.h
//  SparkLib
//
//  https://github.com/Lukas-Stuehrk/XMLHTTPRequest
//
//  Created by alexeym on 04/08/16.
//  Copyright © 2017 hola. All rights reserved.
//
//  NOTE: This file copied from HolaCDN ios_sdk with minimum modifications.
//  Entire loader submodule will be reused by HolaCDN once added to SparkLib.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol XMLHttpRequestExport <JSExport>

@property (nonatomic) NSString* responseType;
@property (nonatomic) NSString* responseText;
@property (nonatomic) NSString* response;
@property (nonatomic) JSValue* onreadystatechange;
@property (nonatomic) NSNumber* readyState;
@property (nonatomic) JSValue* onload;
@property (nonatomic) JSValue* onprogress;
@property (nonatomic) JSValue* onerror;
@property (nonatomic) NSNumber* status;

-(void)open:(NSString*)httpMethod :(NSString*)url :(bool)async;
-(void)abort;
-(void)send:(id)data;
-(void)setRequestHeader:(NSString*)name :(NSString*)value;
-(NSString*)getAllResponseHeaders;
-(NSString*)getReponseHeader:(NSString*)name;

@end

@interface XMLHttpRequest: NSObject <XMLHttpRequestExport>

- (instancetype)initWithURLSession: (NSURLSession *)urlSession;
- (void)extend:(id)jsContext;

@end
