
##关于dispatch sources

当与系统底层打交道，需要考虑到某些内核或者其他系统层调用需要花掉一定时间。因此，许多系统接口提供了异步的方式来处理回调。GCD提供了一套通用的处理方式，可以用block来处理这些异步回调。  
dispatch source是一个很基础的数据类型，用来处理low-level的系统事件，GCD支持以下dispatch source类型：
Timer dispatch sources处理周期性的notifications.  
Signal dispatch sources处理UNIX signal. 
 
######Descriptor sources处理file和socket-based相关的通知，如：
* 当数据读取准备就绪  
* 当数据写入准备就绪  
* 当文件被删除，移动或重命名  
* 当文件元数据信息被更改

######Process dispatch sources处理process相关的事件，如：  
* 当进程退出
* 当进程处理fork或exec调用
* 当进程收到一个信号
* Mach port dispatch sources处理Mach相关的事件
* Custom dispatch sources自定义dispach source

为了避免事件积压，dispatch source实现了事件合并的逻辑。如果一个事件到来的时候，之前的事件还没被执行或者处理，dispatch source会把新事件的数据和老事件的数据合并。根据dispatch source类型的不同，有些老事件会被新事件替换，例如signal-based的dispatch source只会提供最新的signal，但是同时也会提供距离上次处理总共有多少事件发生过的信息。

##创建和使用dispatch sources
1. 用dispatch_source_create方法来创建dispatch source.
2. 配置dispatch source：
	为dispatch source指定event handler
	如果是timer source，用dispatch_source_set_timer来设置timer信息
3. 为dispatch source设置cancellation代理（optional）
4. 调用dispatch_resume方法来开始处理事件


##dispatch source例子
