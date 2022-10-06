//
//  Orientation.m
//

#import "Orientation.h"
#import <UIKit/UIKit.h>
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif

@implementation Orientation
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
  _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
  return _orientation;
}

- (void)updateInterfaceOrientation: (UIInterfaceOrientation)orientation
               withOrientationMask: (UIInterfaceOrientationMask) orientationMask
                           resolve: (RCTPromiseResolveBlock) resolve
                            reject: (RCTPromiseRejectBlock)reject
{
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    if (@available(iOS 16.0, *)) {
      NSArray<UIScene *> *connectedScenes = [[[UIApplication sharedApplication] connectedScenes] allObjects];
      if ([connectedScenes count] > 0) {
        UIWindowScene *windowScene = (UIWindowScene) connectedScenes[0];
        [windowScene requestGeometryUpdateWithPreferences: [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:orientationMask]
                                             errorHandler:^(NSError * _Nonnull error) {
          reject(@"err", [error localizedDescription], nil);
        }];
      } else {
        reject(@"err", @"unable to request geometry update because there are zero connected scenes", nil);
      }
    } else {
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: orientation] forKey:@"orientation"];
    }

    resolve(nil);
  }];
}

- (instancetype)init
{
  if ((self = [super init])) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  }
  return self;

}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"specificOrientationDidChange"
                                              body:@{@"specificOrientation": [self getSpecificOrientationStr:orientation]}];

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                              body:@{@"orientation": [self getOrientationStr:orientation]}];

}

- (NSString *)getOrientationStr: (UIDeviceOrientation)orientation {
  NSString *orientationStr;
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;
    case UIDeviceOrientationLandscapeLeft:
    case UIDeviceOrientationLandscapeRight:

      orientationStr = @"LANDSCAPE";
      break;

    case UIDeviceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;

    default:
      // orientation is unknown, we try to get the status bar orientation
      switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
          orientationStr = @"PORTRAIT";
          break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:

          orientationStr = @"LANDSCAPE";
          break;

        case UIInterfaceOrientationPortraitUpsideDown:
          orientationStr = @"PORTRAITUPSIDEDOWN";
          break;

        default:
          orientationStr = @"UNKNOWN";
          break;
      }
      break;
  }
  return orientationStr;
}

- (NSString *)getSpecificOrientationStr: (UIDeviceOrientation)orientation {
  NSString *orientationStr;
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;

    case UIDeviceOrientationLandscapeLeft:
      orientationStr = @"LANDSCAPE-LEFT";
      break;

    case UIDeviceOrientationLandscapeRight:
      orientationStr = @"LANDSCAPE-RIGHT";
      break;

    case UIDeviceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;

    default:
      // orientation is unknown, we try to get the status bar orientation
      switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
          orientationStr = @"PORTRAIT";
          break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:

          orientationStr = @"LANDSCAPE";
          break;

        case UIInterfaceOrientationPortraitUpsideDown:
          orientationStr = @"PORTRAITUPSIDEDOWN";
          break;

        default:
          orientationStr = @"UNKNOWN";
          break;
      }
      break;
  }
  return orientationStr;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];
  callback(@[[NSNull null], orientationStr]);
}

RCT_EXPORT_METHOD(getSpecificOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getSpecificOrientationStr:orientation];
  callback(@[[NSNull null], orientationStr]);
}

RCT_EXPORT_METHOD(lockToPortrait:(RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  #if DEBUG
    NSLog(@"Locked to Portrait");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskPortrait;
  [Orientation setOrientation:orientationMask];
  [self updateInterfaceOrientation:UIInterfaceOrientationPortrait
               withOrientationMask:orientationMask
                           resolve:resolve
                            reject:reject];
}

RCT_EXPORT_METHOD(lockToLandscape:(RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  #if DEBUG
    NSLog(@"Locked to Landscape");
  #endif
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getSpecificOrientationStr:orientation];
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscape;
  if ([orientationStr isEqualToString:@"LANDSCAPE-LEFT"]) {
    [Orientation setOrientation:orientationMask];
    [self updateInterfaceOrientation:UIInterfaceOrientationLandscapeRight
                 withOrientationMask:orientationMask
                             resolve:resolve
                              reject:reject];
  } else {
    [Orientation setOrientation:orientationMask];
    [self updateInterfaceOrientation: UIInterfaceOrientationLandscapeLeft
                 withOrientationMask:orientationMask
                             resolve:resolve
                              reject:reject];
  }
}

RCT_EXPORT_METHOD(lockToLandscapeRight:(RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Right");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
  [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
  [self updateInterfaceOrientation:UIInterfaceOrientationLandscapeLeft
               withOrientationMask:orientationMask
                           resolve:resolve
                            reject:reject];
}

RCT_EXPORT_METHOD(lockToLandscapeLeft:(RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Left");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscapeRight;
  [Orientation setOrientation:orientationMask];
  [self updateInterfaceOrientation:UIInterfaceOrientationLandscapeRight
               withOrientationMask:orientationMask
                           resolve:resolve
                            reject:reject];
}

RCT_EXPORT_METHOD(unlockAllOrientations:(RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
  #if DEBUG
    NSLog(@"Unlock All Orientations");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAllButUpsideDown;
  [Orientation setOrientation:orientationMask];
  [self updateInterfaceOrientation:UIInterfaceOrientationUnknown
               withOrientationMask:orientationMask
                           resolve:resolve
                            reject:reject];
}

- (NSDictionary *)constantsToExport
{

  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];

  return @{
    @"initialOrientation": orientationStr
  };
}

@end
