# Security Onion SOC Lab: Attack Detection & Incident Response

## 📝 Overview
This project demonstrates the deployment of a **Security Operations Center (SOC) Lab** using **Security Onion**. The goal is to simulate real-world cyber attacks, monitor them via IDS/SIEM tools, and perform incident response and system hardening.

## 🌐 Network Topology
The lab environment consists of three virtual machines:
* **SOC Manager:** Security Onion (172.16.1.134) - Handling IDS, Log Management, and Analysis.
* **Attacker:** Kali Linux (172.16.1.129) - Used for executing various attack vectors.
* **Victim:** Windows 7 (172.16.1.130) - Monitored via Wazuh Agent.

## ⚔️ Attack Scenarios & Detection
In this lab, I successfully simulated and detected the following threats:

### 1. SSH Brute Force
* **Attack:** Used `xHydra` to perform a password dictionary attack against the victim's SSH service.
* **Detection:** Identified through **Squert** and **Wazuh logs** (Rule ID: 60122 - Logon Failure).

### 2. UDP Flood (DoS)
* **Attack:** Executed a Python-based script to overwhelm the target with UDP packets.
* **Detection:** Observed 100% CPU spikes and network congestion alerts in Security Onion.

### 3. SQL Injection (SQLi)
* **Attack:** Targeted a DVWA (Damn Vulnerable Web App) instance using SQL payloads (`' or 1=1 --`).
* **Detection:** **Suricata IDS** triggered high-priority alerts for SQL syntax in HTTP GET requests.

### 4. Malware & Reverse Shell
* **Attack:** Generated a malicious payload using `msfvenom` and established a Meterpreter session.
* **Detection:** Identified suspicious outbound connections on port 4444 via network traffic analysis.

## 🛡️ Incident Response & System Hardening
Post-attack actions taken to secure the environment:
* **Network Level:** Configured `iptables` for rate-limiting, connection limits, and string matching to block malicious patterns.
* **Host Level:** * Implemented **Account Lockout Policies** on Windows.
    * Identified and terminated malicious processes using Task Manager/Resource Monitor.
    * Configured **Software Restriction Policies** to prevent unauthorized `.exe` execution.
* **Service Level:** Changed default SSH ports and implemented IP Whitelisting.

## 🛠️ Tools Used
* **SIEM/IDS:** Security Onion, Suricata, Squert, Wazuh.
* **Pentest:** Kali Linux, Metasploit, xHydra, SQLmap.
* **Analysis:** Wireshark, CyberChef.
