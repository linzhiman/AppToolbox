YYModel 性能优化的几个 Tip：

1. 缓存
Model JSON 转换过程中需要很多类的元数据，如果数据足够小，则全部缓存到内存中。

2. 查表
当遇到多项选择的条件时，要尽量使用查表法实现，比如 switch/case，C Array，如果查表条件是对象，则可以用 NSDictionary 来实现。

3. 避免 KVC
Key-Value Coding 使用起来非常方便，但性能上要差于直接调用 Getter/Setter，所以如果能避免 KVC 而用 Getter/Setter 代替，性能会有较大提升。

4. 避免 Getter/Setter 调用
如果能直接访问 ivar，则尽量使用 ivar 而不要使用 Getter/Setter 这样也能节省一部分开销。

5. 避免多余的内存管理方法
在 ARC 条件下，默认声明的对象是 __strong 类型的，赋值时有可能会产生 retain/release 调用，如果一个变量在其生命周期内不会被释放，则使用 __unsafe_unretained 会节省很大的开销。

访问具有 __weak 属性的变量时，实际上会调用 objc_loadWeak() 和 objc_storeWeak() 来完成，这也会带来很大的开销，所以要避免使用 __weak 属性。

创建和使用对象时，要尽量避免对象进入 autoreleasepool，以避免额外的资源开销。

6. 遍历容器类时，选择更高效的方法
相对于 Foundation 的方法来说，CoreFoundation 的方法有更高的性能，用 CFArrayApplyFunction() 和 CFDictionaryApplyFunction() 方法来遍历容器类能带来不少性能提升，但代码写起来会非常麻烦。

7. 尽量用纯 C 函数、内联函数
使用纯 C 函数可以避免 ObjC 的消息发送带来的开销。如果 C 函数比较小，使用 inline 可以避免一部分压栈弹栈等函数调用的开销。

8. 减少遍历的循环次数
在 JSON 和 Model 转换前，Model 的属性个数和 JSON 的属性个数都是已知的，这时选择数量较少的那一方进行遍历，会节省很多时间。
