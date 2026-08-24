class MIPICSI2RAW12Converter:
    """MIPI CSI-2 RAW12 格式转换器"""
    
    def __init__(self):
        pass
    
    def fpga_to_lane(self, pixels):
        """
        将FPGA像素数据转换为Lane上的RAW12打包数据
        
        Args:
            pixels: 像素值列表，每个像素是12bit值 (0x000 - 0xFFF)
                   或16bit值（只用低12bit）
        
        Returns:
            Lane上的字节流列表
        """
        # 确保像素数量是偶数（RAW12每2个像素打包成3字节）
        if len(pixels) % 2 != 0:
            pixels = pixels + [pixels[-1]]  # 补齐最后一个像素
        
        lane_data = []
        
        for i in range(0, len(pixels), 2):
            pixel0 = pixels[i] & 0xFFF      # 取低12bit
            pixel1 = pixels[i+1] & 0xFFF    # 取低12bit
            
            # RAW12打包格式：
            # Byte0: Pixel0 高8bit
            # Byte1: Pixel1 高8bit  
            # Byte2: Pixel0 低4bit (高位) + Pixel1 低4bit (低位)
            byte0 = (pixel0 >> 4) & 0xFF
            byte1 = (pixel1 >> 4) & 0xFF
            byte2 = ((pixel0 & 0x0F) << 4) | (pixel1 & 0x0F)
            
            lane_data.extend([byte0, byte1, byte2])
        
        return lane_data
    
    def lane_to_soc(self, lane_data):
        """
        将Lane上的数据转换为SoC dump出的12bit紧凑格式
        
        Args:
            lane_data: Lane上的字节流列表
        
        Returns:
            SoC dump的字节流列表（小端16bit格式）
        """
        # 确保数据长度是3的倍数
        if len(lane_data) % 3 != 0:
            raise ValueError(f"Lane数据长度必须是3的倍数，当前长度: {len(lane_data)}")
        
        soc_data = []
        
        for i in range(0, len(lane_data), 3):
            byte0 = lane_data[i]
            byte1 = lane_data[i+1]
            byte2 = lane_data[i+2]
            
            # 将3个字节组成24bit流
            bits_24 = (byte0 << 16) | (byte1 << 8) | byte2
            
            # 12bit紧凑解包：
            # 低12bit -> Pixel0
            # 高12bit -> Pixel1
            pixel0 = bits_24 & 0xFFF         # 低12bit
            pixel1 = (bits_24 >> 12) & 0xFFF # 高12bit
            
            # 以小端16bit格式存储
            # pixel0: 低字节在前
            soc_data.append(pixel0 & 0xFF)        # pixel0 低字节
            soc_data.append((pixel0 >> 8) & 0xFF) # pixel0 高字节
            # pixel1: 低字节在前
            soc_data.append(pixel1 & 0xFF)        # pixel1 低字节
            soc_data.append((pixel1 >> 8) & 0xFF) # pixel1 高字节
        
        return soc_data
    
    def fpga_to_all(self, pixels):
        """
        一站式转换：从FPGA像素到Lane数据和SoC数据
        
        Args:
            pixels: 像素值列表
        
        Returns:
            dict: {
                'fpga_pixels': 输入的像素值,
                'lane_data': Lane上的字节流,
                'soc_data': SoC dump的字节流,
                'soc_pixels': SoC解包后的像素值
            }
        """
        lane_data = self.fpga_to_lane(pixels)
        soc_data = self.lane_to_soc(lane_data)
        
        # 从SoC数据解析出像素值（用于验证）
        soc_pixels = []
        for i in range(0, len(soc_data), 4):
            pixel0 = soc_data[i] | (soc_data[i+1] << 8)
            pixel1 = soc_data[i+2] | (soc_data[i+3] << 8)
            soc_pixels.extend([pixel0, pixel1])
        
        return {
            'fpga_pixels': pixels[:len(soc_pixels)],  # 去除可能的填充
            'lane_data': lane_data,
            'soc_data': soc_data,
            'soc_pixels': soc_pixels
        }


