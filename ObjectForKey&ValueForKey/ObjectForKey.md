# ObjectForKey&ValueForKey

从 NSDictionary 取值的时候有两个方法，objectForKey: 和 valueForKey:，这两个方法具体有什么不同呢？

先从 NSDictionary 文档中来看这两个方法的定义：

objectForKey: returns the value associated with aKey, or nil if no value is associated with aKey. 返回指定 key 的 value，若没有这个 key 返回 nil.

valueForKey: returns the value associated with a given key. 同样是返回指定 key 的 value。
 

直观上看这两个方法好像没有什么区别，但文档里 valueForKey: 有额外一点：

If key does not start with “@”, invokes objectForKey:. If key does start with “@”, strips the “@” and invokes [super valueForKey:] with the rest of the key. via Discussion

一般来说 key 可以是任意字符串组合，如果 key 不是以 @ 符号开头，这时候 valueForKey: 等同于 objectForKey:，如果是以 @ 开头，去掉 key 里的 @ 然后用剩下部分作为 key 执行 [super valueForKey:]。
 

|         | ObjectForKey:key为空 | setObjectForKey:Key为空  | setValueForKey:Key为空  |setObjectForKey:value为空  |  setValueForKey:value为空  |
| ------------- |:-------------:|:-------------:|
| ios7      | ok | crash | crash |crash|ok|
| ios9		| ok |  crash | crash| crash|ok|




