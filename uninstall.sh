#!/bin/bash

# ==========================================
# Lyyncode Clean Theme Uninstaller
# ==========================================
# Script ini akan mengembalikan Pterodactyl ke 
# versi official (vanilla) secara bersih tanpa sisa.

PANEL_PATH="/var/www/pterodactyl"

clear
echo "=================================================="
echo " Lyyncode Clean Theme Uninstaller "
echo "=================================================="
echo ""

echo "[+] Memeriksa direktori panel..."
cd "$PANEL_PATH" || { echo "[!] Error: Direktori $PANEL_PATH tidak ditemukan!"; exit 1; }

# Safety check krusial biar ga salah hapus direktori OS
if [ ! -f ".env" ]; then 
    echo "[!] Error: File .env tidak ditemukan. Script dibatalkan untuk keamanan."
    exit 1
fi

echo "[+] Mematikan akses panel sementara (Maintenance Mode)..."
php artisan down

echo "[+] Menghapus file core lama yang terkontaminasi theme..."
# Folder storage, bootstrap, dan file .env aman tidak dihapus
rm -rf app public resources routes vendor

echo "[+] Mengunduh file core Pterodactyl official terbaru..."
curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

echo "[+] Menginstal ulang dependensi PHP (Composer)..."
# Bypass limit root dari composer
export COMPOSER_ALLOW_SUPERUSER=1
composer install --no-dev --optimize-autoloader

echo "[+] Membersihkan semua cache Laravel..."
php artisan view:clear
php artisan config:clear
php artisan optimize:clear

echo "[+] Memverifikasi dan menyegarkan database..."
# Menambahkan --seed agar default data Pterodactyl tetap utuh
php artisan migrate --seed --force

echo "[+] Memperbaiki perizinan file (Permissions)..."
# Secara default pakai www-data (Ubuntu/Debian). 
# Note: Ganti ke nginx:nginx kalau VPS lu pakai AlmaLinux/CentOS
chown -R www-data:www-data *
chmod -R 755 storage/* bootstrap/cache/

echo "[+] Merestart Pterodactyl Queue Worker..."
# Step krusial official biar proses background sinkron dengan file vanilla
php artisan queue:restart

echo "[+] Mengaktifkan panel kembali..."
php artisan up

echo ""
echo "=================================================="
echo " Selesai! Panel udah balik bersih ke default pabrik. 🚀"
echo "=================================================="
