function data=readdata_real_time_mini45
    %% 最终数据存储在data中，data是一个[6,1]的矩阵
    %
    %  运行enable_mini45，传感器的Net_Box开始以30Hz的频率（如果发生bug可以在'192.168.1.1-communication'中调低'RDT Output Rate'）发出数据流，
    %  此时udp对象的状态从0变为一个大于3的数字，表示udp接通，在后续不需要fopen操作
    %  
    %  运行readdata_mini45，每运行一次读取1次当时的传感器的示数，结果储存在data(6*1)中
    %  
    %  运行disable_mini45，传感器的Net_Box停止发送数据，此时udp对象状态变化为0，表示udp关闭，如需继续读取数据，需进行enable_mini45操作
    %
    %% 定义初值

    global mini45   %udp对象mini45，其定义位于init_mini45
    % global data

    %% 读取数据
    % 一次读取一个36字节的数据包存放在text中
    enable_mini45;
    text = zeros(36,100);
    for i=1:1:100
%         readasync(mini45)
        text(:,i) = fread(mini45);
    end
    disable_mini45;

    %% 翻译数据
    % text 是从网口读取的力传感器数据，是一个36*1大小的矩阵，其内的值为10进制数字，需先转化为16进制
    % text_1 是转化为16进制的力传感器数据，是一个2*36大小的矩阵，其内的值为16进制表示
    % text_2 是将text_1按列顺序重新排列的力传感器数据，是一个72*1大小的矩阵，其内的值为16进制表示
    % text_3 是将text_2按列顺序重新排列的力传感器数据，是一个8*9大小的矩阵，其内的值为16进制表示
    % text_4 是将text_3转置并去掉前三行后得到的力传感器数据，是一个6*8大小的矩阵
    % 其中：
    %     去掉的前三行前三行分别代表：
    %                    Uint32 rdt_sequence; // RDT sequence number of this packet.
    %                    Uint32 ft_sequence; // The record’s internal sequence number
    %                    Uint32 status; // System status code
    %     后六行分别代表：// Force and torque readings use counts values
    %                    Int32 Fx; // X-axis force
    %                    Int32 Fy; // Y-axis force
    %                    Int32 Fz; // Z-axis force
    %                    Int32 Tx; // X-axis torque
    %                    Int32 Ty; // Y-axis torque
    %                    Int32 Tz; // Z-axis torque
    % 
    % 将text_4转化为10进制就到的力传感器的示数，该示数为Transducer Loading Snapshot (Counts)，需缩小10^6倍
    % 其中text_4的第一位的数值<8代表所得值为正，否则需将所得值与2^32-1做差，得到负值
    %  data = 1;
    %%
    l = 3600;
    data = zeros(6,l/36);
    for i=1:1:l/36
        text_1=dec2hex(text(:,i))';
        text_4=reshape(text_1,[8,9])';
        text_4(1:3,:)=[];
        data(:,i)=hex2dec(text_4);

        for a=1:6
            if str2double(text_4(a,1))<8
                data(a,i)=(data(a,i))/10^6;
            else
                data(a,i)=(data(a,i)-2^32+1)/10^6;
            end
        end
    end
end
    
function enable_mini45
    %%  mini45是传感器的通讯对象
    % 进入192.168.1.1设置communications的值，其中:
    %              IP Address Mode              设置为     Static IP
    %              RDT Output Rate (1 to 7000)  设置为     30（不能设置高于50的值否则会报错）


    global mini45
    fopen(mini45);
    cmd_enable=uint8([hex2dec('12'),hex2dec('34'),hex2dec('00'),hex2dec('02'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00')]); %连续不断地发送数据
    fwrite(mini45,cmd_enable);

    %% cmd说明：
    %
    % cmd structure include：
    %    Uint16 command_header = 0x1234; // Required
    %    Uint16 command; // Command to execute
    %    Uint32 sample_count;		 // Samples to output (0 = infnite)
    %
    %   Command           Command Name                                      Command Response
    %    0x0000          Stop streaming                                          none
    %    0x0002          Start high-speed real-time streaming                RDT record(s)
    %    0x0003          Start high-speed buffered streaming                 RDT record(s)
    %    0x0004          Start multi-unit streaming (synchronized)           RDT record(s)
    %    0x0041          Reset Threshold Latch                                   none
    %    0x0042          Set Software Bias                                       none
    %   
    % Set sample_count to the number of samples to output. If you set sample_count to zero, the Net Box will output continuously until
    % you send an RDT request with command set to zero.
    %
    %
end

function disable_mini45
    global mini45

    cmd_disable=uint8([hex2dec('12'),hex2dec('34'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00')]); %连续不断地发送数据
    fwrite(mini45,cmd_disable);
    fclose(mini45);
end