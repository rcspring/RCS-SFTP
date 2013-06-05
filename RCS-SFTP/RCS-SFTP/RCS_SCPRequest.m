//
//  RCSSCPRequest.m
//  RCSSCP
//
//  Created by Ryan Spring on 6/3/13.
//  Copyright (c) 2013 Ryan Spring. All rights reserved.
//

#import "RCS_SCPRequest.h"
#import "RCS_SCPTransferCtx.h"

#import "libssh2.h"
#import "libssh2_config.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import <netdb.h>

#define DISPATCH_QUEUE_NAME @"RCSSCPRequest-%d"
#define RCS_SCP_REQUEST_DIR_DOWN 1
#define RCS_SCP_REQUEST_DIR_UP 2
#define TRANSFER_BUFFER_SIZE 1024

@interface RCS_SCPRequest ()

@property (nonatomic,strong) NSString* hostname;
@property (nonatomic,strong) NSString* username;
@property (nonatomic,strong) NSString* pwd;

@end


@implementation RCS_SCPRequest


-(id)initWithHostname:(NSString*)hostname Username:(NSString*)username Password:(NSString*)password {
    self = [super init];
    
    if(self) {
        self.hostname = hostname;
        self.username = username;
        self.pwd = password;
    }
    
    return self;
}

-(id)init {
    
    NSException* unsupported = [NSException exceptionWithName:@"Unsupported Method" reason:@"Please use custom init" userInfo:nil];
    @throw unsupported;
    
    return self;
    
}


-(void)startDownload:(NSMutableData*)data fromPath:(NSString*)path {
    
    RCSSCPTransferCtx* ctx = [[RCSSCPTransferCtx alloc]init];
    ctx.data = data;
    ctx.path = path;
    ctx.direction = RCS_SCP_REQUEST_DIR_DOWN;
    
    if(self.delegate != nil) {
        [self startTransfer:ctx];
    }
    
    
}

-(void)startUpload:(NSData*)data toPath:(NSString*)path {
    RCSSCPTransferCtx* ctx = [[RCSSCPTransferCtx alloc]init];
    ctx.data = (NSMutableData*)data;
    ctx.path = path;
    ctx.direction = RCS_SCP_REQUEST_DIR_UP;
    
    if(self.delegate != nil) {
        [self startTransfer:ctx];
    }
    
    
}


