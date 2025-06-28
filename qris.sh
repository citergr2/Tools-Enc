#!/bin/bash

# Warna
GREEN='\033[1;92m'
NC='\033[0m'

clear
echo -e "${GREEN}========== QRIS PAYMENT TOOLS ==========${NC}"

read -p "Nama Produk      : " produk
read -p "Nominal (Rp)     : " nominal
read -p "Link Pembayaran  : " link

filename="qris_$produk.png"

# Tambahkan info ke dalam QR
full_url="$link?produk=$produk&nominal=$nominal"

# Generate QR
qrencode -o "$filename" "$full_url"

echo -e "${GREEN}QRIS berhasil dibuat: $filename${NC}"
