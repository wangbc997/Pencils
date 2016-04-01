
##关于dispatch sources

当与系统底层打交道，需要考虑到某些内核或者其他系统层调用需要花掉一定时间。因此，许多系统接口提供了异步的方式来处理回调。GCD提供了一套通用的处理方式，可以用block来处理这些异步回调。  

* dispatch source是一个很基础的数据类型，用来处理low-level的系统事件，GCD支持以下dispatch source类型：
* Timer dispatch sources处理周期性的notifications.  
* Signal dispatch sources处理UNIX signal. 
 
* Descriptor sources处理file和socket-based相关的通知，如：
	* 当数据读取准备就绪  
	* 当数据写入准备就绪  
	* 当文件被删除，移动或重命名  
	* 当文件元数据信息被更改

* Process dispatch sources处理process相关的事件，如：  
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

#####timer dispatch source
	
	dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (source) {
        dispatch_source_set_timer(source, DISPATCH_TIME_NOW, NSEC_PER_SEC * 5, 1000);
        dispatch_source_set_event_handler(source, ^{
            NSLog(@"timer invoked");
        });
        dispatch_resume(source);
    }
跟使用系统的timer有一些区别的是，dispatch_source_set_timer可以设置timer的精度，也就是说timer可能在interval+-leeway的时间内触发，这样做的目的是为了降低系统消耗。
#####data add dispatch source
这个是自定义的dispatch source通知，需要自己手动触发，data add dispatch source的一个很有用的使用情况是，当目标dispatch queue线程处于繁忙状态的时候，block并不会触发，在线程空闲的时候，所有之前触发会联合到一起执行，减少了线程不必要的损耗。列如如果在异步线程做了什么操作需要触发UISlide改动，可以用data add dispatch source减少性能的消耗，让这个改动在线程繁忙的时候只会执行最后一次。  

	dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
	dispatch_source_set_event_handler(source, ^{
	    unsigned long data = dispatch_source_get_data(source);
	    NSLog(@"%lu",data);
	});
	dispatch_resume(source);
	dispatch_apply(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
	    dispatch_source_merge_data(source, 1);
	});
####dispatch type data read
这也是个比较实用的dispatch source类型，它能监控某个文件目录，在这个文件目录下有文件发生改变（新增，删除，修改等）会触发通知。实用的场景如监控app Document目录下的itunes文件同步。

	NSString *path = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	int fileDescr = open([path fileSystemRepresentation], O_EVTONLY);
	dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescr, DISPATCH_VNODE_ATTRIB|DISPATCH_VNODE_WRITE|DISPATCH_VNODE_LINK|DISPATCH_VNODE_EXTEND, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
	dispatch_source_set_event_handler(source, ^{
	    dispatch_source_vnode_flags_t flags = dispatch_source_get_data(source);//obtain flags
	    if(flags & DISPATCH_VNODE_WRITE){
	    }
	    if(flags & DISPATCH_VNODE_ATTRIB){
	    }
	    if(flags & DISPATCH_VNODE_LINK){
	    }
	    if(flags & DISPATCH_VNODE_EXTEND){
	    }
	});
	    

####其他dispatch source类型

 *  DISPATCH_SOURCE_TYPE_DATA_ADD 			自定义dadasource data add
 *  DISPATCH_SOURCE_TYPE_DATA_OR 			自定义dadasource data or
 *  DISPATCH_SOURCE_TYPE_MACH_SEND:   		mach send监控
 *  DISPATCH_SOURCE_TYPE_MACH_RECV:    	mach receive监控
 *  DISPATCH_SOURCE_TYPE_MEMORYPRESSURE  	内存警告
 *  DISPATCH_SOURCE_TYPE_PROC:           	线程
 *  DISPATCH_SOURCE_TYPE_READ:    			数据源读取
 *  DISPATCH_SOURCE_TYPE_SIGNAL:         	当前线程signals
 *  DISPATCH_SOURCE_TYPE_TIMER:  			timer
 *  DISPATCH_SOURCE_TYPE_VNODE:  			磁盘监控
 *  DISPATCH_SOURCE_TYPE_WRITE:  			数据源写入























