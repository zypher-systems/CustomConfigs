#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# --- Pre-flight Checks ---
if [ "$EUID" -eq 0 ]; then
  echo "❌ Error: Please do NOT run this script as root."
  echo "   Run it as your regular user. The script will ask for sudo password when needed."
  exit 1
fi

echo "🚀 Starting ZypherOS Post-Install Configuration..."

# --- 1. System Repositories ---
echo "📦 Configuring Repositories..."

# Enable multilib repository
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "   Enabling multilib repository..."
    sudo sed -i '/^\#\[multilib\]/,/^\#Include = \/etc\/pacman\.d\/mirrorlist/ s/^\#//' /etc/pacman.conf
    echo "   Updating package database..."
    sudo pacman -Syu --noconfirm
else
    echo "   Multilib repository already enabled."
fi

# --- 2. Pacman Packages ---
echo "📦 Installing Base Packages..."
# Added 'ttf-meslo-nerd' because your ghostty config asks for it.
PACKAGES=(
    base-devel
    git
    fastfetch
    fish
    ghostty
    gwenview
    okular
    gimp
    blender
    inkscape
    libreoffice-fresh
    pika-backup
    obs-studio
    eza
    bat
    btop
    flatpak
    ttf-meslo-nerd
)

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

# --- 3. Flatpak Setup ---
echo "📦 Setting up Flatpaks..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

FLATPAKS=(
    it.mijour.gearlever
    com.github.tchx84.Flatseal
    com.google.Chrome
)

for pkg in "${FLATPAKS[@]}"; do
    flatpak install -y flathub "$pkg"
done

# --- 4. AUR Helper (yay) ---
if ! command -v yay &> /dev/null; then
    echo "📦 Installing yay..."
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "   yay is already installed."
fi

# --- 5. AUR Packages ---
echo "📦 Installing AUR Packages..."
yay -S --noconfirm visual-studio-code-bin

# --- 6. Ghostty Configuration ---
echo "🎨 Configuring Ghostty..."
mkdir -p "$HOME/.config/ghostty"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

if ! grep -q "shell-integration = fish" "$GHOSTTY_CONFIG" 2>/dev/null; then
    cat >> "$GHOSTTY_CONFIG" << EOF

# Custom configuration added by ZypherOS script
command = /usr/bin/fish
font-family = MesloLGS Nerd Font Mono
font-family-bold = MesloLGS Nerd Font Mono Bold
font-family-italic = MesloLGS Nerd Font Mono Italic
font-size = 14
background-opacity = 0.9
theme = carbonfox
shell-integration = fish
EOF
else
    echo "   Ghostty already configured."
fi

# --- 7. Fish Shell Configuration ---
echo "🐠 Configuring Fish Shell..."
mkdir -p "$HOME/.config/fish/functions"

# Writing fish_prompt.fish
cat > "$HOME/.config/fish/functions/fish_prompt.fish" << 'EOF'
function fish_prompt
    set -l __last_command_exit_status $status
    if not set -q -g __fish_arrow_functions_defined
        set -g __fish_arrow_functions_defined
        function __git_branch_name
            set -l branch (git symbolic-ref --quiet HEAD 2>/dev/null)
            if set -q branch[1]
                echo (string replace -r '^refs/heads/' '' $branch)
            else
                echo (git rev-parse --short HEAD 2>/dev/null)
            end
        end
        function __is_git_dirty
            not command git diff-index --cached --quiet HEAD -- &>/dev/null
            or not command git diff --no-ext-diff --quiet --exit-code &>/dev/null
        end
        function __is_git_repo
            type -q git
            or return 1
            git rev-parse --git-dir >/dev/null 2>&1
        end
        function __hg_branch_name
            echo (hg branch 2>/dev/null)
        end
        function __is_hg_dirty
            set -l stat (hg status -mard 2>/dev/null)
            test -n "$stat"
        end
        function __is_hg_repo
            fish_print_hg_root >/dev/null 2>&1
        end
        function __repo_branch_name
            switch $argv[1]
                case git
                    __git_branch_name
                case hg
                    __hg_branch_name
            end
        end
        function __is_repo_dirty
            switch $argv[1]
                case git
                    __is_git_dirty
                case hg
                    __is_hg_dirty
            end
        end
        function __repo_type
            if __is_hg_repo
                echo hg
                return 0
            else if __is_git_repo
                echo git
                return 0
            end
            return 1
        end
    end
    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l red (set_color -o red)
    set -l green (set_color -o green)
    set -l blue (set_color -o blue)
    set -l normal (set_color normal)
    set -l arrow_color "$green"
    if test $__last_command_exit_status != 0
        set arrow_color "$red"
    end
    set -l arrow "$arrow_color➜ "
    if fish_is_root_user
        set arrow "$arrow_color# "
    end
    set -l cwd $cyan(prompt_pwd | path basename)
    set -l repo_info
    if set -l repo_type (__repo_type)
        set -l repo_branch $red(__repo_branch_name $repo_type)
        set repo_info "$blue $repo_type:($repo_branch$blue)"
        if __is_repo_dirty $repo_type
            set -l dirty "$yellow ✗"
            set repo_info "$repo_info$dirty"
        end
    end
    echo -n -s $arrow ' '$cwd $repo_info $normal ' '
end
EOF

# --- 8. Fastfetch Configuration ---
echo "📝 Installing Fastfetch Config..."
mkdir -p "$HOME/.config/fastfetch"

