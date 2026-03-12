#!/bin/bash

# Color Definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# SDGAMER Banner Function
print_banner() {
    echo -e "${BLUE}"
    echo "  __________________________________________________________"
    echo " /                                                          \\"
    echo " |    ____  ____   ____    _    __  __ _____ ____           |"
    echo " |   / ___||  _ \ / ___|  / \  |  \/  | ____|  _ \          |"
    echo " |   \___ \| | | | |  _  / _ \ | |\/| |  _| | |_) |         |"
    echo " |    ___) | |_| | |_| |/ ___ \| |  | | |___|  _ <          |"
    echo " |   |____/|____/ \____/_/   \_\_|  |_|_____|_| \_\         |"
    echo " |                                                          |"
    echo " |                AUTO-SUSPENSION MODULE                    |"
    echo " |            Installation Powered by SAGA AI               |"
    echo " \__________________________________________________________/"
    echo -e "${NC}"
}

print_message() {
    echo -e "${GREEN}[SAGA]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[SAGA]${NC} $1"
}

print_error() {
    echo -e "${RED}[SAGA]${NC} $1"
}

print_question() {
    echo -e "${BLUE}[SAGA]${NC} $1"
}

# Initial Checks
print_warning "Auto Installer may not work if you are using a custom theme. Continue? (y/n): "
read -r continue_install

if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
    print_message "Please do Manual Installation. Join: https://discord.gg/DU8cjUJjeN"
    exit 0
fi

print_question "Have you uploaded the required files? (SuspendExpiredServers.php and migration) (y/n): "
read -r files_uploaded

if [[ ! "$files_uploaded" =~ ^[Yy]$ ]]; then
    print_error "Please upload the required files before proceeding."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

if [ ! -f "artisan" ]; then
    print_error "Please run this script from the root of your Pterodactyl installation (/var/www/pterodactyl)"
    exit 1
fi

# Step 0: Backups
print_message "Creating backups of files to be modified..."
FILES_TO_BACKUP=(
    "app/Models/Server.php"
    "resources/views/admin/servers/new.blade.php"
    "resources/views/admin/servers/view/build.blade.php"
    "app/Services/Servers/ServerCreationService.php"
    "app/Services/Servers/BuildModificationService.php"
    "app/Http/Controllers/Admin/ServersController.php"
    "app/Console/Kernel.php"
    "app/Transformers/Api/Client/ServerTransformer.php"
    "resources/scripts/api/server/getServer.ts"
    "resources/scripts/components/server/console/ServerConsoleContainer.tsx"
    "resources/scripts/components/dashboard/ServerRow.tsx"
)

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "${file}.saga"
        print_message "Backed up $file"
    else
        print_warning "File $file not found, skipping backup"
    fi
done

# Step 1-2: Update Server Model
print_message "Updating Server model..."
SERVER_MODEL="app/Models/Server.php"
if grep -q "expiration_date" "$SERVER_MODEL"; then
    print_warning "Server model already updated."
else
    sed -i '/* @property \\Illuminate\\Support\\Carbon|null $installed_at/a\ * @property \\Illuminate\\Support\\Carbon|null $expiration_date' "$SERVER_MODEL"
    sed -i "/'installed_at' => 'datetime'/a\        'expiration_date' => 'datetime'," "$SERVER_MODEL"
fi

# Step 3: Admin New Server View
print_message "Updating server creation form..."
NEW_BLADE="resources/views/admin/servers/new.blade.php"
if ! grep -q "expiration_date" "$NEW_BLADE"; then
    sed -i "/<form action=\"{{ route('admin.servers.new') }}\" method=\"POST\">/a\\
    <div class=\"row\">\\
        <div class=\"col-xs-12\">\\
            <div class=\"box\">\\
            <div class=\"box-header with-border\">\\
                    <h3 class=\"box-title\">Auto Suspension</h3>\\
                </div>\\
                <div class=\"box-body row\">\\
                    <div class=\"form-group col-md-6\">\\
                        <label for=\"pExpirationDate\" class=\"control-label\">Expiration Date</label>\\
                        <div>\\
                            <input type=\"datetime-local\" id=\"pExpirationDate\" name=\"expiration_date\" class=\"form-control\" />\\
                        </div>\\
                        <p class=\"text-muted small\">The date when this server will be automatically suspended.</p>\\
                    </div>\\
                </div>\\
            </div>\\
        </div>\\
    </div>" "$NEW_BLADE"
