//
//  KTPropertyCheck.m
//  KTPropertyCheck
//
//  Created by Kam on 2021/4/27.
//

#import "KTPropertyCheck.h"
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <objc/runtime.h>
#import <objc/objc.h>
#import <dlfcn.h>

@implementation KTPropertyCheck

static bool isPropertyPass(objc_property_t pro) {
    if (!pro) return false;
    
    const char *attr = property_getAttributes(pro);
    /// non-object type, return
    if (attr[0] != 'T' || attr[1] != '@') return true;
    
    char *ptr = (char *)attr;
    bool metComma = false; /// start
    bool metGorV = false; /// end
    bool pass = false;
    
    /// traverse attributes
    while (*ptr != '\0') {
        char c = *ptr;
        if (c == 'R') {
            pass = true;
            break; /// pass over readonly property
        }

        if (metComma) {
            /// strong, copy , weak
            if (c == '&' || c == 'C' || c == 'W') pass = true;
        }
        
        if (!metComma) {
            metComma = (c == ',');
        }
        
        if (metComma) {
            /// G - custom getter prefix, V - variable name prefix
            metGorV = (c == 'G') || (c == 'V');
        }
        
        if (metGorV) {
            break;
        }
        
        ptr++;
    }
    
    if (!pass) {
        fprintf(stdout, "KTPropertyCheck: ⚠️ %s", property_getName(pro));
    }
    return pass;
}

+ (void)checkImagesThatContainClasses:(NSArray<Class> *)classes {
    [classes enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _check:obj];
    }];
}

+ (void)_check:(Class)cls {
    
    const char *targetImageName = class_getImageName(cls);
    uint32_t imageCount = _dyld_image_count();
    for (uint32_t idx = 0; idx < imageCount; idx++) {
        const char* binaryName = _dyld_get_image_name(idx);
        
        // find target image
        if (strcmp(binaryName, targetImageName) == 0) {

            unsigned long size = 0;
            const struct mach_header *header = _dyld_get_image_header(idx);
            const char *objcClassListSectionName = "__objc_classlist";
            
            void *data = getsectiondata((void *)header, "__DATA", objcClassListSectionName, &size);
            if (!data) data = getsectiondata((void *)header, "__DATA_CONST", objcClassListSectionName, &size);
            if (size == 0) break; // no class here

            Class *classList = (Class *)data;
            unsigned long classCount = (unsigned int)(size / sizeof(Class));
            for (unsigned long clzIdx = 0; clzIdx < classCount; clzIdx++) {
                Class z = classList[clzIdx];
                z = NSClassFromString(NSStringFromClass(z)); // for reading class not would not loaded in runtime
                if (!z) continue;
                
                unsigned int outCount = 0;
                objc_property_t *list = class_copyPropertyList(z, &outCount);
                // no property, skip it...
                if (!list) continue;
                for (unsigned int i = 0; i < outCount; i++) {
                    objc_property_t property = list[i];
                    if (!isPropertyPass(property)) {
                        fprintf(stdout, " in class: %s\n", object_getClassName(z));
                    }
                }
                free(list);
            }
            break;
        }
    }
}

@end
