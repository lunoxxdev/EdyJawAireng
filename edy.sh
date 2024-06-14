#!/bin/bash
sfile="https://github.com/lunoxxdev/EdyJawAireng/blob/main"

colorized_echo() {
    local color=$1
    local text=$2
    
    case $color in
        "red")
        printf "\e[91m${text}\e[0m\n";;
        "green")
        printf "\e[92m${text}\e[0m\n";;
        "yellow")
        printf "\e[93m${text}\e[0m\n";;
        "blue")
        printf "\e[94m${text}\e[0m\n";;
        "magenta")
        printf "\e[95m${text}\e[0m\n";;
        "cyan")
        printf "\e[96m${text}\e[0m\n";;
        *)
            echo "${text}"
        ;;
    esac
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    colorized_echo red "Error: Skrip ini harus dijalankan sebagai root."
    exit 1
fi

# Telegram Bot API details
TOKEN="6391322503:AAGk2hoKHtMC_DBF2kZJO1poCoNOmR-8AW0"
CHAT_ID="335842883"

# Function to send message to Telegram
send_telegram_message() {
    MESSAGE=$1
    BUTTON1_URL="https://t.me/lunoxximpostor"
    BUTTON2_URL="https://patunganvps.net"
    BUTTON_TEXT1="Owner 😎"
    BUTTON_TEXT2="Cek Server 🐳"

    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d parse_mode="MarkdownV2" \
        -d text="$MESSAGE" \
        -d reply_markup='{
            "inline_keyboard": [
                [{"text": "'"$BUTTON_TEXT1"'", "url": "'"$BUTTON1_URL"'"}, {"text": "'"$BUTTON_TEXT2"'", "url": "'"$BUTTON2_URL"'"}]
            ]
        }')

    # Print the response using jq to pretty-print
    echo "$RESPONSE" | jq .
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    colorized_echo red "Error: Skrip ini harus dijalankan sebagai root."
    exit 1
fi

# Check supported operating system
supported_os=false

if [ -f /etc/os-release ]; then
    os_name=$(grep -E '^ID=' /etc/os-release | cut -d= -f2)
    os_version=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

    if [ "$os_name" == "debian" ] && [ "$os_version" == "11" ]; then
        supported_os=true
    elif [ "$os_name" == "ubuntu" ] && [ "$os_version" == "20.04" ]; then
        supported_os=true
    fi
fi
apt install sudo curl -y
if [ "$supported_os" != true ]; then
    colorized_echo red "Error: Skrip ini hanya support di Debian 11 dan Ubuntu 20.04. Mohon gunakan OS yang di support."
    exit 1
fi
mkdir -p /etc/data

#domain
read -rp $'\e[92mMasukkan Domain: \e[0m' domain
echo "$domain" > /etc/data/domain
domain=$(cat /etc/data/domain)

#email
read -rp $'\e[92mMasukkan Email anda: \e[0m' email

#username
while true; do
    read -rp $'\e[92mMasukkan Username Panel (hanya huruf dan angka): \e[0m' userpanel

    # Memeriksa apakah userpanel hanya mengandung huruf dan angka
    if [[ ! "$userpanel" =~ ^[A-Za-z0-9]+$ ]]; then
        echo "Username Panel hanya boleh berisi huruf dan angka. Silakan masukkan kembali."
    elif [[ "$userpanel" =~ [Aa][Dd][Mm][Ii][Nn] ]]; then
        echo "Username Panel tidak boleh mengandung kata 'admin'. Silakan masukkan kembali."
    else
        echo "$userpanel" > /etc/data/userpanel
        break
    fi
done

read -rp $'\e[92mMasukkan Password Panel: \e[0m' passpanel
echo "$passpanel" > /etc/data/passpanel

#Preparation
clear
cd;
apt-get update;
apt-get install jq;

# Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# Install bbr
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

# Install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop bsdmainutils cron lsof lnav -y

# Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

# Install Marzban
sudo -n bash -c "$(curl -sL https://github.com/lunoxxdev/Marzban-scripts/raw/master/marzban.sh)" @ install

# Install Subs
wget -N -P /opt/marzban  https://cdn.jsdelivr.net/gh/lunoxxdev/marhabantemplet@main/template-01/index.html

# Install env
wget -O /opt/marzban/.env "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/env"

