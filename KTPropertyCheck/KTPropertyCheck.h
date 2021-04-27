//
//  KTPropertyCheck.h
//  KTPropertyCheck
//
//  Created by Kam on 2021/4/27.
//

#import <Foundation/Foundation.h>

@interface KTPropertyCheck : NSObject
/// check mis-typing attrbute perpoerty(`object type` with `assign mem` attribute ) in image(executable, dynamic library, etc)
/// @param classes Class in target image
+ (void)checkImagesThatContainClasses:(NSArray<Class> *)classes;
@end
