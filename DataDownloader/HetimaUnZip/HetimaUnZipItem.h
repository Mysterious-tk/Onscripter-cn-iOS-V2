//
//  HetimaUnZipItem.h
//  HetimaUnZip
//
//  Created by hetima on 05.3.26.
//  Copyright 2005 Hetima Computer. All rights reserved.
//
//  ChangeLog:
//  2008-12-15	Added HetimaUnzipItemDelegate protocol, _delegate member.		Hisanaga MAKINO(hisaboh@yher.net)
//  2008-12-15	Added extractTo: delegate: method.								Hisanaga MAKINO(hisaboh@yher.net)
//  2008-12-15	Added fireDidExtractDataOfLength method.						Hisanaga MAKINO(hisaboh@yher.net)

/*
HetimaUnZipContainer の contents の中身
直接生成することはないと思われ

- (NSString*)path; で内部パス
- (NSData*)data; で解凍データ
- (unsigned)compressedSize; と - (unsigned)uncompressedSize; でそれぞれのサイズ

*/


#import <Foundation/Foundation.h>


@class HetimaUnZipContainer;
@class HetimaUnZipItem;

@protocol HetimaUnZipItemDelegate
@optional
- (void)item:(HetimaUnZipItem *)item didExtractDataOfLength:(NSUInteger)length;
@end

@interface HetimaUnZipItem : NSObject {
    HetimaUnZipContainer*  _container;
    char*   _rawName;
    BOOL    _crypted;
    NSString*   _path;
    NSData* _data;
    unsigned    _compressedSize;
    unsigned    _uncompressedSize;
    int         _dosDate;
	
	id<HetimaUnZipItemDelegate, NSObject> _delegate;
}
- (id)initWithContainer:(id)container rawName:(char*)rawName zipInfo:(void*)info;

- (NSString *)description;

// ---- 解凍データ ----
// 通常これ
- (NSData*)data;
// これはやってもzipに書き込まれたりはしませんので
- (void)setData:(NSData*)inData;
// 指定のpathに解凍したデータを書き込む
- (BOOL)extractTo:(NSString *)path delegate:(id<HetimaUnZipItemDelegate, NSObject>)delegate;
- (void)fireDidExtractDataOfLength:(NSNumber *)length;

// 先頭数バイトだけ調べたいなんてときはこれで
// sizeはとりあえず32MBまで。それ以上を指定するとエラー扱いになります。
- (NSData*)headDataForSize:(unsigned)size;
// 生データで欲しいときはこっちで
// 返り値は malloc() されたポインタ。呼んだ側で free() してください
// pSize だけ解凍を試み、解凍できたサイズが rSize に入る
// pSize はとりあえず32MBまで。それ以上を指定するとエラー扱いになります。
- (void*)headBytesProposedSize:(unsigned)pSize readSize:(unsigned*)rSize;

// ---- 情報 ----
// 内部パス
- (NSString*)path;
// これはやってもzipに書き込まれたりはしませんので
- (void)setPath:(NSString*)inStr;
// サイズ
- (unsigned)compressedSize;
- (unsigned)uncompressedSize;
// ファイルの更新日
- (NSDate*)modificationDate;

// 親コンテナ HetimaUnZipContainer
- (id)container;

@end
