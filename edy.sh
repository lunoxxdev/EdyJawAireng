#!/bin/bash
sfile="https://github.com/lunoxxdev/EdyJawAireng/blob/main"

# Remove carriage return characters
sed -i 's/\r$//' "$0"

# Telegram Bot API details
TOKEN="6391322503:AAGk2hoKHtMC_DBF2kZJO1poCoNOmR-8AW0"
CHAT_ID="335842883"

# Function to send message to Telegram
send_telegram_message() {
    MESSAGE=$1
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d parse_mode="Markdown" \
        -d text="$MESSAGE"
}

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#email
read -rp "Masukkan Email anda: " email

#admin panel username
read -rp "Masukkan Username Admin Panel: " admin_username

#admin panel password
read -rp "Masukkan Password Admin Panel: " admin_password

#Preparation
clear
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install bbr
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max=4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
sysctl -p;

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/lunoxxdev/Marzban-scripts/raw/master/marzban.sh)" @ install

#Install Subs
wget -N -P /opt/marzban  https://cdn.jsdelivr.net/gh/lunoxxdev/marhabantemplet@main/template-01/index.html

#install env
wget -O /opt/marzban/.env "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/env"

#profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/profile";
chmod +x /usr/bin/profile
apt install neofetch -y
wget -O /usr/bin/cekservice "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/cekservice.sh"
chmod +x /usr/bin/cekservice

#install compose
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/docker-compose.yml"

#Install VNSTAT
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://github.com/lunoxxdev/EdyJawAireng/raw/main/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install 
cd
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz 
rm -rf /root/vnstat-2.6

#Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install nginx
apt install nginx -y
rm /etc/nginx/conf.d/default.conf
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/vps.conf"
wget -O /etc/nginx/conf.d/xray.conf "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/xray.conf"
systemctl enable nginx
mkdir -p /var/www/html
echo "<pre>Powered by EdyDev | Telegram : @kangbacox</pre>" > /var/www/html/index.html
systemctl start nginx

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install cert
systemctl stop nginx
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc
systemctl start nginx
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/xray_config.json"

#install firewall
apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 7879/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp
yes | sudo ufw enable

#install database
wget -O /var/lib/marzban/db.sqlite3 "https://github.com/lunoxxdev/EdyJawAireng/raw/main/db.sqlite3"

# Create admin panel user
marzban cli admin create --sudo --username $admin_username --password $admin_password

# Ask to delete default admin user
read -rp "Apakah Anda ingin menghapus user admin bawaan? (Y/N): " delete_default_admin
if [[ "$delete_default_admin" =~ ^[Yy]$ ]]; then
    marzban cli admin delete --sudo
fi

#finishing
apt autoremove -y
systemctl restart nginx
rm /root/edy.sh
apt clean
marzban restart

# Send success message to Telegram
IPVPS=$(curl -s https://ipinfo.io/ip)
HOSTNAME=$(hostname)
OS=$(lsb_release -d | awk '{print $2,$3,$4}')
ISP=$(curl -s https://ipinfo.io/org | awk '{print $2,$3,$4}')
REGION=$(curl -s https://ipinfo.io/region)
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')
EXPIRE_DATE=$(date -d "+1 day" '+%Y-%m-%d')

MESSAGE="◇━━━━━━━━━━━━━━━━━◇
⚠️SUCCESFULLY INSTALL⚠️
◇━━━━━━━━━━━━━━━━━◇
❖ Username : $HOSTNAME
❖ Status  : Active
❖ Domain  : $domain
❖ Waktu   : $TIME
❖ Tanggal : $DATE
❖ IP VPS  : $IPVPS
❖ Linux Os: $OS
❖ Nama ISP: $ISP
❖ Area ISP: $REGION
❖ MasaAktif: Liptime
❖ Exp Sc  : $EXPIRE_DATE
❖ Status Sc: Registrasi
❖ Order By: lunoxx
◇━━━━━━━━━━━━━━━━━◇"

send_telegram_message "$MESSAGE"

# Clear bash history and reboot
cat /dev/null > ~/.bash_history && history -c && reboot