//
//  EncodeWAVToAMR.h
//  QCEncodeAudio
//
//  音频格式WAV和AMR互转工具
//


#import <Foundation/Foundation.h>


@interface QCEncodeAudio : NSObject

/**
 *  amr转wav文件
 *
 *  @param amrData amr数据
 *
 *  @return wav数据
 */
+ (NSData *)convertAmrToWavFile:(NSData *)amrData;

/**
 *  wav转amr文件
 *
 *  @param wavData wav数据
 *
 *  @return amr数据
 */
+ (NSData *)convertWavToAmrFile:(NSData *)wavData;

/**
 *  amr转wav
 *
 *  @param amrData amr数据
 *
 *  @return wav数据
 */
+ (NSData *)convertAmrToWav:(NSData *)amrData;

/**
 *  wav转amr
 *
 *  @param wavData wav数据
 *
 *  @return amr数据
 */
+ (NSData *)convertWavToAmr:(NSData *)wavData;

@end
