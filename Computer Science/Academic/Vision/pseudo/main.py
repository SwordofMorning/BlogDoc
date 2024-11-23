import csv
import struct
import os
import numpy as np
import cv2

def create_color_bar(bgr_values, width, height=50):
    """创建色带图像"""
    color_bar = np.zeros((height, width, 3), dtype=np.uint8)
    for i in range(width):
        b, g, r = bgr_values[i]
        color_bar[:, i] = [b, g, r]
    return color_bar

def save_bin_and_preview(bgr_values, base_file, suffix):
    """保存二进制文件和预览图像"""
    bin_file = f"{base_file}_{suffix}.bin"
    png_file = f"{base_file}_{suffix}.png"
    
    # 保存二进制文件
    with open(bin_file, 'wb') as f_bin:
        for b, g, r in bgr_values:
            bgr_bytes = struct.pack('BBB', b, g, r)
            f_bin.write(bgr_bytes)
    
    # 生成并保存预览图像
    color_bar = create_color_bar(bgr_values, len(bgr_values))
    cv2.imwrite(png_file, color_bar)
    
    return bin_file, png_file

def csv_to_bin(csv_file, output_base):
    """
    Convert CSV file with BGR values to binary files and generate color bars
    创建正序和逆序的bin文件和预览图像
    """
    # 读取BGR值
    bgr_values = []
    with open(csv_file, 'r') as f_csv:
        csv_reader = csv.reader(f_csv)
        for row in csv_reader:
            b, g, r = map(int, row)
            bgr_values.append((b, g, r))

    # 创建逆序数组
    bgr_values_reversed = list(reversed(bgr_values))
    
    # 保存正序文件
    forward_bin, forward_png = save_bin_and_preview(bgr_values, output_base, "forward")
    
    # 保存逆序文件
    reverse_bin, reverse_png = save_bin_and_preview(bgr_values_reversed, output_base, "reverse")

    return len(bgr_values), bgr_values, bgr_values_reversed

def verify_bin_file(bin_file, num_colors):
    """读取并验证二进制文件内容"""
    with open(bin_file, 'rb') as f:
        data = f.read()
        
    print(f"\nVerifying: {bin_file}")
    print(f"Expected size: {num_colors * 3} bytes")
    print(f"Actual size: {len(data)} bytes")
    
    print("First 3 BGR values:")
    for i in range(min(3, num_colors)):
        b, g, r = struct.unpack('BBB', data[i*3:i*3+3])
        print(f"BGR({b:3d}, {g:3d}, {r:3d})")
    
    print("Last 3 BGR values:")
    for i in range(max(0, num_colors-3), num_colors):
        b, g, r = struct.unpack('BBB', data[i*3:i*3+3])
        print(f"BGR({b:3d}, {g:3d}, {r:3d})")

def print_color_stats(bgr_values, label):
    """打印颜色统计信息"""
    b_vals = [b for b, _, _ in bgr_values]
    g_vals = [g for _, g, _ in bgr_values]
    r_vals = [r for _, _, r in bgr_values]
    
    print(f"\nColor range statistics ({label}):")
    print(f"B: min={min(b_vals):3d}, max={max(b_vals):3d}")
    print(f"G: min={min(g_vals):3d}, max={max(g_vals):3d}")
    print(f"R: min={min(r_vals):3d}, max={max(r_vals):3d}")

def main():
    # 确保输出目录存在
    os.makedirs('./bin', exist_ok=True)
    
    # 设置输入输出文件
    csv_file = './csv/rainbowhc.csv'
    output_base = './bin/rainbowhc'
    
    print(f"Converting {csv_file}")
    num_colors, bgr_values, bgr_values_reversed = csv_to_bin(csv_file, output_base)
    
    # 输出基本信息
    print(f"\nGenerated files:")
    print(f"1. Forward binary file: {output_base}_forward.bin")
    print(f"2. Forward color bar: {output_base}_forward.png")
    print(f"3. Reverse binary file: {output_base}_reverse.bin")
    print(f"4. Reverse color bar: {output_base}_reverse.png")
    print(f"Number of colors: {num_colors}")
    
    # 验证所有生成的二进制文件
    verify_bin_file(f"{output_base}_forward.bin", num_colors)
    verify_bin_file(f"{output_base}_reverse.bin", num_colors)
    
    # 输出正序和逆序的色值统计
    print_color_stats(bgr_values, "Forward")
    print_color_stats(bgr_values_reversed, "Reverse")

if __name__ == '__main__':
    main()