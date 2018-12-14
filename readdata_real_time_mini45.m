function data=readdata_real_time_mini45
    %% �������ݴ洢��data�У�data��һ��[6,1]�ľ���
    %
    %  ����enable_mini45����������Net_Box��ʼ��30Hz��Ƶ�ʣ��������bug������'192.168.1.1-communication'�е���'RDT Output Rate'��������������
    %  ��ʱudp�����״̬��0��Ϊһ������3�����֣���ʾudp��ͨ���ں�������Ҫfopen����
    %  
    %  ����readdata_mini45��ÿ����һ�ζ�ȡ1�ε�ʱ�Ĵ�������ʾ�������������data(6*1)��
    %  
    %  ����disable_mini45����������Net_Boxֹͣ�������ݣ���ʱudp����״̬�仯Ϊ0����ʾudp�رգ����������ȡ���ݣ������enable_mini45����
    %
    %% �����ֵ

    global mini45   %udp����mini45���䶨��λ��init_mini45
    % global data

    %% ��ȡ����
    % һ�ζ�ȡһ��36�ֽڵ����ݰ������text��
    enable_mini45;
    text = zeros(36,100);
    for i=1:1:100
%         readasync(mini45)
        text(:,i) = fread(mini45);
    end
    disable_mini45;

    %% ��������
    % text �Ǵ����ڶ�ȡ�������������ݣ���һ��36*1��С�ľ������ڵ�ֵΪ10�������֣�����ת��Ϊ16����
    % text_1 ��ת��Ϊ16���Ƶ������������ݣ���һ��2*36��С�ľ������ڵ�ֵΪ16���Ʊ�ʾ
    % text_2 �ǽ�text_1����˳���������е������������ݣ���һ��72*1��С�ľ������ڵ�ֵΪ16���Ʊ�ʾ
    % text_3 �ǽ�text_2����˳���������е������������ݣ���һ��8*9��С�ľ������ڵ�ֵΪ16���Ʊ�ʾ
    % text_4 �ǽ�text_3ת�ò�ȥ��ǰ���к�õ��������������ݣ���һ��6*8��С�ľ���
    % ���У�
    %     ȥ����ǰ����ǰ���зֱ����
    %                    Uint32 rdt_sequence; // RDT sequence number of this packet.
    %                    Uint32 ft_sequence; // The record��s internal sequence number
    %                    Uint32 status; // System status code
    %     �����зֱ����// Force and torque readings use counts values
    %                    Int32 Fx; // X-axis force
    %                    Int32 Fy; // Y-axis force
    %                    Int32 Fz; // Z-axis force
    %                    Int32 Tx; // X-axis torque
    %                    Int32 Ty; // Y-axis torque
    %                    Int32 Tz; // Z-axis torque
    % 
    % ��text_4ת��Ϊ10���ƾ͵�������������ʾ������ʾ��ΪTransducer Loading Snapshot (Counts)������С10^6��
    % ����text_4�ĵ�һλ����ֵ<8��������ֵΪ���������轫����ֵ��2^32-1����õ���ֵ
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
    %%  mini45�Ǵ�������ͨѶ����
    % ����192.168.1.1����communications��ֵ������:
    %              IP Address Mode              ����Ϊ     Static IP
    %              RDT Output Rate (1 to 7000)  ����Ϊ     30���������ø���50��ֵ����ᱨ��


    global mini45
    fopen(mini45);
    cmd_enable=uint8([hex2dec('12'),hex2dec('34'),hex2dec('00'),hex2dec('02'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00')]); %�������ϵط�������
    fwrite(mini45,cmd_enable);

    %% cmd˵����
    %
    % cmd structure include��
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

    cmd_disable=uint8([hex2dec('12'),hex2dec('34'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00'),hex2dec('00')]); %�������ϵط�������
    fwrite(mini45,cmd_disable);
    fclose(mini45);
end