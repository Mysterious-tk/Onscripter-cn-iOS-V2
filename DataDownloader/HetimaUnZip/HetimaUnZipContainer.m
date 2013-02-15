

#import "unzip.h"
#import "HetimaUnZip.h"

//自動判別用 from KEdit for Mac OS X (KTextUtils.h)
typedef enum { NUL_char = 0,
	LF_char = 10,  CR_char = 13,
	ESC_char = 27, SS2_char = 142
} KCharacterCode;

typedef enum {
	NEW_type = 1,
	OLD_type,
	NEC_type,
	EUC_type,
	SJIS_type,
	EUCORSJIS_type,
	UTF8_type,
	UTF16_type,
	ASCII_type
} KDetectedCharacterCodeType;




@interface HetimaUnZipContainer(private)
- (NSMutableArray*)_zipContentsArray;
+ (NSStringEncoding)_relyKTextUtils_detectCharacterCodeType:(NSData*)data;
+ (int)_relyKTextUtils_getCodeLength:(const char*)text;
@end


@implementation HetimaUnZipContainer

+ (id)unZipContainerWithZipFile:(NSString*)file;
{
    return [[[HetimaUnZipContainer alloc]initWithZipFile:file]autorelease];
}

+ (id)unZipContainerWithZipFile:(NSString*)file listOnlyRealFile:(BOOL)inBool extensionFilter:(NSArray*)inArray
{
    HetimaUnZipContainer*   container=[[[HetimaUnZipContainer alloc]initWithZipFile:file]autorelease];
    if(container){
        [container setListOnlyRealFile:inBool];
        [container setExtensionFilter:inArray];
    }
    return container;
}


- (id)initWithZipFile:(NSString*)file
{
	if([super init]){
        _loadDataLock=[[NSLock alloc]init];
        _itemClass=[HetimaUnZipItem class];
        _listOnlyRealFile=NO;
        _keepData=YES;
		_file=[file retain];
        uf=unzOpen([_file fileSystemRepresentation]);
		return self;
	}else{
		return NULL;
	}
}


- (void)dealloc {
//	NSLog(@"HetimaUnZipContainer dealloc");

    unzClose(uf);
    [_loadDataLock release];
	[_file release];
    [_extensionFilter release];
    [_password release];
    [_contents release];
    if(_rawPassword) free(_rawPassword);

	[super dealloc];
}
- (unzFile)_ref
{
    return uf;
}

- (void)loadDataLock
{
    [_loadDataLock lock];
}

- (void)loadDataUnlock
{
    [_loadDataLock unlock];
}

#pragma mark -

- (void)setListOnlyRealFile:(BOOL)inBool
{
    if(_listOnlyRealFile!=inBool){
        _listOnlyRealFile=inBool;
    }
}

- (BOOL)listOnlyRealFile
{
    return _listOnlyRealFile;
}

- (NSArray*)extensionFilter
{
    return _extensionFilter;
}

- (void)setExtensionFilter:(NSArray*)inArray
{
    if(_extensionFilter != inArray){
        [_extensionFilter autorelease];
        _extensionFilter=[inArray retain];
    }
}

- (void)setItemClass:(Class)aClass
{
    //itemClassとして使えるかチェックするべきだが
    _itemClass=aClass;
}
- (Class)itemClass
{
    return _itemClass;
}

#pragma mark -


- (NSMutableArray*)contents
{
    if(_contents==nil){
        _contents=[[self _zipContentsArray]retain];
    }
    return _contents;
}

- (BOOL)crypted
{
    //load contents
    [self contents];
    return _crypted;

}

- (NSStringEncoding)encoding
{
    //load contents
    [self contents];
    return _encoding;
}
- (void)setEncoding:(NSStringEncoding)inEncoding
{
    //load contents
    [self contents];
    if(_encoding!=inEncoding){
        _encoding=inEncoding;
        //itemの文字列を破棄
        if([_contents count]>0)[_contents makeObjectsPerformSelector:@selector(setPath:) withObject:nil];
    }
}


- (BOOL)keepData
{
    return _keepData;
}

- (void)setKeepData:(BOOL)inBool
{
    if(_keepData!=inBool){
        _keepData=inBool;
        //既にkeepDataしてたら破棄するか？
        //if(!_keepData && [_contents count]>0){
        //    [_contents makeObjectsPerformSelector:@selector(setData:) withObject:nil];
        //}
    }
}

- (NSString*)password
{
    return _password;
}

- (void)setPassword:(NSString*)newPassword
{

    if(_password != newPassword){
        [_password autorelease];
        _password=[newPassword retain];
        if(_rawPassword){
            free(_rawPassword);
            _rawPassword=nil;
        }
        //itemのデータを破棄
        if([_contents count]>0)[_contents makeObjectsPerformSelector:@selector(setData:) withObject:nil];
        
    }
}

