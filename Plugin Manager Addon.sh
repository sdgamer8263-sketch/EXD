#!/bin/bash
# ==========================================
# Fixed & UI Upgraded Auto-Installer
# ==========================================

# Terminal Colors & UI Elements
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

INFO="${CYAN}💡 [INFO]${RESET}"
SUCCESS="${GREEN}✅ [SUCCESS]${RESET}"
ERROR="${RED}❌ [ERROR]${RESET}"
WARN="${YELLOW}⚠️ [WARNING]${RESET}"
LOADING="${MAGENTA}⏳ [WORKING]${RESET}"

# ==========================================
# Fail-Safe: Prevent 503 Error Lockout
# ==========================================
# Agar script majh me crash hota hai, toh yeh automatic panel ko live kar dega
trap 'echo -e "\n${WARN} ${YELLOW}Script interrupted! Bringing panel back online to prevent 503 error...${RESET}"; cd /var/www/pterodactyl && php artisan up; exit 1' INT TERM ERR

clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ____  ____   ____    _    __  __ _____ ____  
 / ___||  _ \ / ___|  / \  |  \/  | ____|  _ \ 
 \___ \| | | | |  _  / _ \ | |\/| |  _| | |_) |
  ___) | |_| | |_| |/ ___ \| |  | | |___|  _ < 
 |____/|____/ \____/_/   \_\_|  |_|_____|_| \_\

EOF
echo -e "${RESET}"
echo -e "${BLUE}╭──────────────────────────────────────────────────────────────────────────────╮${RESET}"
echo -e "${BLUE}│${RESET}           🚀 ${MAGENTA}${BOLD}Plugin Manager Addon - Auto Installer${RESET} 🚀                    ${BLUE}│${RESET}"
echo -e "${BLUE}│${RESET}                  ✨ ${WHITE}Optimized for SKA HOST${RESET} ✨                             ${BLUE}│${RESET}"
echo -e "${BLUE}╰──────────────────────────────────────────────────────────────────────────────╯${RESET}\n"

# 1. Update system packages safely
echo -e "${LOADING} ${CYAN}[1/8] Updating system packages... 📦${RESET}"
apt update -y -q > /dev/null 2>&1

# 2. Install required tools
echo -e "${LOADING} ${CYAN}[2/8] Installing required tools (curl, git, yarn)... 🛠️${RESET}"
apt install -y curl git > /dev/null 2>&1

# 3. Set Panel to maintenance mode
echo -e "${WARN} ${YELLOW}[3/8] Setting panel to maintenance mode... 🛑${RESET}"
cd /var/www/pterodactyl || exit 1
php artisan down

# 4. Download files
echo -e "${LOADING} ${CYAN}[4/8] Downloading addon files... 📥${RESET}"
cd /tmp || exit 1
rm -rf plugin-manager-addon
git clone -q https://github.com/chlewtf/plugin-manager-addon
cp -R plugin-manager-addon/code/* /var/www/pterodactyl/

# 5. Install Node.js 18 LTS & Yarn
echo -e "${LOADING} ${CYAN}[5/8] Installing Node.js 18 LTS & Yarn... ⚙️${RESET}"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - > /dev/null 2>&1
apt install -y nodejs > /dev/null 2>&1
npm install -g yarn > /dev/null 2>&1

NODE_VERSION=$(node -v)
echo -e "${SUCCESS} ${GREEN}[6/8] Node.js Installed: ${WHITE}$NODE_VERSION${RESET} 🎉"

# 6. Build Panel
echo -e "${LOADING} ${CYAN}[7/8] Building panel frontend (This will take a few minutes) ☕...${RESET}"
cd /var/www/pterodactyl || exit 1

# Using Yarn instead of NPM to prevent dependency errors
yarn install --network-timeout 100000
yarn build:production

# 7. Assign permissions and cleanup
echo -e "${LOADING} ${CYAN}[8/8] Setting database permissions and clearing cache... 🧹${RESET}"
chown -R www-data:www-data /var/www/pterodactyl/*
php artisan optimize:clear
php artisan view:clear

# Remove the Fail-Safe trap since we completed successfully
trap - INT TERM ERR

# 8. Complete
php artisan up
echo -e "\n${BLUE}══════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${SUCCESS} ${GREEN}${BOLD}Installation Complete! Panel is back ONLINE.${RESET} 🎉"
echo -e "${BLUE}══════════════════════════════════════════════════════════════════════════════${RESET}\n"
echo -e "${WHITE}Plugin Manager Addon has been successfully installed.${RESET}"
echo -e "${WHITE}Author: ${CYAN}chlewtf${RESET}\n"
echo -e "${YELLOW}👉 Next steps:${RESET}"
echo -e "  ${WHITE}1.${RESET} Log into your Pterodactyl Panel"
echo -e "  ${WHITE}2.${RESET} Navigate to any server"
echo -e "  ${WHITE}3.${RESET} Look for the ${CYAN}'Plugins'${RESET} tab in the sidebar"
echo -e "  ${WHITE}4.${RESET} Search for a plugin (e.g., 'EssentialsX')\n"
