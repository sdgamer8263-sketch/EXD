#!/bin/bash

# 1. Print the SDGAMER Banner
echo -e "\e[1;36m"
echo "  ____  ____   ____    _    __  __ _____ ____  "
echo " / ___||  _ \ / ___|  / \  |  \/  | ____|  _ \ "
echo " \___ \| | | | |  _  / _ \ | |\/| |  _| | |_) |"
echo "  ___) | |_| | |_| |/ ___ \| |  | | |___|  _ < "
echo " |____/|____/ \____/_/   \_\_|  |_|_____|_| \_\\"
echo -e "\e[0m"
echo -e "\e[1;32mStarting Auto-Installation for SFTP Alias...\e[0m\n"

# 2. Navigate to the Pterodactyl directory
cd /var/www/pterodactyl || { echo -e "\e[1;31mError: /var/www/pterodactyl directory not found!\e[0m"; exit 1; }

# 3. Download the patch file directly from your GitHub repo
echo -e "\e[1;33mDownloading patch file...\e[0m"
curl -sLO https://raw.githubusercontent.com/sdgamer8263-sketch/EXD/main/sftp/sftp-alias.patch

# 4. Install Git and apply the patch
echo -e "\e[1;33mInstalling Git and applying patch...\e[0m"
sudo apt-get update -y
sudo apt-get install git -y
git apply sftp-alias.patch

# 5. Finish
echo -e "\n\e[1;32mInstallation completed successfully!\e[0m"