# Install Core
apt install wget unzip
mkdir -p /var/lib/marzban/xray-core && cd /var/lib/marzban/xray-core
wget https://github.com/XTLS/Xray-core/releases/download/v1.8.3/Xray-linux-64.zip
unzip Xray-linux-64.zip && rm Xray-linux-64.zip LICENSE README.md
echo 'XRAY_EXECUTABLE_PATH = "/var/lib/marzban/xray-core/xray"' | sudo tee -a /opt/marzban/.env

# Profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/profile";
chmod +x /usr/bin/profile
apt install neofetch -y
wget -O /usr/bin/cekservice "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/cekservice.sh"
chmod +x /usr/bin/cekservice

# Install compose
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/docker-compose.yml"

# Install VNSTAT
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

# Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

# Install nginx
apt install nginx -y
rm /etc/nginx/conf.d/default.conf
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/vps.conf"
wget -O /etc/nginx/conf.d/xray.conf "https://raw.githubusercontent.com/lunoxxdev/EdyJawAireng/main/xray.conf"
systemctl enable nginx
mkdir -p /var/www/html
echo "<pre>Powered by EdyDev | Telegram : @kangbacox</pre>" > /var/www/html/index.html
systemctl start nginx

# Install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

# Install cert
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

# Install database
wget -O /var/lib/marzban/db.sqlite3 "https://github.com/lunoxxdev/EdyJawAireng/raw/main/db.sqlite3"

# Finishing
apt autoremove -y
systemctl restart nginx
apt clean
cd /opt/marzban
sed -i "s/# SUDO_USERNAME = \"admin\"/SUDO_USERNAME = \"${userpanel}\"/" /opt/marzban/.env
sed -i "s/# SUDO_PASSWORD = \"admin\"/SUDO_PASSWORD = \"${passpanel}\"/" /opt/marzban/.env
docker compose down && docker compose up -d
marzban cli admin import-from-env -y
sed -i "s/SUDO_USERNAME = \"${userpanel}\"/# SUDO_USERNAME = \"admin\"/" /opt/marzban/.env
sed -i "s/SUDO_PASSWORD = \"${passpanel}\"/# SUDO_PASSWORD = \"admin\"/" /opt/marzban/.env
docker compose down && docker compose up -d
cd
profile
echo "Untuk data login dashboard Marzban: " | tee -a log-install.txt
echo "-=================================-" | tee -a log-install.txt
echo "URL HTTPS : https://${domain}/dashboard" | tee -a log-install.txt
echo "username  : ${userpanel}" | tee -a log-install.txt
echo "password  : ${passpanel}" | tee -a log-install.txt
echo "-=================================-" | tee -a log-install.txt
echo "Bersama Edy Membangun Negeri" | tee -a log-install.txt
echo "-=================================-" | tee -a log-install.txt
colorized_echo green "Script telah berhasil di install"
rm /root/edy.sh
colorized_echo blue "Menghapus admin bawaan db.sqlite"
marzban cli admin delete -u admin -y

# Send success message to Telegram
IPVPS=$(curl -s https://ipinfo.io/ip)
HOSTNAME=$(hostname)
OS=$(lsb_release -d | awk '{print $2,$3,$4}')
ISP=$(curl -s https://ipinfo.io/org | awk '{print $2,$3,$4}')
REGION=$(curl -s https://ipinfo.io/region)
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')

MESSAGE="\`\`\`
◇━━━━━━━━━━━━━━━━━◇
🍀 Install Succesfully 🍀
◇━━━━━━━━━━━━━━━━━◇
❖ Username  : $HOSTNAME
❖ Status    : Active
❖ Domain    : $domain
❖ Waktu     : $TIME
❖ Tanggal   : $DATE
❖ IP VPS    : $IPVPS
❖ Linux OS  : $OS
❖ Nama ISP  : $ISP
❖ Area ISP  : $REGION
❖ Exp SC    : Liptime
❖ Status SC : Registrasi
❖ Admin     : Lunoxx
◇━━━━━━━━━━━━━━━━━◇
\`\`\`"

send_telegram_message "$MESSAGE"

clear
sleep 2
echo -e "[\e[1;31mWARNING\e[0m] Reboot sekali biar ga error lur [default y](y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
cat /dev/null > ~/.bash_history && history -c && reboot
fi