# Writing config.jsonc
cat > "$HOME/.config/fastfetch/config.jsonc" << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "builtin",
        "height": 15,
        "width": 30,
        "padding": {
            "top": 5,
            "left": 3
        }
    },
    "modules": [
        "break",
        {
            "type": "custom",
            "format": "\u001b[1;32m╭──────────────────────── \u001b[1;97mHardware\u001b[1;32m ────────────────────────╮"
        },
        {
            "type": "host",
            "key": "\u001b[1;32m│ \u001b[1;97m \u001b[1;32mPC",
            "keyColor": "bright_green"
        },
        {
            "type": "cpu",
            "key": "\u001b[1;32m│ \u001b[1;97m \u001b[1;32mCPU",
            "keyColor": "bright_green"
        },
        {
            "type": "gpu",
            "key": "\u001b[1;32m│ \u001b[1;97m \u001b[1;32mGPU",
            "keyColor": "bright_green"
        },
        {
            "type": "memory",
            "key": "\u001b[1;32m│ \u001b[1;97m \u001b[1;32mRAM",
            "keyColor": "bright_green"
        },
        {
            "type": "disk",
            "key": "\u001b[1;32m│ \u001b[1;97m \u001b[1;32mStorage",
            "keyColor": "bright_green"
        },
        {
            "type": "custom",
            "format": "\u001b[1;32m╰──────────────────────────────────────────────────────────╯"
        },
        "break",
        {
            "type": "custom",
            "format": "\u001b[1;33m╭──────────────────────── \u001b[1;97mSoftware\u001b[1;33m ────────────────────────╮"
        },
        {
            "type": "os",
            "key": "\u001b[1;33m│ \u001b[1;97m \u001b[1;33mOS",
            "keyColor": "bright_yellow"
        },
        {
            "type": "kernel",
            "key": "\u001b[1;33m│ \u001b[1;97m \u001b[1;33mKernel",
            "keyColor": "bright_yellow"
        },
        {
            "type": "bios",
            "key": "\u001b[1;33m│ \u001b[1;97m \u001b[1;33mBIOS",
            "keyColor": "bright_yellow"
        },
        {
            "type": "packages",
            "key": "\u001b[1;33m│ \u001b[1;97m \u001b[1;33mPackages",
            "keyColor": "bright_yellow"
        },
        {
            "type": "shell",
            "key": "\u001b[1;33m│ \u001b[1;97m \u001b[1;33mShell",
            "keyColor": "bright_yellow"
        },
        {
            "type": "custom",
            "format": "\u001b[1;33m╰──────────────────────────────────────────────────────────╯"
        },
        "break",
        {
            "type": "custom",
            "format": "\u001b[1;34m╭─────────────────── \u001b[1;97mDesktop Environment\u001b[1;34m ──────────────────╮"
        },
        {
            "type": "de",
            "key": "\u001b[1;34m│ \u001b[1;97m \u001b[1;34mDE",
            "keyColor": "bright_blue"
        },
        {
            "type": "lm",
            "key": "\u001b[1;34m│ \u001b[1;97m \u001b[1;34mLogin Manager",
            "keyColor": "bright_blue"
        },
        {
            "type": "wm",
            "key": "\u001b[1;34m│ \u001b[1;97m \u001b[1;34mWindow Manager",
            "keyColor": "bright_blue"
        },
        {
            "type": "wmtheme",
            "key": "\u001b[1;34m│ \u001b[1;97m \u001b[1;34mTheme",
            "keyColor": "bright_blue"
        },
        {
            "type": "terminal",
            "key": "\u001b[1;34m│ \u001b[1;97m \u001b[1;34mTerminal",
            "keyColor": "bright_blue"
        },
        {
            "type": "custom",
            "format": "\u001b[1;34m╰──────────────────────────────────────────────────────────╯"
        },
        "break",
        {
            "type": "custom",
            "format": "\u001b[1;35m╭─────────────────── \u001b[1;97mNetwork & System\u001b[1;35m ───────────────────╮"
        },
        {
            "type": "localip",
            "key": "\u001b[1;35m│ \u001b[1;97m \u001b[1;35mLocal IP",
            "keyColor": "bright_magenta"
        },
        {
            "type": "wifi",
            "key": "\u001b[1;35m│ \u001b[1;97m \u001b[1;35mWiFi",
            "keyColor": "bright_magenta"
        },
        {
            "type": "command",
            "key": "\u001b[1;35m│ \u001b[1;97m \u001b[1;35mOS Age",
            "keyColor": "bright_magenta",
            "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days"
        },
        {
            "type": "uptime",
            "key": "\u001b[1;35m│ \u001b[1;97m \u001b[1;35mUptime",
            "keyColor": "bright_magenta"
        },
        {
            "type": "datetime",
            "key": "\u001b[1;35m│ \u001b[1;97m \u001b[1;35mDateTime",
            "keyColor": "bright_magenta"
        },
        {
            "type": "custom",
            "format": "\u001b[1;35m╰────────────────────────────────────────────────────────╯"
        },
        "break",
        {
            "type": "custom",
            "format": "\u001b[1;90m                    ╭─ \u001b[1;97mPowered by Zypher Systems\u001b[1;90m ─╮"
        },
        {
            "type": "custom",
            "format": "\u001b[1;90m                    ╰─ \u001b[1;97mCustom Fastfetch Config\u001b[1;90m ───╯"
        }
    ]
}
EOF

# --- 9. Completion ---
echo "✅ ZypherOS Configuration Complete!"
echo "   Running fastfetch to verify..."
fastfetch