#pragma mark - Backend Methods
-(void)performTransfer:(RCSSCPTransferCtx*)ctx {
    int rc;
    unsigned long hostaddr;
    struct sockaddr_in sin;
    
    rc = libssh2_init (0);
    
    if (rc != 0) {
        NSLog(@"libssh2 initialization failed (%d)", rc);
        return;
    }
    
    
    hostaddr = inet_addr([self.hostname cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSLog(@"Connect %@",self.hostname);
    
    ctx.sock = socket(AF_INET, SOCK_STREAM, 0);
    
    NSLog(@"Start connect");
    
    
    sin.sin_family = AF_INET;
    sin.sin_port = htons(22);
    sin.sin_addr.s_addr = hostaddr;
    if (connect(ctx.sock, (struct sockaddr*)(&sin),
                sizeof(struct sockaddr_in)) != 0) {
        
        char buff[80];
        NSLog(@"failed to connect to %s",inet_ntop(sin.sin_family, &sin.sin_addr, buff, 80));
        return;
    }
    
    NSLog(@"End connect");
    
    
    ctx.session = libssh2_session_init();
    
    if(!ctx.session) {
        return;
    }
    NSLog(@"Shandshake");
    rc = libssh2_session_handshake(ctx.session, ctx.sock);
   
    if(rc) {
        NSLog(@"Failure establishing SSH session:  %d", rc);
        return;
    }
     NSLog(@"Ehandshake");
    int retVal = libssh2_userauth_password(ctx.session, [self.username cStringUsingEncoding:NSUTF8StringEncoding],[self.pwd cStringUsingEncoding:NSUTF8StringEncoding]);
    
    
    NSLog(@"EPWD %@:%@",self.username,self.pwd);
    if (retVal) {
        NSLog(@"Fail auth %d",retVal);
        [self callDelegateWithError:@"Authentication Failed" andCtx:ctx];
        [self shutdownSession:ctx];
        return;
    }
    
    if(ctx.direction == RCS_SCP_REQUEST_DIR_DOWN) {
        [self handleDownload:ctx];
    }
    
    if(ctx.direction == RCS_SCP_REQUEST_DIR_UP) {
        NSLog(@"Startin up");
        [self handleUpload:ctx];
    }
    

}


-(void)handleDownload:(RCSSCPTransferCtx*)ctx {
    struct stat fileinfo;
    off_t got = 0;
    off_t rc;
    
    ctx.channel = libssh2_scp_recv(ctx.session, [ctx.path cStringUsingEncoding:NSUTF8StringEncoding], &fileinfo);
    
    if (!ctx.channel) {
        [self callDelegateWithError:@"Cannot start download" andCtx:ctx];
        [self shutdownSession:ctx];
        return;
    }
    
    
    while(got < fileinfo.st_size) {
        char buff[TRANSFER_BUFFER_SIZE];
        
        rc = libssh2_channel_read(ctx.channel, buff, TRANSFER_BUFFER_SIZE);
        [ctx.data appendBytes:buff length:rc];
        
        got += rc;
    }
    
    [self callDelegateWithDownloadResult:ctx.data andCtx:ctx];
    
    [self shutdownSession:ctx];
}

-(void)handleUpload:(RCSSCPTransferCtx*)ctx {
  
    off_t sent = 0;
    off_t wc;
    
    NSLog(@"Start");
    ctx.channel = libssh2_scp_send(ctx.session, [ctx.path cStringUsingEncoding:NSUTF8StringEncoding], S_IRWXU, ctx.data.length);
    
    NSLog(@"End");
    
    
    if (!ctx.channel) {
        [self callDelegateWithError:@"Cannot start upload" andCtx:ctx];
        [self shutdownSession:ctx];
        return;
    }
    
    
    while(sent < ctx.data.length) {
        char buff[TRANSFER_BUFFER_SIZE];
        
        
        NSLog(@"Wirte buff");
        NSUInteger length = ctx.data.length - sent > TRANSFER_BUFFER_SIZE ? TRANSFER_BUFFER_SIZE : ctx.data.length - sent;
        NSRange readRange = NSMakeRange(sent, length);
        
        [ctx.data getBytes:buff range:readRange];
        
        wc = libssh2_channel_write(ctx.channel, buff, length);
        
        sent += wc;
    }

    [self callDelegateWithUploadCtx:ctx];
    [self shutdownSession:ctx];

}


-(void)shutdownSession:(RCSSCPTransferCtx*)ctx {
    libssh2_session_disconnect(ctx.session, "Normal Shutdown, Thank you for playing");
    libssh2_session_free(ctx.session);
    ctx.session = nil;
    
    close(ctx.sock);
    
    return;
}





#pragma mark - Backend Methods
-(void)startTransfer:(RCSSCPTransferCtx*)ctx {
    ctx.mainQueue = dispatch_get_main_queue();
    
    srand(time(NULL));
    int sockNum = rand();
    NSString* queueName = [NSString stringWithFormat:DISPATCH_QUEUE_NAME,sockNum];
    
    ctx.sockQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    
    void (^transfer)(void) = ^{
        [self performTransfer:ctx];
    };
    
    dispatch_async(ctx.sockQueue, transfer);
}


#pragma mark - Callback Handlers

-(void)callDelegateWithError:(NSString*)errorText andCtx:(RCSSCPTransferCtx*)ctx {
    
    NSError* customError = [NSError errorWithDomain:errorText code:1 userInfo:nil];

    void (^errorHandler)(void) = ^{
        if([self.delegate respondsToSelector:@selector(RCS_SCPRequestFailedWithError:)]) {
            [self.delegate RCS_SCPRequestFailedWithError:customError];
        }
        else {
            NSLog(@"DOesn't respond");
        }
    };
    
    dispatch_async(ctx.mainQueue, errorHandler);
    
    
}

-(void)callDelegateWithDownloadResult:(NSData*)data andCtx:(RCSSCPTransferCtx*)ctx {
    void (^callbackHandler)(void) = ^{
        if([self.delegate respondsToSelector:@selector(RCS_SCPRequestDownloadCompleted:)]) {
            [self.delegate RCS_SCPRequestDownloadCompleted:data];
        }
    };
    
    dispatch_async(ctx.mainQueue, callbackHandler);

}

-(void)callDelegateWithUploadCtx:(RCSSCPTransferCtx*)ctx {
    void (^callbackHandler)(void) = ^{
        if([self.delegate respondsToSelector:@selector(RCS_SCPRequestUploadCompleted)]) {
            [self.delegate RCS_SCPRequestUploadCompleted];
        }
    };
    
    dispatch_async(ctx.mainQueue, callbackHandler);
    
}



@end
