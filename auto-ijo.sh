#!/bin/bash

clear
echo "=================================================="
echo " Lyyncode Fully Auto Installer Panel, Wings & Egg "
echo "=================================================="
echo ""

# 1. Pastikan expect terinstall
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

export PANEL_DOMAIN NODE_DOMAIN NODE_RAM ADMIN_EMAIL ADMIN_USER ADMIN_PASS

echo ""
echo "[+] Data aman. Proses instalasi berjalan OTOMATIS"
sleep 3

# 3. Auto-Answer Pterodactyl Installer
echo "[+] Menjalankan installer Pterodactyl..."

expect << 'EOD'
set timeout -1
spawn bash -c "bash <(curl -s https://pterodactyl-installer.se)"

expect {
    -nocase "*Input 0-*" { send "2\r"; exp_continue }
    -nocase "*install MariaDB*" { send "y\r"; exp_continue }
    -nocase "*Database name*" { send "\r"; exp_continue }
    -nocase "*Database username*" { send "\r"; exp_continue }
    -nocase "*Password (press enter to*" { send "\r"; exp_continue }
    -nocase "*Select timezone*" { send "Asia/Jakarta\r"; exp_continue }
    -nocase "*Provide the email address that will be used*" { send "$env(ADMIN_EMAIL)\r"; exp_continue }
    -nocase "*Email address for the initial*" { send "$env(ADMIN_EMAIL)\r"; exp_continue }
    -nocase "*Username for the initial*" { send "$env(ADMIN_USER)\r"; exp_continue }
    -nocase "*First name for the initial*" { send "Admin\r"; exp_continue }
    -nocase "*Last name for the initial*" { send "Lyyncode\r"; exp_continue }
    -nocase "*Password for the initial*" { send "$env(ADMIN_PASS)\r"; exp_continue }
    -nocase "*FQDN of this panel*" { send "$env(PANEL_DOMAIN)\r"; exp_continue }
    -nocase "*configure UFW*" { send "y\r"; exp_continue }
    -nocase "*configure HTTPS*" { send "y\r"; exp_continue }
    -nocase "*HTTPS request is performed*" { send "y\r"; exp_continue }
    -nocase "*Continue with installation*" { send "y\r"; exp_continue }
    -nocase "*telemetry data*" { send "no\r"; exp_continue }
    -nocase "*Do you agree?*" { send "y\r"; exp_continue }
    -nocase "*proceed to wings*" { send "y\r"; exp_continue }
    eof
}
EOD

# 4. Verifikasi Direktori
cd /var/www/pterodactyl || { echo "[!] Error: Instalasi panel gagal, direktori tidak ditemukan."; exit 1; }

echo "[+] Menyiapkan file Egg JSON..."

