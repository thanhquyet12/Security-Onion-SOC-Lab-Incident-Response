#!/bin/bash
# -----------------------------------------------------------------------------
# INCIDENT RESPONSE MITIGATION SCRIPT
# Project: SOC Lab - Security Onion & Wazuh
# Author: QuyetNT
# -----------------------------------------------------------------------------

# Khai báo biến (Anh check lại dải IP cho khớp với thực tế máy ảo)
ATTACKER_IP="172.16.1.131"
VICTIM_IP="172.16.1.130"

echo "======================================================================"
echo "   TRIỂN KHAI CÁC QUY TẮC NGĂN CHẶN TẤN CÔNG (MITIGATION STRATEGY)"
echo "======================================================================"

# ---------------------------------------------------------
# PHẦN 1: 3 KỸ THUẬT CỐT LÕI TRONG LAB (MỤC TIÊU CHÍNH)
# ---------------------------------------------------------

# 1. NGĂN CHẶN SSH BRUTE FORCE (Kỹ thuật: Dynamic Blocking với Module Recent)
# Tự động chặn IP nếu thực hiện > 5 kết nối mới tới cổng 22 trong vòng 60 giây.
sudo iptables -A FORWARD -p tcp --dport 22 -m state --state NEW -m recent --set
sudo iptables -A FORWARD -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 5 -j DROP
echo "[OK] Đã cấu hình chặn Brute Force SSH (Dynamic Block)."

# 2. NGĂN CHẶN UDP FLOOD - DDOS (Kỹ thuật: Rate Limiting & Connection Limit)
# - Giới hạn tốc độ gói tin UDP xuống còn 10 gói/giây để bảo vệ CPU máy nạn nhân.
sudo iptables -A FORWARD -p udp --dport 80 -m limit --limit 10/s -j ACCEPT

# - Giới hạn tối đa 5 kết nối đồng thời từ mỗi IP (Chống SYN Flood/Connection Flood).
sudo iptables -A FORWARD -p tcp --syn -m connlimit --connlimit-above 5 -j DROP
echo "[OK] Đã triển khai Rate Limiting và Connection Limit chống DDoS."

# 3. NGĂN CHẶN SQL INJECTION (Kỹ thuật: Layer 7 String Matching)
# Soi "ruột" gói tin để chặn các Payload độc hại phổ biến (' or 1=1 và union select).
sudo iptables -I FORWARD -p tcp --dport 80 -m string --string "' or 1=1" --algo bm -j DROP
sudo iptables -I FORWARD -p tcp --dport 80 -m string --string "union select" --algo bm -j DROP
echo "[OK] Đã kích hoạt bộ lọc nội dung (String Match) chặn SQL Injection."


# ---------------------------------------------------------
# PHẦN 2: CÁC KỸ THUẬT MỞ RỘNG (GIA TĂNG BẢO MẬT)
# ---------------------------------------------------------

# 4. GHI NHẬT KÝ (LOGGING)
# Ghi lại dấu vết các gói tin bị Drop vào Syslog để SOC Analyst có thể điều tra hậu sự cố.
sudo iptables -A FORWARD -m limit --limit 5/m -j LOG --log-prefix "SOC_LAB_DROP: "
echo "[OK] Đã bật Logging cho các sự kiện bị chặn."

# 5. CHỐNG GIẢ MẠO IP (ANTI-SPOOFING)
# Chỉ cho phép lưu lượng từ dải mạng nội bộ hợp lệ đi qua cổng mạng eth1.
sudo iptables -A FORWARD -s ! 172.16.1.0/24 -i eth1 -j DROP
echo "[OK] Đã kích hoạt chính sách Anti-spoofing bảo vệ phân đoạn mạng."

# 6. CHẶN ICMP (ICMP DROP)
# Chặn hoàn toàn lệnh Ping từ máy Hacker để gây khó khăn trong quá trình Reconnaissance (thăm dò).
sudo iptables -A FORWARD -p icmp -s $ATTACKER_IP -j DROP
echo "[OK] Đã chặn Ping từ địa chỉ IP Hacker."

# 7. CHẶN TỔNG THỂ (QUICK CONTAINMENT)
# Lệnh "Vũ lực" - Chặn đứng mọi loại kết nối từ Hacker khi sự cố đang diễn ra trầm trọng.
# Lưu ý: Chỉ bỏ comment khi cần cô lập hoàn toàn IP Hacker ngay lập tức.
# sudo iptables -I FORWARD -s $ATTACKER_IP -j DROP

echo "----------------------------------------------------------------------"
echo "   TẤT CẢ CÁC LUẬT IPTABLES ĐÃ ĐƯỢC ÁP DỤNG THÀNH CÔNG!"
echo "   SỬ DỤNG LỆNH 'sudo iptables -L -v -n' ĐỂ KIỂM TRA BỘ ĐẾM (COUNTERS)."
echo "----------------------------------------------------------------------"
