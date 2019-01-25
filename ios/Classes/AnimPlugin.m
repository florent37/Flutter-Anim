#import "AnimPlugin.h"
#import <anim/anim-Swift.h>

@implementation AnimPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAnimPlugin registerWithRegistrar:registrar];
}
@end
