
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

//! Project version number for BPMDetectionManager.
FOUNDATION_EXPORT double BPMDetectionManagerVersionNumber;

//! Project version string for BPMDetectionManager.
FOUNDATION_EXPORT const unsigned char BPMDetectionManagerVersionString[];

@protocol BPMDetectionManagerDelegate

- (void)updateDetction:(int)bpmCount time: (int)seconds;
- (void)pauseDetection;
- (void)endDetection;
- (void)getImageFromCamera:(UIImage*)image;

@end

@interface BPMDetectionManager : NSObject

@property (nonatomic, weak) id<BPMDetectionManagerDelegate> delegate;

- (void) turnTorchOn: (bool) on;
- (void)runDetection : (int) duration;
- (void)finishDetection;
- (void)clear;

@end



