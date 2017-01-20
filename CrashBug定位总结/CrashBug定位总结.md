

#一 获取crash日志信息
1. 直接通过手机app，在设置->隐私->诊断与用量->诊断与用量数据里面，找到app的崩溃信息，拷贝，然后通过qq、微信等发出来。
2. 手机连接电脑，通过xcode->device>View Device Logs, 查看手机里面的所有的log
3. 第三方平台如友盟的后台
4. XCode->Organizer->crash 或者 iTunes Connect后台（Manage Your Applications - View Details - Crash Reports）
5. 通过iTunes同步后，crash log会保存到电脑中，具体位置如下：

		Mac：  
		~/Library/Logs/CrashReporter/MobileDevice  
		  
		Windows Vista/7：  
		C:\Users<span style="vertical-align: baseline; background-color: transparent; color: #ffa07a; padding: 0px; margin: 0px;" class="string">\<</span>user_name>\AppData\Roaming\Apple computer\Logs\CrashReporter/MobileDevice  
		  
		Windows XP：  
		C:\Documents and Settings<span style="vertical-align: baseline; background-color: transparent; color: #ffa07a; padding: 0px; margin: 0px;" class="string">\<</span>user_name>\Application Data\Apple computer\Logs\CrashReporter

#二 分析crash

分析前，需要先确认crash log和dSYM、app的udid一致，可以使用如下命令：dwarfdump —uuid YourApp.app/YourApp

1. 通过xcode的device log工具自动分析，把需要分析的.crash拖入进入就可以
	- 1.1 如果这个crash对应的包是在这个电脑上archive的，则xcode能自动解析
	- 1.2 如果crash的uuid不在电脑上，则把iOS应用的.app和.dSYM文件放到一个文件夹中，执行命令mdimport foldername，再解析
	- 1.3 还可以通过命令行手动解析整个crash文件export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer; /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash KingReaderSDKDemo.crash KingReaderSDKDemo.app.dSYM > KingReaderSDKDemo.log
2. 手动通过命令行工具解析具体的某个地址
	- 2.1 运行命令xcrun atos -arch arm64 -o /Users/abraham/电脑备份//WifiPlus_iOS.app/WifiPlus_iOS -l 0x1000cc000 0x1000d3a80,其中-l命令指明load address，这个地址在crash log最下面Binary Images处，binary的起始地址
	- 2.2 dwarfdump -arch arm64 MemoryWarningTest.app.dSYM --lookup 0x0000641c，这里的地址是指vmaddr+偏移地址，但是crash log里面给出的地址是load address + 偏移地址，所以这里需要换算一下，例如crash log里面的地址是0x1000d3a80，load address是0x1000cc000，vmaddress是0x100000000(获取vmaddress可以用otool -arch arm64 -l /Users/cnstar-tech/crash/xxx.app/xxx  | grep -B 1 -A 10 "LC_SEGM" | grep -B 3 -A 8 "__TEXT")，则先算出偏移0x7a80,再加上0x100000000,则实际输入dwarfdump命令的地址是0x100007a80



注：
DWARF(Debugging With Attributed RecordFormats)是一种调试文件结构标准