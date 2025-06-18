
#import "BPMDetectionManager.h"
#import <AVFoundation/AVFoundation.h>

const int FRAMES_PER_SECOND = 30;

@interface BPMDetectionManager() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) NSMutableArray *dataPointsHue;
@property (nonatomic, assign) int duration;

@end

@implementation BPMDetectionManager

#pragma mark - Data collection


- (void)clear
{
    
    self.dataPointsHue = [[NSMutableArray alloc] init];
    [self turnTorchOn:false];
    [self.session stopRunning];
    self.session = NULL;
    
}

- (void)runDetection : (int) duration
{

    
    
    
    self.dataPointsHue = [[NSMutableArray alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetLow;
    
    self.duration = duration;
    // Retrieve the back camera
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *captureDevice;
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if (device.position == AVCaptureDevicePositionBack)
            {
                captureDevice = device;
                break;
            }
        }
    }
    
    
    
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    [self.session addInput:input];
    
    if (error)
    {
        NSLog(@"%@", error);
    }
    
    AVCaptureDeviceFormat *currentFormat;
    for (AVCaptureDeviceFormat *format in captureDevice.formats)
    {
        NSArray *ranges = format.videoSupportedFrameRateRanges;
        AVFrameRateRange *frameRates = ranges[0];
        
        if (frameRates.maxFrameRate == FRAMES_PER_SECOND && (!currentFormat || (CMVideoFormatDescriptionGetDimensions(format.formatDescription).width < CMVideoFormatDescriptionGetDimensions(currentFormat.formatDescription).width && CMVideoFormatDescriptionGetDimensions(format.formatDescription).height < CMVideoFormatDescriptionGetDimensions(currentFormat.formatDescription).height)))
        {
            currentFormat = format;
        }
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
        
        [device lockForConfiguration:nil];
        
        captureDevice.activeFormat = currentFormat;
        captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, FRAMES_PER_SECOND);
        captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, FRAMES_PER_SECOND);
        
        [device unlockForConfiguration];
        
    }
    
    AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    dispatch_queue_t captureQueue=dispatch_queue_create("catpureQueue", NULL);
    
    [videoOutput setSampleBufferDelegate:self queue:captureQueue];
    
    videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
                                 nil];
    videoOutput.alwaysDiscardsLateVideoFrames = NO;
    
    //    [self.session addInput:input];
    [self.session addOutput:videoOutput];
    
    // Start the video session
    [self.session startRunning];
    
    if (self.delegate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self turnTorchOn: true];
        });
    }
}

- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    } }

- (void)finishDetection
{
    [self turnTorchOn:false];
    [self.session stopRunning];
    
    if (self.delegate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate endDetection];
        });
    }
}

-(void) screenshotOfVideoStream:(CVImageBufferRef)imageBuffer
{
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    if (!ciImage) {
        
    } else {
        
        CGImageRef videoImage = [temporaryContext createCGImage:ciImage
                                                       fromRect:CGRectMake(0, 0,
                                                                           CVPixelBufferGetWidth(imageBuffer),
                                                                           CVPixelBufferGetHeight(imageBuffer))];
        
        if (videoImage != NULL) {
            UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
            
            if (self.delegate)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate getImageFromCamera:image];
                });
            }
            
            CGImageRelease(videoImage);
        } else {
            NSLog(@"❌ Failed to create CGImage from buffer");
        }
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    static int count=0;
    count++;

    
    
    CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    
    [self screenshotOfVideoStream:cvimgRef];
    
    CVPixelBufferLockBaseAddress(cvimgRef,0);
    
    NSInteger width = CVPixelBufferGetWidth(cvimgRef);
    NSInteger height = CVPixelBufferGetHeight(cvimgRef);
    
    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
    size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
    float r=0,g=0,b=0;
    
    long widthScaleFactor = width/192;
    long heightScaleFactor = height/144;
    
    for(int y=0; y < height; y+=heightScaleFactor) {
        for(int x=0; x < width*4; x+=(4*widthScaleFactor)) {
            b+=buf[x];
            g+=buf[x+1];
            r+=buf[x+2];
            // a+=buf[x+3];
        }
        buf+=bprow;
    }
    r/=255*(float) (width*height/widthScaleFactor/heightScaleFactor);
    g/=255*(float) (width*height/widthScaleFactor/heightScaleFactor);
    b/=255*(float) (width*height/widthScaleFactor/heightScaleFactor);

    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    CGFloat hue, sat, bright;
    [color getHue:&hue saturation:&sat brightness:&bright alpha:nil];
    
    
    switch (UIDevice.currentDevice.userInterfaceIdiom) {
        case UIUserInterfaceIdiomUnspecified:break;
        case UIUserInterfaceIdiomPhone:
        if (sat > 0.8) {
            [self.dataPointsHue addObject:@(hue)];
        } else if (sat < 0.5) {
            if (self.delegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate pauseDetection];
                });
            }
        }
        break;
        case UIUserInterfaceIdiomPad:
        if (sat > 0.5) {
            [self.dataPointsHue addObject:@(hue)];
        }
        break;
        case UIUserInterfaceIdiomTV: break;
        case UIUserInterfaceIdiomCarPlay:  break;
    }
    

    
    // Only send UI updates once a second
    if (self.dataPointsHue.count % FRAMES_PER_SECOND == 0 )
    {
        if (self.delegate)
        {
            switch (UIDevice.currentDevice.userInterfaceIdiom) {
                case UIUserInterfaceIdiomUnspecified:break;
                case UIUserInterfaceIdiomPhone:
                        [self tempMethod:0.8 sat:sat];
                    break;
                case UIUserInterfaceIdiomPad:
                        [self tempMethod:0.5 sat:sat];
                    break;
                case UIUserInterfaceIdiomTV: break;
                case UIUserInterfaceIdiomCarPlay:  break;
            }
        }
    }
