function crc_value = crc16(data, varargin)
    % CRC16计算器 - 基于给定的C代码实现
    % 输入: 
    %   data - 数据数组（可以是十进制数组或十六进制字符串）
    %   varargin - 可选参数，'hex'表示输入是十六进制字符串
    % 输出: 
    %   crc_value - 16位CRC值
    
    % 处理输入参数
    if nargin > 1 && strcmp(varargin{1}, 'hex')
        % 输入是十六进制字符串，转换为数组
        if ischar(data)
            % 移除可能的空格和0x前缀
            data = strrep(data, ' ', '');
            data = strrep(data, '0x', '');
            data = strrep(data, '0X', '');
            
            % 转换为字节数组
            if mod(length(data), 2) ~= 0
                error('十六进制字符串长度必须是偶数');
            end
            
            byte_array = [];
            for i = 1:2:length(data)
                hex_byte = data(i:i+1);
                byte_array = [byte_array, hex2dec(hex_byte)];
            end
            data = byte_array;
        end
    end
    
    % 算法常量
    POLY = hex2dec('8408');  % 0x8408，多项式0x1021的位反转
    
    % 初始化
    crc = hex2dec('ffff');   % 0xFFFF
    length_data = length(data);
    
    % 如果数据长度为0，直接返回初始CRC
    if length_data == 0
        crc_value = crc;
        return;
    end
    
    % 主循环 - 处理每个字节
    for byte_idx = 1:length_data
        % 获取当前字节并确保在0-255范围内
        current_byte = bitand(data(byte_idx), hex2dec('ff'));
        
        % 处理当前字节的每一位（从LSB开始）
        for bit_idx = 0:7
            % 提取CRC的LSB和数据的当前位
            crc_lsb = bitand(crc, 1);
            data_bit = bitand(current_byte, 1);
            
            % 检查是否需要与多项式异或
            if bitxor(crc_lsb, data_bit)
                % CRC右移1位后与多项式异或
                crc = bitxor(bitshift(crc, -1), POLY);
            else
                % CRC直接右移1位
                crc = bitshift(crc, -1);
            end
            
            % 数据字节右移1位，准备处理下一位
            current_byte = bitshift(current_byte, -1);
        end
    end
    
    crc_value = crc;
end