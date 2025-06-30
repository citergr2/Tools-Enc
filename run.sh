#!/bin/bash
read -sp "Password: " pwd
echo ""

openssl enc -aes-256-cbc -d -in XitersToolsEnc.enc -pass pass:$pwd -out temp_xiters.sh

if [[ ! -s temp_xiters.sh ]]; then
  echo "✗ Gagal dekripsi! Password salah atau file rusak."
  exit 1
fi

chmod +x temp_xiters.sh
./temp_xiters.sh
rm temp_xiters.sh