- (const char*)_rawPassword
{
    if(_password==nil || [_password length]<=0){
        return NULL;
    }
    if(_rawPassword==nil){
/*
        const char *pass=CFStringGetCStringPtr((CFStringRef)_password, CFStringConvertNSStringEncodingToEncoding(_encoding));
        if(pass==nil){
            return [_password lossyCString];
        }
        return pass;
*/
        //ファイルパスはUTF-8なのにパスワードはSJISとかあるし
        //とりあえずSJIS固定で
        NSData* aData=[_password dataUsingEncoding:/*_encoding*/NSShiftJISStringEncoding allowLossyConversion:YES];
        if(aData==nil){
			return [_password cStringUsingEncoding:NSShiftJISStringEncoding];
        }else{
            unsigned length=[aData length];
            _rawPassword=malloc(length+1);
            if(_rawPassword) [aData getBytes:_rawPassword length:length];
        }
    }
    
    return _rawPassword;
}

@end


@implementation HetimaUnZipContainer(private)


- (NSMutableArray*)_zipContentsArray
{
    NSMutableArray* _array;
    
    //for detect encoding
    int     isMacOSX=0;
    int     isWindows=0;
    NSMutableData* _nameData=[NSMutableData dataWithCapacity:4096];
    char _nameDivider=ESC_char;
    const char* MacOSXMetaDataPrefix="__MACOSX/";
    
    uLong i;
    unz_global_info gi;
    int err;

    err = unzGetGlobalInfo (uf, &gi);
    if (err!=UNZ_OK) return nil;


    _array=[NSMutableArray arrayWithCapacity:gi.number_entry];
    for (i=0; i<gi.number_entry; i++){
        char filename_inzip[512];
        unz_file_info file_info;
        BOOL    shouldAdd=YES;

        err = unzGetCurrentFileInfo(uf, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
        if (err!=UNZ_OK){
            //printf("error %d with zipfile in unzGetCurrentFileInfo\n",err);
            break;
        }
        
        //OS調べる
        int made_by= file_info.version >> 8;
        switch (made_by){
            case 3: //unix
                ++isMacOSX;
                break;
            case 0: //FAT
            case 11:    //NTFS
                ++isWindows;
                break;
            default:
                --isMacOSX;
                break;
        }
                
        //フィルタ
        if(_listOnlyRealFile && file_info.uncompressed_size<=0){
            shouldAdd=NO;
        }else if([_extensionFilter count]>0){
            shouldAdd=NO;
            char* ext=strrchr(filename_inzip, '.');
            if(ext && strlen(ext) > 1){
                ++ext;
                NSString*   extStr=[[NSString stringWithCString:ext]lowercaseString];

                if(extStr && [_extensionFilter indexOfObject:extStr]!=NSNotFound){
                    shouldAdd=YES;
                }
            }
        }
        //BOMArchiveHelper対策
        if(strncmp(filename_inzip, MacOSXMetaDataPrefix, sizeof(MacOSXMetaDataPrefix))==0){
            ++isMacOSX;
            shouldAdd=NO;
        }
        
        if (shouldAdd){
            //ratio = (file_info.compressed_size*100)/file_info.uncompressed_size;

            HetimaUnZipItem*    item=[[_itemClass alloc]initWithContainer:self rawName:filename_inzip zipInfo:&file_info];  
            if(item){
                [_array addObject:item];
                [item release];
            }
            [_nameData appendBytes:filename_inzip length:strlen(filename_inzip)];
            [_nameData appendBytes:&_nameDivider length:1];
            //check crypted
            if (item && (file_info.flag & 1) != 0){
                _crypted=YES;
            }

        }

        if ((i+1)<gi.number_entry){
            err = unzGoToNextFile(uf);
            if (err!=UNZ_OK){
                //printf("error %d with zipfile in unzGoToNextFile\n",err);
                break;
            }
        }
    }
    
    //detect encoding
    if(isMacOSX > isWindows){
        _encoding=NSUTF8StringEncoding;
    }else{
        _encoding=[HetimaUnZipContainer _relyKTextUtils_detectCharacterCodeType:_nameData];
    }
    
    return _array;
}


#pragma mark -

//自動判別 from KEdit for Mac OS X (KTextUtils.m)

// Character-Code Detector
+ (NSStringEncoding)_relyKTextUtils_detectCharacterCodeType:(NSData*) data
{
	unsigned char	c = 1; // unsigned char is required.
	const char* text = [data bytes];
	const char* text2 = [data bytes];
	KDetectedCharacterCodeType	aCodeType = ASCII_type;
	
	//for UTF-8/16 only. It's not a smart way.
	
	int		codenum, i;
	long	len = strlen(text);
	bool	isASCII = true;
	
	char aUTF16Head[3] = { 0xFE, 0xFF, '\0' };
	if((len >= 2) && !strncmp(text, aUTF16Head, 2)){
		aCodeType = UTF16_type;
	}
	
	
	//int testCount = 0;
	while ((aCodeType == EUCORSJIS_type || aCodeType == ASCII_type) && c != '\0'){
		//testCount++;
		//if(testCount < 20){ NSLog([NSString stringWithFormat:@"c = %hu, 0x%x", c, c]); }
	
		if((c = *text++) != '\0'){
			if(c == ESC_char){
				c = *text++;
				if(c == '$'){
					c = *text++;
					if(c == 'B')
						aCodeType = NEW_type;
					else if(c == '@')
						aCodeType = OLD_type;
				}
				else if(c == 'K')
					aCodeType = NEC_type;
			}
			else if((c >= 129 && c <= 141) || (c >= 143 && c <= 159)){
				aCodeType = SJIS_type;
			}
			else if(c == SS2_char){
				c = *text++;
				if((c >= 64 && c <= 126) || (c >= 128 && c <= 160) || (c >= 224 && c <= 252))
					aCodeType = SJIS_type;
				else if(c >= 161 && c <= 223)
					aCodeType = EUCORSJIS_type;
			}
			else if(c >= 161 && c <= 223){
				c = *text++;
				if(c >= 240 && c <= 254)
					aCodeType = EUC_type;
				else if(c >= 161 && c <= 223)
					aCodeType = EUCORSJIS_type;
				else if(c >= 224 && c <= 239){
					aCodeType = EUCORSJIS_type;
					while (c >= 64 && c != '\0' && aCodeType == EUCORSJIS_type){
						if(c >= 129){
							if(c <= 141 || (c >= 143 && c <= 159))
								aCodeType = SJIS_type;
							else if(c >= 253 && c <= 254)
								aCodeType = EUC_type;
						}
						c = *text++;
					}
				}
				else if(c <= 159)
					aCodeType = SJIS_type;
			}
			else if(c >= 240 && c <= 254)
				aCodeType = EUC_type;
			else if(c >= 224 && c <= 239){
				c = *text++;
				if((c >= 64 && c <= 126) || (c >= 128 && c <= 160))
					aCodeType = SJIS_type;
				else if(c >= 253 && c <= 254)
					aCodeType = EUC_type;
				else if(c >= 161 && c <= 252)
					aCodeType = EUCORSJIS_type;
			}
		}
	}
	if(/*aCodeType == ASCII_type || */(aCodeType != UTF16_type) || (aCodeType != SJIS_type)){
		for(i = 0; i < len; i++){
			if((codenum = [HetimaUnZipContainer _relyKTextUtils_getCodeLength:(text2 + i)]) > 1){
				if([HetimaUnZipContainer _relyKTextUtils_getCodeLength:(text2 + i + 1)] != 0
					|| (codenum == 3 && [HetimaUnZipContainer _relyKTextUtils_getCodeLength:(text2 + i + 2)] != 0)){
					break;
				}
				isASCII = false;
			}
			if(i == len - 1 && !isASCII){
				aCodeType = UTF8_type;
			}
		}
	}
	//NSLog([NSString stringWithFormat:@"code = %d, testcount = %d", aCodeType, testCount]);
	
	if(aCodeType == ASCII_type){
		return NSShiftJISStringEncoding;    //SJIS優先
	}else if(/*aCodeType == ASCII_type ||*/ aCodeType == UTF8_type){
		return NSUTF8StringEncoding;
	}else if(aCodeType == NEW_type || aCodeType == OLD_type){
		return NSISO2022JPStringEncoding;
	}else if(aCodeType == SJIS_type){
		return NSShiftJISStringEncoding;
	}else if(aCodeType == EUC_type || aCodeType == EUCORSJIS_type){
		return NSJapaneseEUCStringEncoding;
	}else if(aCodeType == UTF16_type){
		return NSUnicodeStringEncoding;
	}
	
	//NSLog(@"KTextUtils detectCodeType: an error has occured.");
	return NSShiftJISStringEncoding;
}

+ (int)_relyKTextUtils_getCodeLength:(const char*) text
{
	//Now, for 3 bytes.
	if((*text & 0xc0) != 0x80){
		if((*text & 0x80) == 0){
			return 1;
		}else if((*text & 0xe0) == 0xc0){
			return 2;
		}else if((*text & 0xf0) == 0xe0){
			return 3;
		}else{
			return 0;
		}
	}else{
		return 0;
	}
}

@end


/*
"__MACOSX/"のファイル
82(0x52)バイトがファイル情報
50(0x32)バイト目から (OSType)fileType (OSType)fileCreator (UInt16)finderFlags

82(0x52)バイト以降がリソースフォーク

*/




