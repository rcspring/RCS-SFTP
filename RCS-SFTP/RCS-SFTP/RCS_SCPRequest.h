//
//  RCSSCPRequest.h
//  RCSSCP
//
//  Created by Ryan Spring on 6/3/13.
//  Copyright (c) 2013 Ryan Spring. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCS_SCPRequestDelegate <NSObject>

-(void)RCS_SCPRequestFailedWithError:(NSError*)error;
-(void)RCS_SCPRequestDownloadCompleted:(NSData*)data;
-(void)RCS_SCPRequestUploadCompleted;

@end

@interface RCS_SCPRequest : NSObject

@property (nonatomic,weak) id<RCS_SCPRequestDelegate> delegate;

-(id)initWithHostname:(NSString*)hostname Username:(NSString*)username Password:(NSString*)password;
-(void)startDownload:(NSMutableData*)data fromPath:(NSString*)path;
-(void)startUpload:(NSData*)data toPath:(NSString*)path;

@end
