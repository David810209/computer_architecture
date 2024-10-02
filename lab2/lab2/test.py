import random

def generate_mulh_test_data(rs1_values, rs2_values, num_samples=5):
    selected_indices = random.sample(range(len(rs1_values)), num_samples)
    t = 0
    for idx in selected_indices:
        rs1 = rs1_values[idx]
        rs2 = rs2_values[idx]
        product = rs1 * rs2
        mulh = product >> 32  # 取高 32 位（MULH）
        
        print(f"TEST_RR_SRC10_BYP({t}, mulh,{rs1}, {rs2}, {mulh})")
        t += 1

def generate_mulhu_test_data(rs1_values, rs2_values, num_samples=8):
    selected_indices = random.sample(range(len(rs1_values)), num_samples)
    t = 0
    for idx in selected_indices:
        rs1 = rs1_values[idx]
        rs2 = rs2_values[idx]
        product = rs1 * rs2
        mulh = product >> 32  # 取高 32 位（MULH）
        
        print(f"TEST_RR_OP(mulh,{rs1}, {rs2}, {mulh})")
        t += 1

def generate_mulhsu_test_data(rs1_values, rs2_values, num_samples=8):
    selected_indices = random.sample(range(len(rs1_values)), num_samples)
    t = 0
    for idx in selected_indices:
        rs1 = rs1_values[idx]
        rs2 = rs2_values[idx]
        product = rs1 * rs2
        mulh = product >> 32  # 取高 32 位（MULH）
        
        print(f"TEST_RR_OP(mulh,{rs1}, {rs2}, {mulh})")
        t += 1

# 生成測試資料
rs1 = [-123456,-876543,-456789,-123456,-123456,876543,-567890,-567890,234567,1234567,7654321]
rs2 = [987654,234567,654321,789012,987654,234567,345678,345678,876543,1234567,7654321]
# generate_mulh_test_data(rs1, rs2)
# generate_mulhu_test_data(rs1, rs2)
generate_mulhsu_test_data(rs1, rs2)
