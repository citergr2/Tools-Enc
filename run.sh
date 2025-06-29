#!/bin/bash

# Ganti 'script.enc' dengan nama file terenkripsi kamu
ENC_FILE="XitersToolsEnc.enc"

# Jalankan isi hasil dekripsi di RAM (tidak tersimpan di disk)
openssl enc -aes-256-cbc -d -in "$ENC_FILE" | bash
