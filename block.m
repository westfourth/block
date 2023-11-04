//
//  block.m
//  OCCommand
//
//  Created by xisi on 2023/9/27.
//

#import "block.h"

//  参考苹果libclosure官方源码 https://opensource.apple.com/source/libclosure/
//  Clang Block文档 https://clang.llvm.org/docs/Block-ABI-Apple.html

enum Block_flag {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
};

struct Block_descriptor_1 {
    unsigned long reserved;
    unsigned long size;
};

struct Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    void(*copy)(void *, const void *);
    void(*dispose)(const void *);
};

struct Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};

/*
 descriptor 由下面三项组成：
 Block_descriptor_1（必有）、
 Block_descriptor_2（可能有）、
 Block_descriptor_3（可能有）、
 */
struct Block_layout {
    void *isa;
    enum Block_flag flags; // contains ref count
    int32_t reserved;
    void *FuncPtr;
    
    struct Block_descriptor_1 *descriptor;
};


//  获取block函数签名
const char *block_get_signature(id block) {
    struct Block_layout *layout = (__bridge void *)(block);
    
    if (!(layout->flags & BLOCK_HAS_SIGNATURE)) {
        return NULL;
    }
    
    void *desc = layout->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct Block_descriptor_2);
    }
    
    const char *types = *((const char **)desc);
    return types;
}

//  获取block函数指针
void *block_get_function_pointer(id block) {
    struct Block_layout *layout = (__bridge void *)(block);
    return layout->FuncPtr;
}
