#!/bin/bash

# ==========================================
# SKA HOST - Ultimate Installer & 503 Fixer
# ==========================================

# Terminal Colors & UI Elements
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

clear
echo -e "${CYAN}╭──────────────────────────────────────────────────────────────────────────────╮${RESET}"
echo -e "${CYAN}│${RESET}       🚀 ${MAGENTA}${BOLD}Plugin Manager Addon - Ultimate Installer${RESET} 🚀               ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}                  ✨ ${WHITE}Secured by SKA HOST (SDGAMER)${RESET} ✨                    ${CYAN}│${RESET}"
echo -e "${CYAN}╰──────────────────────────────────────────────────────────────────────────────╯${RESET}\n"

echo -e "${CYAN}💡 [INFO] Running official commands first... ⚙️${RESET}\n"

# ==========================================
# 1. OFFICIAL COMMANDS
# ==========================================
sudo curl -Lo auto-install.sh https://raw.githubusercontent.com/chlewtf/plugin-manager-addon/main/auto-install.sh
sudo chmod u+x auto-install.sh
sudo ./auto-install.sh

# Capture the exit status of the official script
INSTALL_STATUS=$?

echo -e "\n${CYAN}──────────────────────────────────────────────────────────────────────────────${RESET}"

# ==========================================
# 2. FALLBACK & OLD FIX LOGIC (If Error Occurs)
# ==========================================
if [ $INSTALL_STATUS -ne 0 ]; then
    echo -e "${RED}❌ [ERROR] The official script crashed or failed!${RESET}"
    echo -e "${YELLOW}⚠️ [WARNING] Starting SKA HOST Manual Fallback Installation... 🛠️${RESET}\n"
    
    # --- YOUR MANUAL INSTALLATION COMMANDS ---
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Cloning and copying files... 📂${RESET}"
    cd /tmp
    rm -rf plugin-manager-addon # Clean up old clone if it exists
    git clone https://github.com/chlewtf/plugin-manager-addon
    cd plugin-manager-addon
    cp -R * /var/www/pterodactyl/
    cd /var/www/pterodactyl

    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Installing Node.js 18... ⚙️${RESET}"
    # Smart OS Detection for Node.js Installation
    if [ -f /etc/debian_version ]; then
        # Ubuntu/Debian
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo -e "${RED}❌ Unsupported OS for automated Node.js installation.${RESET}"
    fi

    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Checking Node & NPM Versions... 🔍${RESET}"
    node --version
    npm --version

    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Building Panel Production (This may take a while)... ☕${RESET}"
    npm install --legacy-peer-deps # Added legacy flag to prevent dependency errors
    npm run build:production
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Clearing cache... 🧹${RESET}"
    php artisan cache:clear

    # --- THE OLD 503 FIX LOGIC ---
    echo -e "\n${YELLOW}⚠️ [WARNING] Running SKA HOST 503 Rescue Logic... 🚑${RESET}"
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Optimizing views and clearing extra cache... 🧹${RESET}"
    php artisan optimize:clear > /dev/null 2>&1
    php artisan view:clear > /dev/null 2>&1
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Restoring correct file permissions... 📂${RESET}"
    chown -R www-data:www-data /var/www/pterodactyl/*
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Bringing panel out of maintenance mode... 🌐${RESET}"
    php artisan up
    
    echo -e "\n${GREEN}✅ [SUCCESS] Fallback installation complete & panel rescued! LIVE without 503 Error.${RESET}"

else
    # If no error occurs
    echo -e "${GREEN}✅ [SUCCESS] Official script completed successfully! No fallback needed.${RESET}"
fi

# Cleanup
cd /var/www/pterodactyl
rm -f /root/auto-install.sh
rm -f auto-install.sh
echo -e "\n${CYAN}💡 [INFO] Temporary files cleaned up. SKA HOST Installer finished! 👋${RESET}"
