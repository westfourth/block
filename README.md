# block

获取`block`的方法签名、函数指针

``` objc
 int (^blk)(int, int) = ^(int a, int b) {
     return a + b;
 };
 
 //  "i16@?0i8i12"
 const char *s = block_get_signature(blk);
 void *func = block_get_function_pointer(blk);
```

``` objc
 int c = ((int (*)(id, int, int))func)(blk, 2, 3);
```

``` objc
 NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:s];
 NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
 inv.target = blk;
 
 int x = 10, y = 20, z = 0;
 [inv setArgument:(__bridge void *)blk atIndex:0];
 [inv setArgument:&x atIndex:1];
 [inv setArgument:&y atIndex:2];
 
 inv.target = blk;
 [inv invoke];
 [inv getReturnValue:&z];
```