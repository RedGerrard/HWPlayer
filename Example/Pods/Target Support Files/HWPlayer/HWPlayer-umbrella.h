#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HWFileManager.h"
#import "HWPlayer.h"
#import "HWPlayerDownLoader.h"
#import "HWResourceLoaderDelegate.h"

FOUNDATION_EXPORT double HWPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char HWPlayerVersionString[];