fi

# Step 4: Admin Build View
BUILD_BLADE="resources/views/admin/servers/view/build.blade.php"
if ! grep -q "expiration_date" "$BUILD_BLADE"; then
    sed -i "/<form action=\"{{ route('admin.servers.view.build', \$server->id) }}\" method=\"POST\">/a\\
        <div class=\"col-sm-12\">\\
            <div class=\"box\">\\
                <div class=\"box-header with-border\">\\
                    <h3 class=\"box-title\">Auto Suspension</h3>\\
                </div>\\
                <div class=\"box-body\">\\
                    <div class=\"form-group\">\\
                        <label for=\"expiration_date\" class=\"control-label\">Expiration Date</label>\\
                        <div>\\
                            <input type=\"datetime-local\" id=\"expiration_date\" name=\"expiration_date\" class=\"form-control\" value=\"{{ \$server->expiration_date ? \\\\Carbon\\\\Carbon::parse(\$server->expiration_date)->format('Y-m-d\\\\TH:i') : '' }}\" />\\
                        </div>\\
                    </div>\\
                </div>\\
            </div>\\
        </div>" "$BUILD_BLADE"
fi

# Step 5-7: Controller & Services
sed -i "/'backup_limit' => Arr::get(\$data, 'backup_limit') ?? 0,/a\            'expiration_date' => Arr::get(\$data, 'expiration_date')," "app/Services/Servers/ServerCreationService.php"
sed -i "s/'allocation_id'\]);/'allocation_id', 'expiration_date'\]);/" "app/Services/Servers/BuildModificationService.php"
sed -i "/'oom_disabled',/a\            'expiration_date'," "app/Http/Controllers/Admin/ServersController.php"

# Step 9: Kernel Cron
KERNEL="app/Console/Kernel.php"
if ! grep -q "SuspendExpiredServers" "$KERNEL"; then
    sed -i "/use Pterodactyl\\\\Console\\\\Commands\\\\Schedule\\\\ProcessRunnableCommand;/a use Pterodactyl\\\\Console\\\\Commands\\\\SuspendExpiredServers;" "$KERNEL"
    sed -i "/\$schedule->command(CleanServiceBackupFilesCommand::class)->daily();/a\        \$schedule->command(SuspendExpiredServers::class)->everyMinute()->withoutOverlapping();" "$KERNEL"
fi

# Step 10-13: Frontend (API & React)
sed -i "/'is_transferring' => !is_null(\$server->transfer),/a\            'expiration_date' => \$server->expiration_date," "app/Transformers/Api/Client/ServerTransformer.php"
sed -i "/allocations: Allocation\[\];/a\    expiration_date: string | null;" "resources/scripts/api/server/getServer.ts"
sed -i "/isTransferring: data.is_transferring,/a\    expiration_date: data.expiration_date || null," "resources/scripts/api/server/getServer.ts"

# Step 15: Build Assets
print_message "Building panel assets (this may take a few minutes)..."
php artisan down
export NODE_OPTIONS=--openssl-legacy-provider

# Ensure Dependencies
if ! command -v yarn &> /dev/null; then npm i -g yarn; fi

yarn install
yarn build:production

# Finalize
php artisan migrate --force
php artisan cache:clear
php artisan view:clear
php artisan config:clear
php artisan optimize
chown -R www-data:www-data *
php artisan up

# Success
print_banner
print_message "Installation Complete! Your servers can now be auto-suspended based on expiration dates."