def format_hex_list(data, bytes_per_group=None, prefix='0x'):
    """格式化十六进制列表输出"""
    if bytes_per_group:
        groups = [data[i:i+bytes_per_group] for i in range(0, len(data), bytes_per_group)]
        return ' | '.join([' '.join([f'{prefix}{b:02X}' for b in g]) for g in groups])
    else:
        return ' '.join([f'{prefix}{b:02X}' for b in data])


def main():
    """主函数：演示转换器使用"""
    converter = MIPICSI2RAW12Converter()
    
    print("=" * 80)
    print("MIPI CSI-2 RAW12 数据转换器")
    print("=" * 80)
    
    # 测试案例1：你提供的实际数据
    print("\n【测试案例1】你的实际数据")
    print("-" * 80)
    
    # FPGA发送的像素：0x02 0x80 表示像素值 0x280
    fpga_pixels = [0x280, 0x280]
    
    result = converter.fpga_to_all(fpga_pixels)
    
    print(f"FPGA像素值: {[hex(p) for p in result['fpga_pixels']]}")
    print(f"  -> 二进制: {[bin(p) for p in result['fpga_pixels']]}")
    print()
    print(f"Lane数据 (RAW12打包):")
    print(f"  -> {format_hex_list(result['lane_data'], bytes_per_group=3)}")
    print()
    print(f"SoC Dump (12bit紧凑, 小端16bit):")
    print(f"  -> {format_hex_list(result['soc_data'], bytes_per_group=4)}")
    print()
    print(f"SoC解包后像素值: {[hex(p) for p in result['soc_pixels']]}")
    print(f"  -> 验证: {'✓ 正确' if result['fpga_pixels'] == result['soc_pixels'] else '✗ 错误'}")
    
    # 测试案例2：不同的像素值
    print("\n" + "=" * 80)
    print("【测试案例2】其他像素值测试")
    print("-" * 80)
    
    test_cases = [
        [0x000, 0x000],  # 全黑
        [0xFFF, 0xFFF],  # 全白
        [0x123, 0x456],  # 不同值
        [0xABC, 0xDEF],  # 另一组不同值
    ]
    
    for pixels in test_cases:
        result = converter.fpga_to_all(pixels)
        print(f"\nFPGA: {[hex(p) for p in pixels]}")
        print(f"Lane: {format_hex_list(result['lane_data'])}")
        print(f"SoC:  {format_hex_list(result['soc_data'])}")
        print(f"验证: {[hex(p) for p in result['soc_pixels']]} {'✓' if pixels == result['soc_pixels'] else '✗'}")
    
    # 交互式模式
    print("\n" + "=" * 80)
    print("【交互式转换】")
    print("-" * 80)
    print("输入像素值（十六进制，用空格分隔，如: 280 280）")
    print("或输入 'q' 退出")
    
    while True:
        try:
            user_input = input("\n像素值 > ").strip()
            if user_input.lower() == 'q':
                break
            
            # 解析输入
            pixels = [int(p, 16) for p in user_input.split()]
            
            result = converter.fpga_to_all(pixels)
            
            print(f"\nFPGA像素: {[hex(p) for p in result['fpga_pixels']]}")
            print(f"Lane数据: {format_hex_list(result['lane_data'], bytes_per_group=3)}")
            print(f"SoC数据:  {format_hex_list(result['soc_data'], bytes_per_group=4)}")
            print(f"验证像素: {[hex(p) for p in result['soc_pixels']]} {'✓' if result['fpga_pixels'] == result['soc_pixels'] else '✗'}")
            
        except ValueError as e:
            print(f"输入错误: {e}")
        except KeyboardInterrupt:
            break
    
    print("\n程序结束")


if __name__ == "__main__":
    main()