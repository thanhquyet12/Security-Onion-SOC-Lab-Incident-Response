sudo iptables -I FORWARD -p udp -m limit --limit 10/s --limit-burst 20 -j
ACCEPT
sudo iptables -I FORWARD -p tcp --syn -m connlimit --connlimit- above 5 -j REJECT
sudo iptables -I FORWARD -p udp -m string --string "ATTACK_PAYLOAD" -- algo bm -j DROP
sudo iptables -L FORWARD -n -V
