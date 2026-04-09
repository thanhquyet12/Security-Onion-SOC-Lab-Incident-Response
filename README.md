# 🛡️ Security Onion SOC Lab: Inline Monitoring & Incident Response

## 1. Khái quát (Overview)
Dự án tập trung xây dựng mô hình **SOC (Security Operations Center)** thực tế nhằm giám sát, phát hiện và phản ứng trước các kịch bản tấn công mạng phổ biến.

* **Kiến trúc:** **Inline Monitoring** (Giám sát trực tiếp). Security Onion đóng vai trò là "chốt chặn" trung tâm, buộc mọi lưu lượng từ kẻ tấn công phải đi qua hệ thống kiểm soát trước khi đến đích.
* **Giá trị cốt lõi:** Thực thi quy trình **IR (Incident Response)** chuẩn hóa từ bước nhận diện dấu hiệu cho đến khi củng cố hệ thống (Hardening).

![SOC Dashboard Overview](Images/01-Setup/01-08-soc-dashboard-overview.png)

---

## 2. Kỹ thuật sơ bộ (Technical Specifications)

### 🖥️ Danh sách máy ảo
* **Attacker:** Kali Linux (172.16.1.131)
* **Monitor/IPS:** Security Onion (172.16.1.134) - Chạy IDS/IPS, Wazuh Manager.
* **Victim:** Windows 7 (172.16.1.130) - Cài đặt Wazuh Agent & Bitvise SSH.

### 🌐 Sơ đồ kết nối
| Kết nối | Giao diện mạng | Ghi chú |
| :--- | :--- | :--- |
| Kali → SecOnion | VMnet2 | Phân đoạn tấn công (Attack Segment) |
| SecOnion → Win7 | VMnet8 | Phân đoạn nạn nhân (Victim Segment) |

![Lab Topology](Images/01-Setup/01-01-network-topology.png)

---

## 3. Kịch bản tấn công (Attack Scenarios)
Mô phỏng các kỹ thuật tấn công thực tế từ máy Kali (Attacker) nhắm vào Windows 7 (Victim).

### 3.1. SSH Brute Force
Sử dụng `xHydra` để dò tìm mật khẩu. Hệ thống ghi nhận hàng loạt nỗ lực login thất bại trước khi tìm thấy password đúng.
![xHydra Attack Running](Images/03-Attack/03-24-bruteforce-success-hydra.png)

### 3.2. Malware Reverse Shell
Tạo mã độc bằng `msfvenom`, lừa nạn nhân thực thi file `malware.exe` trên máy Win7 để thiết lập kết nối ngược về Kali.
| Chạy Malware trên Win7 | Session Meterpreter thiết lập |
| :--- | :--- |
| ![Run Malware](Images/03-Attack/03-36-malware-execution-win7.png) | ![Meterpreter Session](Images/03-Attack/03-37-meterpreter-session-opened.png) |

### 3.3. UDP Flood (DDoS)
Chạy script `UDPFloodattack.py` trên Kali đẩy lưu lượng UDP cực lớn, làm cạn kiệt tài nguyên máy nạn nhân.
![Kali Running DDoS Script](Images/03-Attack/03-27-ddos-script-execution.png
)

### 3.4. SQL Injection
Sử dụng payload `' or 1=1 -- -` trực tiếp trên trình duyệt máy Kali để vượt qua cơ chế xác thực của ứng dụng web DVWA.
![SQLi Payload Execution](Images/03-Attack/03-31-sqli-payload-input.png)

---

## 4. Quy trình ứng phó sự cố (Incident Response)

### Giai đoạn 1: Phát hiện & Xác minh (Detection)
Sử dụng mô hình đối chiếu giữa Cảnh báo IDS (Squert) và Chứng cứ thực tế (Logs/Performance).

| Loại tấn công | Cảnh báo hệ thống (Squert/IDS) | Chứng cứ thực tế (Logs/Metrics) |
| :--- | :--- | :--- |
| **SSH Brute Force** | ![Squert SSH Alert](Images/03-Attack/03-25-squert-et-scan-alert.png) | ![Bitvise Activity Log](Images/04-IR/04-39-bitvise-ssh-log-success.png) |
| **DDoS Attack** | ![Squert DoS Alert](Images/03-Attack/03-29-squert-dos-detected.png) | ![CPU Impact 100%](Images/03-Attack/03-28-cpu-impact-100-percent.png) |
| **SQL Injection** | ![Squert SQLi Alert](Images/03-Attack/03-32-squert-sqli-attack-alert.png) | 
| **Malware Shell** | ![Squert Malware Alert](Images/03-Attack/03-38-squert-metasploit-alert.png) | ![Win7 Task Manager Malware](Images/04-IR/04-42-task-manager-malware-detect.png) |

