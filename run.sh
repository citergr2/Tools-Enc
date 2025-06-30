#!/bin/bash

# Tampilkan prompt password
read -sp "Password: " pwd
echo ""

# Coba dekripsi ke file sementara
tmpfile="/data/data/com.termux/files/usr/tmp/xiters.sh"

openssl enc -aes-256-cbc -d -in XitersToolsEnc.enc -pass pass:"$pwd" -out "$tmpfile" 2>/dev/null

# Cek apakah berhasil
if [[ ! -s "$tmpfile" ]]; then
  echo "✗ Gagal dekripsi! Password salah atau file rusak."
  rm -f "$tmpfile"
  exit 1
fi

# Jadikan bisa dieksekusi
chmod +x "$tmpfile"

# Jalankan
bash "$tmpfile"

# Hapus file sementara setelah selesai
rm -f "$tmpfile"

