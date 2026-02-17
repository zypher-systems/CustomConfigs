#!/bin/bash
set -e

# --- Pre-flight Checks ---
if [ "$EUID" -eq 0 ]; then
  echo "❌ Error: Please do NOT run this script as root."
  echo "   Run it as your regular user. The script will ask for sudo password when needed."
  exit 1
fi

echo "🚀 Starting ZypherOS Post-Install Configuration..."

# --- 1. Repositories ---
echo "📦 Configuring Repositories..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "   Enabling multilib..."
    sudo sed -i '/^\#\[multilib\]/,/^\#Include = \/etc\/pacman\.d\/mirrorlist/ s/^\#//' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
else
    echo "   Multilib already active."
fi

# --- 2. Package Installation ---
echo "📦 Installing Packages..."

PACKAGES=(
    # Core Tools
    base-devel
    git
    fastfetch
    fish
    neovim          # Added for your config (EDITOR=nvim)
    starship        # Added for your prompt
    zoxide          # Added for your config
    thefuck         # Added for your config
    eza             # Required for your aliases
    bat             # Required for your aliases
    btop

    # Desktop
    plasma-meta
    dolphin
    konsole
    sddm
    sddm-kcm

    # Apps
    ghostty
    gwenview
    okular
    gimp
    blender
    inkscape
    libreoffice-fresh
    pika-backup
    obs-studio
    flatpak

    # Fonts
    ttf-meslo-nerd
    noto-fonts
)

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

# --- 3. Enable Services ---
echo "🔌 Enabling Services..."
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# --- 4. Flatpak Setup ---
echo "📦 Setting up Flatpaks..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

FLATPAKS=(
    it.mijorus.gearlever
    com.github.tchx84.Flatseal
    com.google.Chrome
)

for pkg in "${FLATPAKS[@]}"; do
    flatpak install -y flathub "$pkg"
done

# --- 5. AUR Helper (yay) ---
if ! command -v yay &> /dev/null; then
    echo "📦 Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd ~ && rm -rf /tmp/yay
fi
echo "📦 Installing AUR Packages..."
yay -S --noconfirm visual-studio-code-bin

# --- 6. Ghostty Configuration ---
echo "🎨 Configuring Ghostty..."
mkdir -p "$HOME/.config/ghostty/themes"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
CARBONFOX_THEME="$HOME/.config/ghostty/themes/carbonfox"

# Create Carbonfox Theme
cat > "$CARBONFOX_THEME" << 'EOF'
palette = 0=#282828
palette = 1=#ee5396
palette = 2=#25be6a
palette = 3=#08bdba
palette = 4=#78a9ff
palette = 5=#be95ff
palette = 6=#33b1ff
palette = 7=#dfdfe0
palette = 8=#484848
palette = 9=#f16da6
palette = 10=#46c880
palette = 11=#2dc7c4
palette = 12=#8cb6ff
palette = 13=#c8a5ff
palette = 14=#52bdff
palette = 15=#e4e4e5
background = 161616
foreground = f2f4f8
cursor-color = e4e4e5
selection-background = 2a2a2a
selection-foreground = f2f4f8
EOF

# Write Ghostty Config
if ! grep -q "shell-integration = fish" "$GHOSTTY_CONFIG" 2>/dev/null; then
    cat >> "$GHOSTTY_CONFIG" << EOF
command = /usr/bin/fish
font-family = MesloLGS Nerd Font Mono
font-family-bold = MesloLGS Nerd Font Mono Bold
font-family-italic = MesloLGS Nerd Font Mono Italic
font-size = 14
background-opacity = 0.9
theme = carbonfox
shell-integration = fish
EOF
fi

# --- 7. Fish Shell Configuration (Custom Zypher Config) ---
echo "🐠 Configuring Fish Shell..."
mkdir -p "$HOME/.config/fish"

cat > "$HOME/.config/fish/config.fish" << 'EOF'
# ===============================================
# 🌊 Zypher Systems - Enhanced Fish Configuration
# ===============================================

