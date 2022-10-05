//
//  Orientation.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif

@interface Orientation : NSObject <RCTBridgeModule>
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation;
- (void)updateInterfaceOrientation: (UIInterfaceOrientation)orientation
               withOrientationMask: (UIInterfaceOrientationMask) orientationMask
                           resolve: (RCTPromiseResolveBlock) resolve
                            reject: (RCTPromiseRejectBlock)reject;
- (void)updateInterfaceOrientationMask: (UIInterfaceOrientationMask) orientationMask
                           resolve: (RCTPromiseResolveBlock) resolve
                            reject: (RCTPromiseRejectBlock)reject;
+ (UIInterfaceOrientationMask)getOrientation;
@end
