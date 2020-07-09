# AppToolbox

## ATEventBus-类型安全的事件总线

        OC类型安全的基于block的事件总线，自动生成参数模型，支持Xcode代码提示，兼容NSNotification
        
## BlockNotificationCenter-类型安全的通知中心（Deprecated, use ATEventBus）

[设计及使用说明](http://linzhiman.github.io/2019/08/29/BlockNotificationCenter-类型安全的通知中心.html)

## ATInstanceManager-简单模块管理

        通过identifier标识和缓存对象，支持分组，不关心对象类型
        提供便利使用的宏，将identifier限定为对象的类名，使用者可以不关心identifier

## ATProtocolManager-基于协议的模块管理

        通过protocol标识模块，支持懒加载，支持分组，线程安全

## ATTaskQueue-任务队列

        支持并发或者串行执行任务，支持触发所有或者只触发一个任务，支持手动结束任务，支持优先级
      
## ATComponentService-组件中间件

[设计及使用说明](http://linzhiman.github.io/2017/07/07/一种iOS组件化方案.html)

        基于字符串的弱类型调用。ComponentName[NSString]定位组件，Command[NSString]指定方法，Argument[NSDictionary]指定参数，Callback[Block]指定回调方法。
        
        
