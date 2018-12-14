#!/usr/bin/python
# -*- coding: UTF-8 -*-
import socket               # 导入 socket 模块
from numpy import *
s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)         # 创建 socket 对象
s.setblocking(True)
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

def F2num(arr):
    S = 0
    for i in range(8):
        S += arr[i]*(16**(7-i))
    if arr[0]<8:
        return float(S)/1000000
    else:
        return -float(2**32-1-S)/1000000

data = uint8([hex2dec('12'),hex2dec('34'),hex2dec('00'),hex2dec('02'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00')])
s.sendto(data,('192.168.1.145',port))
#while(True):
 #   print(bin2dec(s.recv(36)))

while(True):
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
   # output_tmp = output_tmp.T
    output_tmp = delete(output_tmp,[0,1,2],axis=0)
    F_x = output_tmp[0,:]
    F_y = output_tmp[1,:]
    F_z = output_tmp[2,:]
    
   # print(F_x)
   # print(F_y)
   # print(F_z)
    print(F2num(F_x))
s.close()  



# ord chr str ascii .encode .decode can't work 
# I want to change '\x00' to num between 0 and 255
