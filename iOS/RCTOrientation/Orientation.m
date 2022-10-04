//
//  Orientation.m
//

#import "Orientation.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif
#import <UIKitCore/UIWindowSceneGeometryPreferencesIOS.h>

@implementation Orientation
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
  _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
  return _orientation;
}

- (void)updateInterfaceOrientation: (UIInterfaceOrientation)orientation withOrientationMask: (UIInterfaceOrientationMask) orientationMask
{
  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    if (@available(iOS 16.0, *)) {

      UIWindowScene *windowScene ;
      
      if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *connectedScenes = [[UIApplication sharedApplication] connectedScenes];
        if ([connectedScenes count] > 0) {
          for (UIWindowScene *connectedWindowScene in connectedScenes) {
            // Get the first window scene from the set.
            windowScene = connectedWindowScene;
            break;
          }
        }
      } else {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        windowScene = [window windowScene];
      }
      
      if (windowScene != nil) {
        [windowScene requestGeometryUpdateWithPreferences: [UIWindowSceneGeometryPreferencesIOS initWithInterfaceOrientations:orientationMask]
                                             errorHandler:^(NSError * _Nonnull error) {
          // TODO: reject a promise, and log an error in JS.

        }];
      } else {
        // TODO: reject a promise, and log an error in JS.
      }
    } else {
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: orientation] forKey:@"orientation"];
    }
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

RCT_EXPORT_METHOD(lockToPortrait)
{
  #if DEBUG
    NSLog(@"Locked to Portrait");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskPortrait;
  [Orientation setOrientation:orientationMask];
  [self updateInterfaceOrientation:UIInterfaceOrientationPortrait withOrientationMask:orientationMask];
//  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
//  }];

}

RCT_EXPORT_METHOD(lockToLandscape)
{
  #if DEBUG
    NSLog(@"Locked to Landscape");
  #endif
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getSpecificOrientationStr:orientation];
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscape;
  if ([orientationStr isEqualToString:@"LANDSCAPE-LEFT"]) {
    [Orientation setOrientation:orientationMask];
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [self updateInterfaceOrientation:UIInterfaceOrientationLandscapeRight withOrientationMask:orientationMask];
//      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
//    }];
  } else {
    [Orientation setOrientation:orientationMask];
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    [self updateInterfaceOrientation: UIInterfaceOrientationLandscapeLeft withOrientationMask:orientationMask];
//      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
//    }];
  }
}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Right");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
  [self updateInterfaceOrientation: UIInterfaceOrientationLandscapeLeft withOrientationMask:orientationMask];
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
//    }];

}

RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
  #if DEBUG
    NSLog(@"Locked to Landscape Left");
  #endif
  UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskLandscapeRight;
  [Orientation setOrientation:orientationMask];
//  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
  [self updateInterfaceOrientation:UIInterfaceOrientationLandscapeRight withOrientationMask:orientationMask];
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
//  }];

}

RCT_EXPORT_METHOD(unlockAllOrientations)
{
  #if DEBUG
    NSLog(@"Unlock All Orientations");
  #endif
  [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
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
