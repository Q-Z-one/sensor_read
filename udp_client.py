#!/usr/bin/python
# -*- coding: UTF-8 -*-
import socket               # 导入 socket 模块
from numpy import *
import pudb
import datetime
s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)         # 创建 socket 对象
#s.setblocking(False)
s.settimeout(0.002) #采样频率1khz，超时丢失一个点
host = '192.168.1.145'
port = 49152                # 设置端口号

def hex2dec(string_num):
    return str(int(string_num.upper(),16))

def dec2hex(string_num):
    #num = int(string_num)
    num = string_num
    mid = []
    while True:
        if num==0:
            break
        num,rem = divmod(num,16)
        mid.append(base[rem])
    return ''.join([str(x) for x in mid[:,:,-1]])

def bin2dec(string_num):
    return str(int(string_num,2))

def F2num(arr):  # 将得到的向量进行解算，得到力的大小
    S = 0
    for i in range(8):
        S += arr[i]*(16**(7-i))
    if arr[0]<8:
        return float(S)/1000000
    else:
        return -float(2**32-1-S)/1000000
filetime = datetime.datetime.now().strftime('%Y-%m-%d,%H:%M:%S')
data = uint8([hex2dec('12'),hex2dec('34'),hex2dec('00'),hex2dec('02'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00')])
s.sendto(data,('192.168.1.145',port))
with open(str(filetime)+'.txt','w') as f: # 以时间作为文件名
    while(True):
        try:
            str_info = s.recv(36)
            if not str_info:
                break
            b = []
            for everybyte in str_info:
                num = int(ord(everybyte))
                b.append(num/16)
                b.append(num-(num/16)*16)

            output_tmp = array(b).reshape(9,8)
            print(output_tmp)
            output_tmp = delete(output_tmp,[0,1,2],axis=0)
            F_x = F2num(output_tmp[0,:])
            F_y = F2num(output_tmp[1,:])
            F_z = F2num(output_tmp[2,:])
            T_x = F2num(output_tmp[3,:])
            T_y = F2num(output_tmp[4,:])
            T_z = F2num(output_tmp[5,:])
            f.write(str(F_x)+'\n')
            f.write(str(F_y)+'\n')
            f.write(str(F_z)+'\n')
            f.write(str(T_x)+'\n')
            f.write(str(T_y)+'\n')
            f.write(str(T_z)+'\n')
            #print(F_x)
            #print(F_y)
            #print(F_z)
            #time.sleep(0.001)
        except Exception,e:
            print(e)
            s.sendto(data,('192.168.1.145',port))
s.close()  

# Some issues that have been closed:
# ord chr str ascii .encode .decode can't work 
# I want to change '\x00' to num between 0 and 255
