% �򵥵�MIPI CRC����
clear; clc;

% exp: F0 00
data1 = 'FF 00 00 02 B9 DC F3 72 BB D4 B8 5A C8 75 C2 7C 81 F8 05 DF FF 00 00 01';
crc_result1 = crc16(data1, 'hex');

% exp: 69 E5
data2 = 'FF 00 00 00 1E F0 1E C7 4F 82 78 C5 82 E0 8C 70 D2 3C 78 E9 FF 00 00 01';
crc_result2 = crc16(data2, 'hex');

% 1200��0x80�Ĳ�������
%data3_bytes = repmat('80 ', 1, 1200);
%data3 = data3_bytes(1:end-1);  % �Ƴ����һ���ո�
%crc_result3 = crc16(data3, 'hex');

data3_bytes = repmat('08 08 00 ', 1, 400);
data3 = data3_bytes(1:end-1);  % �Ƴ����һ���ո�
crc_result3 = crc16(data3, 'hex');

fprintf('����1���: 0x%04X\n', crc_result1);
fprintf('����2���: 0x%04X\n', crc_result2);
fprintf('����3���: 0x%04X\n', crc_result3);