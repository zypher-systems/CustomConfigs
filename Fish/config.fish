# ===============================================
# 🌊 Zypher Systems - Enhanced Fish Configuration
# ===============================================
# Created by: Zypher Systems
# Shell: Fish (Premium Configuration)
# Features: Beautiful aesthetics, rich information display
# ===============================================

if status is-interactive
    # ===== ENVIRONMENT VARIABLES =====
    set -gx EDITOR nvim
    set -gx BROWSER firefox
    set -gx PAGER less
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    
    # Enhanced colors and display
    set -gx TERM xterm-256color
    set -gx COLORTERM truecolor
    set -gx CLICOLOR 1
    set -gx LS_COLORS "di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=1;34:cd=1;34:su=0;41:sg=0;46:tw=0;42:ow=0;43"

    # ===== FISH SHELL ENHANCEMENTS =====
    # Enable VI mode for advanced editing
    fish_vi_key_bindings
    
    # Enhanced greeting
    set fish_greeting
    
    # Color scheme customization
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
    set fish_color_cancel -r
    set fish_pager_color_completion normal
    set fish_pager_color_description B3A06D yellow
    set fish_pager_color_prefix white --bold --underline
    set fish_pager_color_progress brwhite --background=cyan

    # ===== CUSTOM ALIASES =====
    # Enhanced ls commands with colors and icons
    alias ls 'eza --color=always --group-directories-first --icons'
    alias ll 'eza -alF --color=always --group-directories-first --icons'
    alias la 'eza -a --color=always --group-directories-first --icons'
    alias lt 'eza -aT --color=always --group-directories-first --icons'
    alias l. 'eza -a | grep -E "^\."'
    
    # Git aliases with beautiful output
    alias g 'git'
    alias gs 'git status -sb'
    alias gl 'git log --oneline --graph --decorate --all'
    alias ga 'git add'
    alias gc 'git commit'
    alias gp 'git push'
    alias gd 'git diff --color=always'
    
    # System information aliases
    alias sysinfo 'fastfetch'
    alias weather 'curl -s "wttr.in?format=3"'
    alias myip 'curl -s ifconfig.me'
    alias ports 'netstat -tuln'
    
    # Enhanced cat with syntax highlighting
    alias cat 'bat --style=numbers,changes,header'
    alias less 'bat --paging=always'
    
    # Directory navigation
    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias .... 'cd ../../..'
    # Note: 'cd -' works natively in Fish to go to previous directory
    
    # System monitoring
    alias htop 'btop'
    alias df 'df -h'
    alias du 'du -h'
    alias free 'free -h'
    
    # Misc useful aliases
    alias grep 'grep --color=auto'
    alias mkdir 'mkdir -pv'
    alias wget 'wget -c'
    alias userlist 'cut -d: -f1 /etc/passwd'
    alias fsize 'du -sh'
    alias reload 'source ~/.config/fish/config.fish'

    # ===== CUSTOM FUNCTIONS =====
    
    # Beautiful directory listing when entering a directory
    function cd
        builtin cd $argv
        and ls
    end
    
    # Enhanced find function
    function ff
        find . -type f -name "*$argv*" 2>/dev/null
    end
    
    # Quick file editing
    function edit
        $EDITOR $argv
    end
    
    # Extract any archive
    function extract
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "Unknown archive format"
        end
    end
    
    # System update function
    function update
        echo "🔄 Updating system packages..."
        if command -v apt >/dev/null
            sudo apt update && sudo apt upgrade
        else if command -v pacman >/dev/null
            sudo pacman -Syu
        else if command -v dnf >/dev/null
            sudo dnf update
        else
            echo "Package manager not recognized"
        end
    end
    
    # Network information display
    function netinfo
        echo "🌐 Network Information:"
        echo "External IP: "(curl -s ifconfig.me)
        echo "Local IP: "(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
        echo "DNS: "(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -1)
    end
    
    # Weather function
    function weather
        if test (count $argv) -gt 0
            curl -s "wttr.in/$argv[1]"
        else
            curl -s "wttr.in"
        end
    end

    # ===== STARSHIP PROMPT =====
    # Initialize Starship for beautiful prompts
    if command -v starship >/dev/null
        starship init fish | source
    end

    # ===== PLUGIN MANAGEMENT =====
    # Fisher plugin manager auto-install
    if not functions -q fisher
        echo "🎣 Installing Fisher plugin manager..."
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    end

    # ===== WELCOME MESSAGE =====
    function fish_greeting
        # Beautiful system info display
        set_color cyan
        echo "╭────────────────────────────────────────────────────────────╮"
        set_color normal
        set_color --bold blue
        printf "│ 🚀 %-54s │\n" "Zypher Terminal - Enhanced Experience"
        set_color normal
        set_color yellow
        printf "│ 📅 %-54s │\n" (date "+%A, %B %d, %Y at %I:%M %p")
        set_color normal
        set_color green
        set -l uptime_info (cat /proc/uptime | cut -d' ' -f1)
        set -l uptime_hours (math "floor($uptime_info / 3600)")
        set -l uptime_minutes (math "floor(($uptime_info % 3600) / 60)")
        printf "│ 💾 %-54s │\n" "Uptime: $uptime_hours hours, $uptime_minutes minutes"
        set_color normal
        set_color magenta
        set -l host_name (cat /etc/hostname 2>/dev/null || echo "Unknown")
        printf "│ 🖥️  %-54s │\n" "Host: $host_name"
        set_color normal
        set_color red
        printf "│ 👤 %-54s │\n" "User: $USER"
        set_color normal
        set_color blue
        printf "│ 🐚 %-54s │\n" "Shell: Fish "(fish --version | string match -r '\d+\.\d+\.\d+')
        set_color normal
        set_color cyan
        echo "╰────────────────────────────────────────────────────────────╯"
        set_color normal
        echo
        
        # Quick tips
        set_color --dim white
        echo "💡 Tips: Use 'sysinfo' for detailed system info, 'weather' for weather, 'netinfo' for network details"
        set_color normal
        echo
    end

    # ===== FINAL SETUP =====
    # Add local bin to PATH
    set -gx PATH $HOME/.local/bin $PATH
    
    # Initialize any additional tools
    if command -v zoxide >/dev/null
        zoxide init fish | source
    end
    
    if command -v thefuck >/dev/null
        thefuck --alias | source
    end
    
    echo "✨ Zypher Systems Fish Configuration Loaded!"
end
