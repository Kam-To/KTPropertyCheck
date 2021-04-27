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
    
    if (attr[0] != 'T' || attr[1] != '@') return true;
    
    char *ptr = (char *)attr;
    bool metComma = false;
    bool pass = false;
    
    // traverse attributes
    while (*ptr != '\0') {
        char c = *ptr;
        if (c == 'R') {
            pass = true;
            break; // pass over readonly property
        }

        if (metComma) {
            // strong, copy , weak
            if (c == '&' || c == 'C' || c == 'W') pass = true;
            // otherwise it's assign
            break;
        }
        metComma = (c == ',');
        ptr++;
    }
    
    if (!pass) fprintf(stdout, "KTPropertyCheck: %s", property_getName(pro));
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
            
            const struct mach_header *header = _dyld_get_image_header(idx);
            unsigned long size = 0;
            const char *objcClassListSectionName = "__objc_classlist";
            
            void *data = getsectiondata((void *)header, "__DATA", objcClassListSectionName, &size);
            if (!data) data = getsectiondata((void *)header, "__DATA_CONST", objcClassListSectionName, &size);
            if (size == 0) break; // no class here

            Class *classList = (Class *)data;
            unsigned long classCount = (unsigned int)(size / sizeof(Class));
            for (unsigned long clzIdx = 0; clzIdx < classCount; clzIdx++) {
                Class z =  [classList[clzIdx] class];
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
