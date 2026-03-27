#!/bin/bash

# Path ke folder pterodactyl lu
PANEL_PATH="/var/www/pterodactyl"

echo "[+] Memulai Lyyncode Clean Theme Uninstaller..."

# Masuk ke direktori panel
cd "$PANEL_PATH" || { echo "[!] Error: Direktori $PANEL_PATH ga ketemu!"; exit 1; }

# Safety check: mastiin ini beneran folder ptero biar ga salah hapus
if [ ! -f ".env" ]; then 
    echo "[!] Error: File .env ga ketemu. Dibatalkan biar aman."
    exit 1
fi

echo "[+] Masuk mode maintenance..."
php artisan down

echo "[+] Menghapus file core lama yg ketempelan theme..."
# storage sama .env aman
rm -rf app public resources routes vendor

echo "[+] Menarik file vanilla Pterodactyl dari GitHub..."
curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

echo "[+] Menginstall ulang composer dependencies..."
# pake user root biar composer ga rewel masalah permission
export COMPOSER_ALLOW_SUPERUSER=1
composer install --no-dev --optimize-autoloader

echo "[+] Memperbaiki permissions..."
# kalo pake centos/almalinux ganti www-data jadi nginx
chown -R www-data:www-data *
chmod -R 755 storage/* bootstrap/cache/

echo "[+] Membersihkan cache dan memverifikasi database..."
php artisan optimize:clear
php artisan migrate --force

echo "[+] Menyalakan panel kembali..."
php artisan up

echo "[+] Done! Panel udah clean 100% bawaan pabrik."
