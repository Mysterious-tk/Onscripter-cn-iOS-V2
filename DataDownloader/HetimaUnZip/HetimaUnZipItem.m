//
//  HetimaUnZipItem.m
//  HetimaUnZip
//
//  Created by hetima on 05.3.26.
//  Copyright 2005 Hetima Computer. All rights reserved.
//


#import "HetimaUnZip.h"

#import "unzip.h"

@interface HetimaUnZipItem(private)
- (NSData*)_extractData;
- (int)_extractDataBuff:(void*)buf size:(unsigned)size;
@end


@implementation HetimaUnZipItem

-(id)initWithContainer:(id)container rawName:(char*)rawName zipInfo:(void*)info
{
	if([super init]){
        unz_file_info*  file_info=(unz_file_info*)info;
		_container=container;
        _rawName=malloc(strlen(rawName) +1);
        strcpy(_rawName, rawName);
        
        _compressedSize=file_info->compressed_size;
        _uncompressedSize=file_info->uncompressed_size;
        _dosDate=file_info->dosDate;
        if ((file_info->flag & 1) != 0){
            _crypted=YES;
        }

		return self;
	}else{
		return NULL;
	}

}

- (void)dealloc {
//	NSLog(@"HetimaUnZipItem dealloc");
    [_path release];
    [_data release];
    if(_rawName)free(_rawName);

	[super dealloc];
}

- (NSString *)description
{
    return [self path];
}


- (NSData*)data
{

    if([_container keepData]){
        if(_data==nil){
            _data=[[self _extractData]retain];
        }
    }else{
        return [self _extractData];
    }
    return _data;
}

- (void)setData:(NSData*)inData
{
    if(_data != inData){
        [_data autorelease];
        _data=[inData retain];
    }
}

- (void)fireDidExtractDataOfLength:(NSNumber *)length {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (_delegate != nil)
		[_delegate item:self didExtractDataOfLength:[length intValue]];
	[pool release];
}

- (BOOL)extractTo:(NSString *)path delegate:(id<HetimaUnZipItemDelegate, NSObject>)delegate
{
#define WRITEBUFFERSIZE (8192*8)
	_delegate = delegate;
    unzFile uf=[_container _ref];
    int err = UNZ_OK;
    if (unzLocateFile(uf, _rawName, 1) != UNZ_OK){
        return NO;
    }
	
    const char* password=NULL;
    void* buf;
    uInt size_buf;
	
    unz_file_info file_info;
    err = unzGetCurrentFileInfo(uf, &file_info, NULL, 0, NULL, 0, NULL, 0);
	
    if (err!=UNZ_OK){
        //printf("error %d with zipfile in unzGetCurrentFileInfo\n",err);
        return NO;
    }
    
    if(file_info.uncompressed_size <=0)return NO;
	
    if ((file_info.flag & 1) != 0){
        password=[_container _rawPassword];
    }
	
    size_buf = WRITEBUFFERSIZE;
    buf = (void*)malloc(size_buf);
    if (buf==NULL){
        return NO;
    }
	
    [_container loadDataLock];  //lock --------------------------
	BOOL result = NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil];
	}
	NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:path];
    
    err = unzOpenCurrentFilePassword(uf,password);
    if (err!=UNZ_OK){
        //printf("error %d with zipfile in unzOpenCurrentFilePassword\n",err);
    }else{
		
        //printf(" extracting: %s\n",write_filename);
        do{
            err = unzReadCurrentFile(uf,buf,size_buf);
            if(err<0){
                break;
            }
            if(err>0) {
				[file writeData:[NSData dataWithBytes:buf length:err]];
				[self performSelectorOnMainThread:@selector(fireDidExtractDataOfLength:) withObject:[NSNumber numberWithInt:err] waitUntilDone:NO];
			}
        }while (err>0);
		if (err == 0) result = YES;
    }
	
	/*
	 if (err==UNZ_OK){
	 _uncompressedSize=[result length];
	 }
	 */
	
	[file closeFile];
    unzCloseCurrentFile(uf);
    free(buf);
    [_container loadDataUnlock];    //unlock -------------------
	
    return result;
}


- (NSData*)headDataForSize:(unsigned)size
{
    NSData* result=nil;
    unsigned rSize=0;
    void* bytes=[self headBytesProposedSize:size readSize:&rSize];
    if(rSize>0){
        result=[NSData dataWithBytesNoCopy:bytes length:rSize];
        if(bytes && result==nil) free(bytes);
    }
    return result;
}