---

### Giai đoạn 2: Xử lý & Ngăn chặn (Containment & Eradication)

#### 🛡️ Đối với SSH & Malware
1. **Block IP:** Chặn IP kẻ tấn công tại Gateway SecOnion. ![Block IP](Images/04-IR/04-40-block-attacker-ip.png)
2. **Disable User:** Vô hiệu hóa tạm thời tài khoản quyetnt. ![Disable](Images/04-IR/04-41-disable-compromised-user.png) 
3. **Eradication:** Truy tìm PID qua Resource Monitor![PID](Images/04-IR/04-43-resource-monitor-malware-pid.png) 

"Kill" tiến trình malware

  ![Kill Malware](Images/04-IR/04-45-kill-process-tree.png)

"Delete file" malware.exe vĩnh viễn.
    
  ![Delete file](Images/04-IR/04-46-permanent-file-deletion.png)
  
4. **Hardening:**

Thiết lập chính sách mật khẩu.

![Lockout Policy](Images/04-IR/04-48-password-policy-config.png)

Thiết lập chính sách khóa tài khoản. ![Lockout policy](Images/04-IR/04-47-account-lockout-policy.png)

Thiết lập chính sách tường lửa và giới hạn IP. 

![Network Hardening](Images/04-IR/04-50-firewall-ip-whitelisting.png)

Thiết lập chính sách giám sát và kiểm tra. ![Audit Policy](Images/04-IR/04-51-advanced-audit-policy.png) 

Củng cố dịch vụ SSH. ![Bitvise Hardening](Images/04-IR/04-49-ssh-port-obfuscation.png)

Software Restriction Policies (SRP) để chặn file lạ. ![SRP Policy Change](Images/04-IR/04-52-srp-config-rules.png) 

#### 🌊 Đối với DDoS (Iptables Mitigation)
Sử dụng Firewall: Windows Firewall with Advanced Security
![BlockIP](Images/04-IR/04-54-win-firewall-inbound-block.png)
Sử dụng Iptables:
Triển khai 3 kỹ thuật lọc lưu lượng chuyên sâu trên Iptables:
```bash
# 1. Giới hạn tốc độ gói tin (Rate Limiting)
sudo iptables -A FORWARD -p udp --dport 80 -m limit --limit 10/s -j ACCEPT
```
Seconion CLI:
![Drop counter](Images/04-IR/04-58-iptables-drop-counter-verify.png)
```bash
# 2. Giới hạn số lượng kết nối đồng thời (Conn-limit)
sudo iptables -A FORWARD -p tcp --syn -m connlimit --connlimit-above 5 -j DROP
```
Seconion CLI:
![Drop counter](Images/04-IR/04-62-iptables-drop-pkts-check.png)
```bash
# 3. Phân tích hành vi (L7 String Matching) - Chặn gói tin chứa chuỗi độc hại
sudo iptables -I FORWARD -m string --string "malicious_payload" --algo bm -j DROP
```
Seconion CLI:
![Drop counter](Images/04-IR/04-65-iptables-string-drop-verify.png)

*Kết quả: CPU máy nạn nhân phục hồi về mức ổn định <5%.*

![CPU](Images/04-IR/04-59-cpu-recovery-iptables.png)

#### 💉 Đối với SQL Injection
1. **Block IP:** Sử dụng Iptables:
```bash
sudo iptables -I FORWARD -s 172.16.2.131 -j DROP
```

![BlockIP](Images/04-IR/04-67-iptables-block-sqli-ip.png)

2. **Deep Packet Inspection:** Sử dụng **Sguil** đọc Transcript.

![Transcript](Images/04-IR/04-68-sguil-transcript-encoded.png)

Giải mã(Decode) Payload gốc.

![Sguil Transcript Decode](Images/04-IR/04-69-payload-decode.png)

3. **Hardening:** Nâng cấp Security Level của DVWA lên mức **Impossible**.
![DVWA Security Impossible](Images/04-IR/04-70-dvwa-impossible-mode.png)

---

## 🚀 Key Skills Gained
* SOC Analyst Mindset (Detection -> Analysis -> Response).
* Advanced Iptables Filtering & System Hardening (SRP, GPO).
* Traffic Forensics with Sguil & Wireshark.

---
🛠️ **Tools:** Security Onion 2, Wazuh, Suricata, Kali Linux, xHydra, Metasploit.
