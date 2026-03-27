#!/bin/bash

clear
echo "=================================================="
echo " Lyyncode Fully Auto Installer Panel, Wings & Egg "
echo "=================================================="
echo ""

# 1. Pastikan expect terinstall untuk auto-answer
if ! command -v expect &> /dev/null; then
    echo "[+] Menginstall 'expect' agar proses 100% otomatis..."
    apt-get update -y && apt-get install -y expect
fi

# 2. Input Data di Awal
read -p "Masukkan Domain Panel (contoh: panel.domain.com) : " PANEL_DOMAIN
read -p "Masukkan Domain/IP Node (contoh: node.domain.com): " NODE_DOMAIN
read -p "Masukkan RAM VPS dalam MB (contoh 8GB = 8192)    : " NODE_RAM
read -p "Masukkan Email Admin                             : " ADMIN_EMAIL
read -p "Masukkan Username Admin                          : " ADMIN_USER
read -p "Masukkan Password Admin                          : " ADMIN_PASS

# Export variabel biar bisa dibaca aman sama sistem expect
export PANEL_DOMAIN NODE_DOMAIN NODE_RAM ADMIN_EMAIL ADMIN_USER ADMIN_PASS

echo ""
echo "[+] Data aman. Proses instalasi berjalan OTOMATIS (lu bisa tinggal rebahan)."
sleep 3

# 3. Auto-Answer Pterodactyl Installer pakai Expect
echo "[+] Menjalankan dan menjawab installer Pterodactyl secara otomatis..."

# Blok ini bakal ngasih input "3" (Panel+Wings), set timezone, password, dll otomatis
expect << 'EOD'
set timeout -1
spawn bash -c "bash <(curl -s https://pterodactyl-installer.se)"

expect {
    -nocase "*Select an option*" { send "3\r"; exp_continue }
    -nocase "*Database name*" { send "\r"; exp_continue }
    -nocase "*Database username*" { send "\r"; exp_continue }
    -nocase "*Password (press enter to*" { send "\r"; exp_continue }
    -nocase "*Select timezone*" { send "Asia/Jakarta\r"; exp_continue }
    -nocase "*Provide the email address*" { send "$env(ADMIN_EMAIL)\r"; exp_continue }
    -nocase "*Email address for the initial*" { send "$env(ADMIN_EMAIL)\r"; exp_continue }
    -nocase "*Username for the initial*" { send "$env(ADMIN_USER)\r"; exp_continue }
    -nocase "*First name for the initial*" { send "Admin\r"; exp_continue }
    -nocase "*Last name for the initial*" { send "Lyyncode\r"; exp_continue }
    -nocase "*Password for the initial*" { send "$env(ADMIN_PASS)\r"; exp_continue }
    -nocase "*FQDN of this panel*" { send "$env(PANEL_DOMAIN)\r"; exp_continue }
    -nocase "*configure the firewall*" { send "y\r"; exp_continue }
    -nocase "*external access*" { send "y\r"; exp_continue }
    -nocase "*HTTPS request is performed*" { send "y\r"; exp_continue }
    -nocase "*Proceed with installation*" { send "y\r"; exp_continue }
    eof
}
EOD

# 4. Verifikasi dan Pindah ke direktori Pterodactyl
cd /var/www/pterodactyl || { echo "[!] Error: Instalasi panel gagal."; exit 1; }

echo "[+] Menyiapkan file Egg JSON..."

# 5. Inject JSON Egg ke temporary file
cat << 'EOT' > /tmp/egg-nodejs.json
{
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {
        "version": "PTDL_v2",
        "update_url": null
    },
    "exported_at": "2025-05-16T11:42:09+07:00",
    "name": "Bot Whatsap",
    "author": "wannhosting@gmail.com",
    "description": null,
    "features": null,
    "docker_images": {
        "ghcr.io/parkervcp/yolks:nodejs_24": "ghcr.io/parkervcp/yolks:nodejs_24",
        "ghcr.io/parkervcp/yolks:nodejs_14": "ghcr.io/parkervcp/yolks:nodejs_14"
    },
    "file_denylist": [],
    "startup": "if [[ -d .git ]] && [[ {{AUTO_UPDATE}} == \"1\" ]]; then git pull; fi; if [[ ! -z ${NODE_PACKAGES} ]]; then /usr/local/bin/npm install ${NODE_PACKAGES}; fi; if [ -f /home/container/package.json ]; then /usr/local/bin/npm install; fi; /usr/local/bin/${CMD_RUN};",
    "config": {
        "files": "{}",
        "startup": "{\r\n    \"done\": \"running\"\r\n}",
        "logs": "{}",
        "stop": "^^C"
    },
    "scripts": {
        "installation": {
            "script": "#!/bin/bash\r\napt update\r\napt install -y git curl jq file unzip make gcc g++ python python-dev libtool\r\nmkdir -p /mnt/server\r\ncd /mnt/server\r\necho -e \"install complete\"\r\nexit 0",
            "container": "node:14-buster-slim",
            "entrypoint": "bash"
        }
    },
    "variables": [
        {
            "name": "Command Run",
            "description": "The command to start the bot",
            "env_variable": "CMD_RUN",
            "default_value": "npm start",
            "user_viewable": true,
            "user_editable": true,
            "rules": "required|string",
            "field_type": "text"
        }
    ]
}
EOT