if status is-interactive
    # ===== ENVIRONMENT VARIABLES =====
    set -gx EDITOR nvim
    set -gx BROWSER firefox
    set -gx PAGER less
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

    # Enhanced colors
    set -gx TERM xterm-256color
    set -gx COLORTERM truecolor
    set -gx CLICOLOR 1

    # ===== FISH SHELL ENHANCEMENTS =====
    fish_vi_key_bindings
    set fish_greeting

    # Color scheme
    set fish_color_normal normal
    set fish_color_command 00d7ff
    set fish_color_quote a8cc8c
    set fish_color_redirection ff6b9d
    set fish_color_end ff6b9d
    set fish_color_error ff5555
    set fish_color_param d7d7d7
    set fish_color_comment 6272a4
    set fish_color_match --background=brblue
    set fish_color_selection white --bold --background=brblack
    set fish_color_search_match bryellow --background=brblack
    set fish_color_history_current --bold
    set fish_color_operator ff79c6
    set fish_color_escape 8be9fd
    set fish_color_cwd green
    set fish_color_cwd_root red
    set fish_color_valid_path --underline
    set fish_color_autosuggestion 6272a4
    set fish_color_user brgreen
    set fish_color_host normal

    # ===== CUSTOM ALIASES =====
    alias ls 'eza --color=always --group-directories-first --icons'
    alias ll 'eza -alF --color=always --group-directories-first --icons'
    alias la 'eza -a --color=always --group-directories-first --icons'
    alias lt 'eza -aT --color=always --group-directories-first --icons'
    alias l. 'eza -a | grep -E "^\."'

    # Git
    alias g 'git'
    alias gs 'git status -sb'
    alias gl 'git log --oneline --graph --decorate --all'
    alias gd 'git diff --color=always'

    # System
    alias sysinfo 'fastfetch'
    alias weather 'curl -s "wttr.in?format=3"'
    alias myip 'curl -s ifconfig.me'
    alias ports 'netstat -tuln'
    alias cat 'bat --style=numbers,changes,header'
    alias less 'bat --paging=always'

    # Navigation
    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias .... 'cd ../../..'

    # Monitoring
    alias htop 'btop'
    alias df 'df -h'
    alias du 'du -h'
    alias free 'free -h'

    # Misc
    alias grep 'grep --color=auto'
    alias mkdir 'mkdir -pv'
    alias wget 'wget -c'
    alias reload 'source ~/.config/fish/config.fish'

    # ===== CUSTOM FUNCTIONS =====
    function cd
        builtin cd $argv
        and ls
    end

    function extract
        switch $argv[1]
            case '*.tar.bz2'; tar xjf $argv[1] ;;
            case '*.tar.gz'; tar xzf $argv[1] ;;
            case '*.bz2'; bunzip2 $argv[1] ;;
            case '*.rar'; unrar x $argv[1] ;;
            case '*.gz'; gunzip $argv[1] ;;
            case '*.tar'; tar xf $argv[1] ;;
            case '*.tbz2'; tar xjf $argv[1] ;;
            case '*.tgz'; tar xzf $argv[1] ;;
            case '*.zip'; unzip $argv[1] ;;
            case '*.7z'; 7z x $argv[1] ;;
            case '*'; echo "Unknown archive format" ;;
        end
    end

    function update
        echo "🔄 Updating system packages..."
        if command -v pacman >/dev/null
            sudo pacman -Syu
        else
            echo "Package manager not recognized"
        end
    end

    function netinfo
        echo "🌐 Network Information:"
        echo "External IP: "(curl -s ifconfig.me)
        echo "Local IP: "(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
        echo "DNS: "(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -1)
    end

    # ===== STARSHIP PROMPT =====
    if command -v starship >/dev/null
        starship init fish | source
    end

    # ===== WELCOME MESSAGE =====
    function fish_greeting
        set_color cyan
        echo "╭────────────────────────────────────────────────────────────╮"
        set_color normal
        set_color --bold blue
        printf "│ 🚀 %-55s │\n" "Zypher Terminal - Enhanced Experience"
        set_color normal
        set_color yellow
        printf "│ 📅 %-55s │\n" (date "+%A, %B %d, %Y at %I:%M %p")
        set_color normal
        set_color green
        set -l uptime_info (cat /proc/uptime | cut -d' ' -f1)
        set -l uptime_hours (math "floor($uptime_info / 3600)")
        set -l uptime_minutes (math "floor(($uptime_info % 3600) / 60)")
        printf "│ 💾 %-55s │\n" "Uptime: $uptime_hours hours, $uptime_minutes minutes"
        set_color normal
        set_color magenta
        set -l host_name (cat /etc/hostname 2>/dev/null || echo "Unknown")
        printf "│ 🖥️ %-55s │\n" "Host: $host_name"
        set_color normal
        set_color red
        printf "│ 👤 %-55s │\n" "User: $USER"
        set_color normal
        set_color blue
        printf "│ 🐚 %-55s │\n" "Shell: Fish "(fish --version | string match -r '\d+\.\d+\.\d+')
        set_color normal
        set_color cyan
        echo "╰────────────────────────────────────────────────────────────╯"
        set_color normal
        echo
        set_color --dim white
        echo "💡 Tips: Use 'sysinfo' for detailed system info (Fastfetch)"
        set_color normal
        echo
    end

    # ===== FINAL SETUP =====
    set -gx PATH $HOME/.local/bin $PATH

    if command -v zoxide >/dev/null
        zoxide init fish | source
    end

    if command -v thefuck >/dev/null
        thefuck --alias | source
    end
end
EOF

# --- 8. Fastfetch Configuration (RESTORED ZYPHER CONFIG) ---
echo "📝 Installing Fastfetch Config..."
mkdir -p "$HOME/.config/fastfetch"
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