//    else {
//        if (self.delegate)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.delegate pauseDetection];
//            });
//        }
//    }
    
    if (self.dataPointsHue.count == (self.duration * FRAMES_PER_SECOND))
    {
        [self finishDetection];
    }
    
    CVPixelBufferUnlockBaseAddress(cvimgRef,0);
}

- (void) tempMethod:(CGFloat) thresold sat:(CGFloat) sat{
    
    if (sat > thresold) {
        float displaySeconds = self.dataPointsHue.count / FRAMES_PER_SECOND;
        
        NSArray *bandpassFilteredItems = [self butterworthBandpassFilter:self.dataPointsHue];
        NSArray *smoothedBandpassItems = [self medianSmoothing:bandpassFilteredItems];
        int peakCount = [self peakCount:smoothedBandpassItems];
        
        float secondsPassed = smoothedBandpassItems.count / FRAMES_PER_SECOND;
        float percentage = secondsPassed / 60;
        float heartRate = peakCount / percentage;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateDetction:heartRate time:displaySeconds];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate pauseDetection];
        });
    }
}

#pragma mark - Data processing

- (NSArray *)butterworthBandpassFilter:(NSArray *)inputData
{
    const int NZEROS = 8;
    const int NPOLES = 8;
    static float xv[NZEROS+1], yv[NPOLES+1];
    double dGain = 1.232232910e+02;
    
    NSMutableArray *outputData = [[NSMutableArray alloc] init];
    for (NSNumber *number in inputData)
    {
        double input = number.doubleValue;
        
        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8];
        xv[8] = input / dGain;
        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8];
        yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
        + ( -0.1397436053 * yv[0]) + (  1.2948188815 * yv[1])
        + ( -5.4070037946 * yv[2]) + ( 13.2683981280 * yv[3])
        + (-20.9442560520 * yv[4]) + ( 21.7932169160 * yv[5])
        + (-14.5817197500 * yv[6]) + (  5.7161939252 * yv[7]);
        
        [outputData addObject:@(yv[8])];
    }
    
    return outputData;
}


- (int)peakCount:(NSArray *)inputData
{
    if (inputData.count == 0)
    {
        return 0;
    }
    
    int count = 0;
    
    for (int i = 3; i < inputData.count - 3;)
    {
        if (inputData[i] > 0 &&
            [inputData[i] doubleValue] > [inputData[i-1] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-2] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-3] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+1] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+2] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+3] doubleValue]
            )
        {
            count = count + 1;
            i = i + 4;
        }
        else
        {
            i = i + 1;
        }
    }
    
    return count;
}


- (NSArray *)medianSmoothing:(NSArray *)inputData
{
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < inputData.count; i++)
    {
        if (i == 0 ||
            i == 1 ||
            i == 2 ||
            i == inputData.count - 1 ||
            i == inputData.count - 2 ||
            i == inputData.count - 3)        {
            [newData addObject:inputData[i]];
        }
        else
        {
            NSArray *items = [@[
                                inputData[i-2],
                                inputData[i-1],
                                inputData[i],
                                inputData[i+1],
                                inputData[i+2],
                                ] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
            
            [newData addObject:items[2]];
        }
    }
    
    return newData;
}

@end