echo "[+] Memulai injeksi Database (Node, Wings, Nest, dan Egg)..."

# 6. Script PHP untuk konfigurasi sisa database
cat << 'EOF' > auto_ijo.php
<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Pterodactyl\Models\Location;
use Pterodactyl\Models\Node;
use Pterodactyl\Models\Allocation;
use Pterodactyl\Models\Nest;
use Pterodactyl\Services\Nodes\NodeCreationService;
use Pterodactyl\Services\Nodes\NodeConfigurationService;
use Pterodactyl\Services\Eggs\Sharing\EggImporterService;
use Symfony\Component\Yaml\Yaml;

try {
    $fqdn = getenv('NODE_DOMAIN');
    $ram = (int)getenv('NODE_RAM');

    // -- MEMBUAT LOCATION --
    $location = Location::firstOrCreate([
        'short' => 'ID',
        'long' => 'Indonesia',
    ]);

    // -- MEMBUAT NODE --
    $nodeService = app()->make(NodeCreationService::class);
    $nodeData = [
        'name' => 'Node-01',
        'location_id' => $location->id,
        'fqdn' => $fqdn,
        'scheme' => (filter_var($fqdn, FILTER_VALIDATE_IP) ? 'http' : 'https'),
        'memory' => $ram,
        'memory_overallocate' => 0,
        'disk' => $ram * 5,
        'disk_overallocate' => 0,
        'daemonBase' => '/var/lib/pterodactyl/volumes',
        'daemonSFTP' => 2022,
        'daemonListen' => 8080,
        'public' => 1,
        'upload_size' => 100,
    ];
    $node = $nodeService->handle($nodeData);

    // -- MEMBUAT ALLOCATION (PORT 25565 - 25575) --
    $allocations = [];
    for ($i = 25565; $i <= 25575; $i++) {
        $allocations[] = [
            'node_id' => $node->id,
            'ip' => $fqdn,
            'port' => $i
        ];
    }
    Allocation::insert($allocations);

    // -- GENERATE CONFIG.YML UNTUK WINGS --
    $configArray = app()->make(NodeConfigurationService::class)->handle($node);
    $yaml = Yaml::dump($configArray, 4, 2);
    if (!is_dir('/etc/pterodactyl')) {
        mkdir('/etc/pterodactyl', 0755, true);
    }
    file_put_contents('/etc/pterodactyl/config.yml', $yaml);

    // -- MEMBUAT NEST --
    $nest = Nest::firstOrCreate([
        'author' => getenv('ADMIN_EMAIL'),
        'name' => 'Lyyncode Bots',
        'description' => 'Custom Nest untuk layanan Lyyncode'
    ]);

    // -- IMPORT EGG DAN UBAH NAMA --
    $eggJsonString = file_get_contents('/tmp/egg-nodejs.json');
    $eggData = json_decode($eggJsonString, true);
    
    if (json_last_error() === JSON_ERROR_NONE) {
        $eggData['name'] = 'Node JS'; 
        $eggImporter = app()->make(EggImporterService::class);
        $eggImporter->handle($eggData, $nest->id);
    } else {
        echo "WARNING: Gagal memproses JSON Egg.\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
EOF

# 7. Eksekusi script PHP
php auto_ijo.php

# 8. Pembersihan file temporary
rm auto_ijo.php
rm /tmp/egg-nodejs.json

echo "[+] Konfigurasi berhasil diselesaikan."
echo "[+] Mengaktifkan layanan Wings..."

systemctl enable --now wings
systemctl restart wings

echo ""
echo "=================================================="
echo " Sukses install panel + node auto ijo "
echo "=================================================="
echo " Detail Login Panel:"
echo " URL Panel : $PANEL_DOMAIN"
echo " Username  : $ADMIN_USER"
echo " Password  : $ADMIN_PASS"
echo "=================================================="
