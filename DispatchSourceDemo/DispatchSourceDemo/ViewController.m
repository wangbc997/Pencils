//
//  ViewController.m
//  DispatchSourceDemo
//
//  Created by wangbc on 16/3/28.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray array];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_DATA_ADD"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_DATA_OR"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_MACH_SEND"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_MACH_RECV"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_MEMORYPRESSURE"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_PROC"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_READ"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_SIGNAL"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_TIMER"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_VNODE"];
    [self.items addObject:@"DISPATCH_SOURCE_TYPE_WRITE"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.items[indexPath.row];
    if ([key isEqualToString:@"DISPATCH_SOURCE_TYPE_TIMER"]) {
        [self timerDispatchSource];
    } else if ([key isEqualToString:@"DISPATCH_SOURCE_TYPE_DATA_ADD"]) {
        [self dispatchSourceDataAdd];
    } else if ([key isEqualToString:@"DISPATCH_SOURCE_TYPE_DATA_OR"]) {
        [self dispatchSourceDataOr];
    } else if ([key isEqualToString:@"DISPATCH_SOURCE_TYPE_READ"]) {
        [self dispatchSourceTypeRead];
    } else if ([key isEqualToString:@"DISPATCH_SOURCE_TYPE_SIGNAL"]) {
        [self dispatchSourceSignal];
    } else if ([key isEqualToString:@"custom dispatch source"]) {
        
    }
}

#pragma mark - functional method
/*
 *  [done] DISPATCH_SOURCE_TYPE_DATA_ADD:        n/a
 *  [done] DISPATCH_SOURCE_TYPE_DATA_OR:         n/a
 *  DISPATCH_SOURCE_TYPE_MACH_SEND:       dispatch_source_mach_send_flags_t
 *  DISPATCH_SOURCE_TYPE_MACH_RECV:       n/a
 *  DISPATCH_SOURCE_TYPE_MEMORYPRESSURE   dispatch_source_memorypressure_flags_t
 *  DISPATCH_SOURCE_TYPE_PROC:            dispatch_source_proc_flags_t
 *  [done] DISPATCH_SOURCE_TYPE_READ:            n/a
 *  DISPATCH_SOURCE_TYPE_SIGNAL:          n/a
 *  [done] DISPATCH_SOURCE_TYPE_TIMER:    dispatch_source_timer_flags_t
 *  [done] DISPATCH_SOURCE_TYPE_VNODE:           dispatch_source_vnode_flags_t
 *  [done] DISPATCH_SOURCE_TYPE_WRITE:           n/a
 */

- (void)timerDispatchSource {
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (source) {
        dispatch_source_set_timer(source, DISPATCH_TIME_NOW, NSEC_PER_SEC * 5, 1000);
        dispatch_source_set_event_handler(source, ^{
            NSLog(@"timer invoked");
        });
        dispatch_resume(source);
    }
    self.source = source;
}

- (void)dispatchSourceDataAdd {
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        unsigned long data = dispatch_source_get_data(source);
        NSLog(@"%lu",data);
    });
    dispatch_resume(source);
    dispatch_apply(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        dispatch_source_merge_data(source, 1);
    });
    self.source = source;
}

- (void)dispatchSourceDataOr {
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        unsigned long data = dispatch_source_get_data(source);
        NSLog(@"%lu",data);
    });
    dispatch_resume(source);
    dispatch_apply(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        dispatch_source_merge_data(source, 1<<index);
    });
    self.source = source;
}

- (void)dispatchSourceTypeRead {
    NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.txt"];
    NSData *data = [@"tsdsfasfasd" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [data writeToFile:fileName atomically:YES];
    
    int fileDescriptorNum = open([fileName cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fileDescriptorNum, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        size_t estimated = dispatch_source_get_data(source) + 1;
        // Read the data into a text buffer.
        char* buffer = (char*)malloc(estimated);
        if (buffer)
        {
            ssize_t actual = read(fileDescriptorNum, buffer, (estimated));
            //Boolean done = MyProcessFileData(buffer, actual);  // Process the data.
            
            // Release the buffer when done.
            free(buffer);
            
            // If there is no more data, cancel the source.
            //dispatch_source_cancel(source);
            
        }
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fileDescriptorNum);
    });
    
    dispatch_resume(source);
    
    self.source = source;
}

- (void)dispatchSourceSignal {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        signal(SIGHUP, SIG_IGN);
    });
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGHUP, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_event_handler(source, ^{
        unsigned long data = dispatch_source_get_data(source);
        NSLog(@">>>>>>>>>>>>>>>>>%lu",data);
    });
    dispatch_resume(source);
//    dispatch_apply(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
//        dispatch_source_merge_data(source, 1<<index);
//    });
    self.source = source;
}








//---------------------------------------------
- (void)startMonitorDocumentDicFileChange {
    NSString *path = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    int fileDescr = open([path fileSystemRepresentation], O_EVTONLY);// observe file system events for particular path - you can pass here Documents directory path
    //observer queue is my private dispatch_queue_t object
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescr, DISPATCH_VNODE_ATTRIB| DISPATCH_VNODE_WRITE|DISPATCH_VNODE_LINK|DISPATCH_VNODE_EXTEND, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));// create dispatch_source object to observe vnode events
    dispatch_source_set_registration_handler(source, ^{
        NSLog(@"registered for observation");
        //event handler is called each time file system event of selected type (DISPATCH_VNODE_*) has occurred
        dispatch_source_set_event_handler(source, ^{
            
            dispatch_source_vnode_flags_t flags = dispatch_source_get_data(source);//obtain flags
            NSLog(@"%lu",flags);
            
            if(flags & DISPATCH_VNODE_WRITE)//flag is set to DISPATCH_VNODE_WRITE every time data is appended to file
            {
                //TODO: document文件写入通知后续处理
                NSLog(@"DISPATCH_VNODE_WRITE");
                NSDictionary* dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                float size = [[dict valueForKey:NSFileSize] floatValue];
                NSLog(@"%f",size);
            }
            if(flags & DISPATCH_VNODE_ATTRIB)//this flag is passed when file is completely written.
            {
                NSLog(@"DISPATCH_VNODE_ATTRIB");
                dispatch_source_cancel(source);
            }
            if(flags & DISPATCH_VNODE_LINK)
            {
                NSLog(@"DISPATCH_VNODE_LINK");
            }
            if(flags & DISPATCH_VNODE_EXTEND)
            {
                NSLog(@"DISPATCH_VNODE_EXTEND");
            }
        });
        
        dispatch_source_set_cancel_handler(source, ^{
            close(fileDescr);
        });
    });
    
    //we have to resume dispatch_objects
    dispatch_resume(source);
}

@end