- (void*)headBytesProposedSize:(unsigned)pSize readSize:(unsigned*)rSize
{
    void* bytes=nil;
    if(pSize > 0 && pSize < 1024*1024*32){ //いちおサイズ制限
        bytes=malloc(pSize);
        if(bytes){
            int readSize=[self _extractDataBuff:bytes size:pSize];
            if(rSize) *rSize=readSize;
        }
    }
    return bytes;
}

#pragma mark -

-(NSString*)path
{
    if(_path==nil){
        _path=[[NSString alloc]initWithBytes:_rawName length:strlen(_rawName) encoding:[_container encoding]];
    }
    return _path;
}

- (void)setPath:(NSString*)inStr
{
    if(_path != inStr){
        [_path autorelease];
        _path=[inStr retain];
    }
}

- (unsigned)compressedSize
{
    return _compressedSize;
}

- (unsigned)uncompressedSize
{
    return _uncompressedSize;
}

- (NSDate*)modificationDate
{
    NSDate* resultDate=nil;
    if(_dosDate > 0){
    
    }
    
    return resultDate;
}

- (id)container
{
    return _container;
}

@end






@implementation HetimaUnZipItem(private)

- (NSData*)_extractData
{
#define WRITEBUFFERSIZE (8192*8)
    unzFile uf=[_container _ref];
    int err = UNZ_OK;
    if (unzLocateFile(uf, _rawName, 1) != UNZ_OK){
        return nil;
    }

    const char* password=NULL;
    void* buf;
    uInt size_buf;

    unz_file_info file_info;
    err = unzGetCurrentFileInfo(uf, &file_info, NULL, 0, NULL, 0, NULL, 0);

    if (err!=UNZ_OK){
        //printf("error %d with zipfile in unzGetCurrentFileInfo\n",err);
        return nil;
    }
    
    if(file_info.uncompressed_size <=0)return nil;

    if ((file_info.flag & 1) != 0){
        password=[_container _rawPassword];
    }

    size_buf = WRITEBUFFERSIZE;
    buf = (void*)malloc(size_buf);
    if (buf==NULL){
        return nil;
    }

    [_container loadDataLock];  //lock --------------------------
    NSMutableData*  result=nil;
    
    err = unzOpenCurrentFilePassword(uf,password);
    if (err!=UNZ_OK){
        //printf("error %d with zipfile in unzOpenCurrentFilePassword\n",err);
    }else{
        result=[NSMutableData dataWithCapacity:file_info.uncompressed_size +1];

        //printf(" extracting: %s\n",write_filename);
        do{
            err = unzReadCurrentFile(uf,buf,size_buf);
            if(err<0){
                break;
            }
            if(err>0)    [result appendBytes:buf length:err];

        }while (err>0);
    }

/*
    if (err==UNZ_OK){
        _uncompressedSize=[result length];
    }
*/

    unzCloseCurrentFile(uf);
    free(buf);
    [_container loadDataUnlock];    //unlock -------------------

    return result;

}

- (int)_extractDataBuff:(void*)buf size:(unsigned)size
{
    if (buf==NULL){
        return (int)nil;
    }

    unzFile uf=[_container _ref];
    int err = UNZ_OK;
    if (unzLocateFile(uf, _rawName, 1) != UNZ_OK){
        return (int)nil;
    }

    const char* password=NULL;
    unz_file_info file_info;
    err = unzGetCurrentFileInfo(uf, &file_info, NULL, 0, NULL, 0, NULL, 0);

    if (err!=UNZ_OK){
        //printf("error %d with zipfile in unzGetCurrentFileInfo\n",err);
        return -1;
    }

    if(file_info.uncompressed_size <=0)return 0;

    [_container loadDataLock];  //lock -------------------------
    int result = 0;
    
    if ((file_info.flag & 1) != 0){
        password=[_container _rawPassword];
    }

    err = unzOpenCurrentFilePassword(uf,password);
    if (err!=UNZ_OK){
        //printf("error %d with zipfile in unzOpenCurrentFilePassword\n",err);
    }else{
        //printf(" extracting: %s\n",write_filename);
        result = unzReadCurrentFile(uf, buf, size);
    }
    unzCloseCurrentFile(uf);

    [_container loadDataUnlock];    //unlock -------------------

    return result;
}

@end
