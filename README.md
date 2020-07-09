# AppToolbox

## ATEventBus

OC类型安全的基于block的事件总线，自动生成参数模型，支持Xcode代码提示，兼容NSNotification

使用说明：

- 假设需要定义一个名字为kName的事件，具有2个参数，第一个参数类型int，第二个参数类型为NSString*

- 头文件添加申明

        AT_EB_DECLARE(kName, int, a, NSString *, b)
        
- 实现文件添加定义

        AT_EB_DEFINE(kName, int, a, NSString *, b)

- 订阅事件，通过event.data的属性访问事件参数

        [AT_EB_EVENT(kName).observer(self) reg:^(ATEBEvent<ATEB_DATA_kName *> * _Nonnull event) {
                event.data.a;
                event.data.b;
        }];
        
- 取消订阅

        AT_EB_EVENT(kName).observer(self).unReg();
        
- 取消所有订阅，注意不会取消强力订阅，一般不需要调用，内部弱引用observer

        [[ATEventBus sharedObject] unRegAllEvent:self];
        
- 强力订阅和取消

        self.eventToken = [AT_EB_EVENT(kName).observer(self) forceReg:^(ATEBEvent<ATEB_DATA_kName *> * _Nonnull event) {}];
        [self.eventToken dispose];
        
- 触发事件

        [AT_EB_BUS(kName) post_a:123 b:@"abc"];
 
兼容NSNotification：

- 声明系统事件

        AT_EXTERN_NOTIFICATION(kSysName);或自行声明NSString
        
- 定义系统事件

        AT_DECLARE_NOTIFICATION(kSysName);或自行定义NSString
        
- 订阅事件

        [AT_EB_EVENT_SYS(kSysName).observer(self) reg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {}];
        
- 取消订阅

        AT_EB_EVENT_SYS(kSysName).observer(self).unReg();
        
 - 取消所有订阅，注意不会取消强力订阅，一般不需要调用，内部弱引用observer
 
        [[ATEventBus sharedObject] unRegAllEvent:self];
        
- 强力订阅和取消

        self.eventToken = [AT_EB_EVENT_SYS(kSysName).observer(self) forceReg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {}];
        [self.eventToken dispose];
        
- 触发事件

        [AT_EB_BUS_SYS(kSysName) post_data:@{}];
        
