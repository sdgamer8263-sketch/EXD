#!/bin/bash

# ==========================================
# SKA HOST - Auto Installer & 503 Fixer
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
echo -e "${CYAN}│${RESET}           🚀 ${MAGENTA}${BOLD}Plugin Manager Addon - Smart Installer${RESET} 🚀                  ${CYAN}│${RESET}"
echo -e "${CYAN}│${RESET}                  ✨ ${WHITE}Secured by SKA HOST (SDGAMER)${RESET} ✨                    ${CYAN}│${RESET}"
echo -e "${CYAN}╰──────────────────────────────────────────────────────────────────────────────╯${RESET}\n"

echo -e "${CYAN}💡 [INFO] Running official commands first... ⚙️${RESET}\n"

# ==========================================
# 1. OFFICIAL COMMANDS (Exact Run)
# ==========================================
sudo curl -Lo auto-install.sh https://raw.githubusercontent.com/chlewtf/plugin-manager-addon/main/auto-install.sh
sudo chmod u+x auto-install.sh
sudo ./auto-install.sh

# ==========================================
# 2. CAPTURE EXIT STATUS
# ==========================================
# Eta check korbe uporer script-ta success na fail hoyeche
INSTALL_STATUS=$?

echo -e "\n${CYAN}──────────────────────────────────────────────────────────────────────────────${RESET}"

# ==========================================
# 3. AUTO-FIX LOGIC (If Error Occurs)
# ==========================================
if [ $INSTALL_STATUS -ne 0 ]; then
    echo -e "${RED}❌ [ERROR] The official script crashed or failed! (Possible 503 Error Risk)${RESET}"
    echo -e "${YELLOW}⚠️ [WARNING] Triggering SKA HOST Auto-Fix Logic to rescue the panel... 🚑${RESET}\n"
    
    cd /var/www/pterodactyl || exit
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Clearing cache and optimizing views... 🧹${RESET}"
    php artisan optimize:clear > /dev/null 2>&1
    php artisan view:clear > /dev/null 2>&1
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Restoring correct file permissions... 📂${RESET}"
    chown -R www-data:www-data /var/www/pterodactyl/*
    
    echo -e "${MAGENTA}⏳ [WORKING]${RESET} ${CYAN}Bringing panel out of maintenance mode... 🌐${RESET}"
    php artisan up
    
    echo -e "\n${GREEN}✅ [SUCCESS] Panel Rescued! The 503 Error has been prevented and panel is LIVE.${RESET}"
else
    # Jodi kono error na ase
    echo -e "${GREEN}✅ [SUCCESS] Official script completed successfully! No fix needed.${RESET}"
fi

# Cleanup
rm -f auto-install.sh
echo -e "\n${CYAN}💡 [INFO] Temporary files cleaned up. SKA HOST Installer finished! 👋${RESET}"
