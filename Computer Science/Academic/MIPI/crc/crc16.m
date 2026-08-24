function crc_value = crc16(data, varargin)
    % CRC16 calculation - MATLAB implementation matching C code
    % Inputs: 
    %   data     - Input array (numeric or hex string)
    %   varargin - Optional parameter 'hex' indicates input is hex string
    % Outputs: 
    %   crc_value - 16-bit CRC value
    
    % Process input arguments
    if nargin > 1 && strcmp(varargin{1}, 'hex')
        % Convert hexadecimal string to byte array
        if ischar(data)
            % Remove spaces and 0x/0X prefixes
            data = strrep(data, ' ', '');
            data = strrep(data, '0x', '');
            data = strrep(data, '0X', '');
            
            % Check for even character length
            if mod(length(data), 2) ~= 0
                error('Hex string length must be even.');
            end
            
            byte_array = [];
            for i = 1:2:length(data)
                hex_byte = data(i:i+1);
                byte_array = [byte_array, hex2dec(hex_byte)];
            end
            data = byte_array;
        end
    end
    
    % Algorithm configuration
    POLY = hex2dec('8408');  % 0x8408 (bit-reversed polynomial of 0x1021)
    
    % Initialization
    crc = hex2dec('ffff');   % Initial value 0xFFFF
    length_data = length(data);
    
    % Return initial CRC if data length is zero
    if length_data == 0
        crc_value = crc;
        return;
    end
    
    % Outer loop - process each byte
    for byte_idx = 1:length_data
        % Get current byte and mask to 0-255 range
        current_byte = bitand(data(byte_idx), hex2dec('ff'));
        
        % Process each bit starting from LSB
        for bit_idx = 0:7
            % Get LSB of CRC and current bit of data
            crc_lsb = bitand(crc, 1);
            data_bit = bitand(current_byte, 1);
            
            % Check if polynomial XOR is required
            if bitxor(crc_lsb, data_bit)
                % Shift CRC right by 1 bit and XOR with polynomial
                crc = bitxor(bitshift(crc, -1), POLY);
            else
                % Shift CRC right by 1 bit
                crc = bitshift(crc, -1);
            end
            
            % Shift current byte right by 1 bit for the next iteration
            current_byte = bitshift(current_byte, -1);
        end
    end
    
    crc_value = crc;
end