# 5. Inject JSON Egg Node JS
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
        "ghcr.io\/parkervcp\/yolks:nodejs_24": "ghcr.io\/parkervcp\/yolks:nodejs_24",
        "ghcr.io\/parkervcp\/yolks:nodejs_23": "ghcr.io\/parkervcp\/yolks:nodejs_23",
        "ghcr.io\/parkervcp\/yolks:nodejs_22": "ghcr.io\/parkervcp\/yolks:nodejs_22",
        "ghcr.io\/parkervcp\/yolks:nodejs_21": "ghcr.io\/parkervcp\/yolks:nodejs_21",
        "ghcr.io\/parkervcp\/yolks:nodejs_20": "ghcr.io\/parkervcp\/yolks:nodejs_20",
        "ghcr.io\/parkervcp\/yolks:nodejs_19": "ghcr.io\/parkervcp\/yolks:nodejs_19",
        "ghcr.io\/parkervcp\/yolks:nodejs_18": "ghcr.io\/parkervcp\/yolks:nodejs_18",
        "ghcr.io\/parkervcp\/yolks:nodejs_17": "ghcr.io\/parkervcp\/yolks:nodejs_17",
        "ghcr.io\/parkervcp\/yolks:nodejs_16": "ghcr.io\/parkervcp\/yolks:nodejs_16",
        "ghcr.io\/parkervcp\/yolks:nodejs_15": "ghcr.io\/parkervcp\/yolks:nodejs_15",
        "ghcr.io\/parkervcp\/yolks:nodejs_14": "ghcr.io\/parkervcp\/yolks:nodejs_14",
        "ghcr.io\/parkervcp\/yolks:nodejs_13": "ghcr.io\/parkervcp\/yolks:nodejs_13",
        "ghcr.io\/parkervcp\/yolks:nodejs_12": "ghcr.io\/parkervcp\/yolks:nodejs_12",
        "ghcr.io\/parkervcp\/yolks:nodejs_11": "ghcr.io\/parkervcp\/yolks:nodejs_11",
        "ghcr.io\/parkervcp\/yolks:nodejs_10": "ghcr.io\/parkervcp\/yolks:nodejs_10",
        "ghcr.io\/parkervcp\/yolks:nodejs_9": "ghcr.io\/parkervcp\/yolks:nodejs_9",
        "ghcr.io\/parkervcp\/yolks:nodejs_8": "ghcr.io\/parkervcp\/yolks:nodejs_8",
        "ghcr.io\/parkervcp\/yolks:nodejs_7": "ghcr.io\/parkervcp\/yolks:nodejs_7",
        "ghcr.io\/parkervcp\/yolks:nodejs_6": "ghcr.io\/parkervcp\/yolks:nodejs_6",
        "ghcr.io\/parkervcp\/yolks:nodejs_5": "ghcr.io\/parkervcp\/yolks:nodejs_5",
        "ghcr.io\/parkervcp\/yolks:nodejs_4": "ghcr.io\/parkervcp\/yolks:nodejs_4",
        "ghcr.io\/parkervcp\/yolks:nodejs_3": "ghcr.io\/parkervcp\/yolks:nodejs_3",
        "ghcr.io\/parkervcp\/yolks:nodejs_2": "ghcr.io\/parkervcp\/yolks:nodejs_2",
        "ghcr.io\/parkervcp\/yolks:nodejs_1": "ghcr.io\/parkervcp\/yolks:nodejs_1"
    },
    "file_denylist": [],
    "startup": "if [[ -d .git ]] && [[ {{AUTO_UPDATE}} == \"1\" ]]; then git pull; fi; if [[ ! -z ${NODE_PACKAGES} ]]; then \/usr\/local\/bin\/npm install ${NODE_PACKAGES}; fi; if [[ ! -z ${UNNODE_PACKAGES} ]]; then \/usr\/local\/bin\/npm uninstall ${UNNODE_PACKAGES}; fi; if [ -f \/home\/container\/package.json ]; then \/usr\/local\/bin\/npm install; fi;  if [[ ! -z ${CUSTOM_ENVIRONMENT_VARIABLES} ]]; then      vars=$(echo ${CUSTOM_ENVIRONMENT_VARIABLES} | tr \";\" \"\\n\");      for line in $vars;     do export $line;     done fi;  \/usr\/local\/bin\/${CMD_RUN};",
    "config": {
        "files": "{}",
        "startup": "{\r\n    \"done\": \"running\"\r\n}",
        "logs": "{}",
        "stop": "^^C"
    },
    "scripts": {
        "installation": {
            "script": "#!\/bin\/bash\r\n# NodeJS App Installation Script\r\n#\r\n# Server Files: \/mnt\/server\r\napt update\r\napt install -y git curl jq file unzip make gcc g++ python python-dev libtool\r\n\r\nmkdir -p \/mnt\/server\r\ncd \/mnt\/server\r\n\r\nif [ \"${USER_UPLOAD}\" == \"true\" ] || [ \"${USER_UPLOAD}\" == \"1\" ]; then\r\n    echo -e \"assuming user knows what they are doing have a good day.\"\r\n    exit 0\r\nfi\r\n\r\n## add git ending if it's not on the address\r\nif [[ ${GIT_ADDRESS} != *.git ]]; then\r\n    GIT_ADDRESS=${GIT_ADDRESS}.git\r\nfi\r\n\r\nif [ -z \"${USERNAME}\" ] && [ -z \"${ACCESS_TOKEN}\" ]; then\r\n    echo -e \"using anon api call\"\r\nelse\r\n    GIT_ADDRESS=\"https:\/\/${USERNAME}:${ACCESS_TOKEN}@$(echo -e ${GIT_ADDRESS} | cut -d\/ -f3-)\"\r\nfi\r\n\r\n## pull git js repo\r\nif [ \"$(ls -A \/mnt\/server)\" ]; then\r\n    echo -e \"\/mnt\/server directory is not empty.\"\r\n    if [ -d .git ]; then\r\n        echo -e \".git directory exists\"\r\n        if [ -f .git\/config ]; then\r\n            echo -e \"loading info from git config\"\r\n            ORIGIN=$(git config --get remote.origin.url)\r\n        else\r\n            echo -e \"files found with no git config\"\r\n            echo -e \"closing out without touching things to not break anything\"\r\n            exit 10\r\n        fi\r\n    fi\r\n\r\n    if [ \"${ORIGIN}\" == \"${GIT_ADDRESS}\" ]; then\r\n        echo \"pulling latest from github\"\r\n        git pull\r\n    fi\r\nelse\r\n    echo -e \"\/mnt\/server is empty.\\ncloning files into repo\"\r\n    if [ -z ${BRANCH} ]; then\r\n        echo -e \"cloning default branch\"\r\n        git clone ${GIT_ADDRESS} .\r\n    else\r\n        echo -e \"cloning ${BRANCH}'\"\r\n        git clone --single-branch --branch ${BRANCH} ${GIT_ADDRESS} .\r\n    fi\r\n\r\nfi\r\n\r\necho \"Installing nodejs packages\"\r\nif [[ ! -z ${NODE_PACKAGES} ]]; then\r\n    \/usr\/local\/bin\/npm install ${NODE_PACKAGES}\r\nfi\r\n\r\nif [ -f \/mnt\/server\/package.json ]; then\r\n    \/usr\/local\/bin\/npm install --production\r\nfi\r\n\r\necho -e \"install complete\"\r\nexit 0",
            "container": "node:14-buster-slim",
            "entrypoint": "bash"
        }
    },
    "variables": [
        {
            "name": "Git Repo Address",
            "description": "GitHub Repo to clone\r\n\r\nI.E. https:\/\/github.com\/user_name\/repo_name",
            "env_variable": "GIT_ADDRESS",
            "default_value": "",
            "user_viewable": true,
            "user_editable": true,
            "rules": "nullable|string",
            "field_type": "text"
        },
        {
            "name": "Install Branch",
            "description": "The branch to install.",
            "env_variable": "BRANCH",
            "default_value": "",
            "user_viewable": true,
            "user_editable": true,
            "rules": "nullable|string",
            "field_type": "text"
        },
        {
            "name": "Git Username",
            "description": "Username to auth with git.",
            "env_variable": "USERNAME",
            "default_value": "",
            "user_viewable": true,
            "user_editable": true,
            "rules": "nullable|string",
            "field_type": "text"
        },
        {
            "name": "Git Access Token",
            "description": "Password to use with git.\r\n\r\nIt's best practice to use a Personal Access Token.\r\nhttps:\/\/github.com\/settings\/tokens\r\nhttps:\/\/gitlab.com\/-\/profile\/personal_access_tokens",
            "env_variable": "ACCESS_TOKEN",
            "default_value": "",
            "user_viewable": true,
            "user_editable": true,
            "rules": "nullable|string",
            "field_type": "text"
        },
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

echo "[+] Memulai injeksi Database (Node, Allocation, Config Wings, Nest, dan Egg)..."

# 6. Script PHP untuk bypass API dan injeksi database sesuai skema official
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

    $location = Location::firstOrCreate([
        'short' => 'ID',
        'long' => 'Indonesia',
    ]);

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
        'daemon_base' => '/var/lib/pterodactyl/volumes',
        'daemon_sftp' => 2022,
        'daemon_listen' => 8080,
        'behind_proxy' => 0,
        'maintenance_mode' => 0,
        'public' => 1,
        'upload_size' => 100,
    ];
    $node = $nodeService->handle($nodeData);

    $allocations = [];
    for ($i = 7777; $i <= 7877; $i++) {
        $allocations[] = [
            'node_id' => $node->id,
            'ip' => $fqdn,
            'ip_alias' => null,
            'port' => $i
        ];
    }
    Allocation::insert($allocations);

    $configArray = app()->make(NodeConfigurationService::class)->handle($node);
    $yaml = Yaml::dump($configArray, 4, 2);
    if (!is_dir('/etc/pterodactyl')) {
        mkdir('/etc/pterodactyl', 0755, true);
    }
    file_put_contents('/etc/pterodactyl/config.yml', $yaml);

    $nest = Nest::firstOrCreate([
        'author' => getenv('ADMIN_EMAIL'),
        'name' => 'Lyyncode Bots',
        'description' => 'Custom Nest untuk layanan Lyyncode'
    ]);

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

echo "[+] Konfigurasi database berhasil diselesaikan."
echo "[+] Mengaktifkan layanan Wings secara aman..."

systemctl enable wings
systemctl stop wings
sleep 2
systemctl start wings

echo ""
echo "=================================================="
echo " Sukses install panel + node auto ijo "
echo "=================================================="
echo " URL Panel : $PANEL_DOMAIN"
echo " Username  : $ADMIN_USER"
echo " Password  : $ADMIN_PASS"
echo "=================================================="
