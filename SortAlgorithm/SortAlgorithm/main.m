//
//  main.m
//  SortAlgorithm
//
//  Created by wangbc on 16/4/27.
//  Copyright © 2016年 Shanghai Lianyou Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        void quickSort(int *n, int l, int r);
        void bubbleSort(int *n, int l);
        void insetSort(int *n, int l);
        // insert code here...
        int count = 100;
        int *n = malloc(sizeof(int) * count);
        for (int i = 0; i < count; i++) {
            n[i] = (int)(arc4random() % 1000);
        }
        
        NSMutableString *input = [NSMutableString string];
        for (int i = 0; i < count; i++) {
            [input appendString:[NSString stringWithFormat:@"%d,",n[i]]];
        }
        NSLog(@"%@",input);
        
        //quickSort(n, 0, count - 1);
//        bubbleSort(n,count);
        insetSort(n,count);
        
        NSMutableString *result = [NSMutableString string];
        for (int i = 0; i < count; i++) {
            [result appendString:[NSString stringWithFormat:@"%d,",n[i]]];
        }
        NSLog(@"%@",result);
        
    }
    return 0;
}

#pragma mark - 冒泡排序

void bubbleSort(int *n, int l) {
    for (int i = 1; i < l; i++) {
        for (int j = l - 1; j >= i; j--) {
            if(n[j] < n[j-1]) {
                int temp = n[j-1];
                n[j-1] = n[j];
                n[j] = temp;
            }
        }
    }
}

#pragma mark - 快速排序

void quickSort(int *n, int l, int r) {
    if (r <= l) return;
    int s = l, e = r;
    int temp = n[e];
    while(s < e) {
        while(s < e && n[s] < temp) s++;
        if(s < e) n[e] = n[s];
        while(s < e && n[e] >= temp) e--;
        if(s < e) n[s] = n[e];
    }
    n[s] = temp;
    quickSort(n,l,s-1);
    quickSort(n,s+1,r);
}

#pragma mark - 插入排序
void insetSort(int *n, int l) {
    for (int i = 1; i < l; i++) {
        for (int j = i; j > 0; j--) {
            if (n[j] < n[j-1]) {
                int temp = n[j-1];
                n[j-1] = n[j];
                n[j] = temp;
            }
        }
    }
}

