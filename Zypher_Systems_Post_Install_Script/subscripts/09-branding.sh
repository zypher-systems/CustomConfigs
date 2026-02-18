#!/bin/bash
echo "🎨 [9/9] Applying ZypherOS Branding..."

# --- Variables ---
SOURCE_DIR="../images"
DEST_DIR="$HOME/.local/share/zypher/branding"
WALLPAPER="zypher_os_wallpaper.png"
ICON="zypher_os_launcher_icon.png"
ICON_PATH="$DEST_DIR/$ICON"

# --- 1. Setup Storage ---
echo "   Creating permanent asset storage..."
mkdir -p "$DEST_DIR"
cp "$SOURCE_DIR/$WALLPAPER" "$DEST_DIR/"
cp "$SOURCE_DIR/$ICON" "$DEST_DIR/"

# --- 2. Apply Wallpaper (This works fine live) ---
echo "   Setting Wallpaper..."
plasma-apply-wallpaperimage "$DEST_DIR/$WALLPAPER"

# --- 3. The "Ambush" Icon Fix ---
echo "   Scheduling Icon Injection for next boot..."

# We create a script in the Plasma 'env' folder. 
# Scripts here run BEFORE the desktop environment starts.
mkdir -p "$HOME/.config/plasma-workspace/env"
ENV_SCRIPT="$HOME/.config/plasma-workspace/env/zypher_icon_fix.sh"

cat > "$ENV_SCRIPT" <<EOF
#!/bin/bash
# ZypherOS Icon Injector
# This runs before Plasma starts to ensure the icon is set correctly.

CONFIG_FILE="\$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
ICON_PATH="$ICON_PATH"

# Only run if we haven't successfully set the icon yet
if ! grep -q "\$ICON_PATH" "\$CONFIG_FILE"; then
    
    # 1. Find the Launcher Section
    LAUNCHER_GROUP=\$(awk '/^\[/{last=\$0} /plugin=org.kde.plasma.kickoff|plugin=org.kde.plasma.kicker|plugin=org.kde.plasma.kickerdash/{print last; exit}' "\$CONFIG_FILE")

    if [ -n "\$LAUNCHER_GROUP" ]; then
        # 2. Parse the section header
        CLEAN_PATH=\$(echo "\$LAUNCHER_GROUP" | sed 's/^\[//;s/\]$//;s/\]\[/ /g')
        read -r -a GROUPS <<< "\$CLEAN_PATH"

        # 3. Patch the file (Safe because Plasma is not running yet!)
        kwriteconfig6 \\
            --file "\$CONFIG_FILE" \\
            --group "\${GROUPS[0]}" \\
            --group "\${GROUPS[1]}" \\
            --group "\${GROUPS[2]}" \\
            --group "\${GROUPS[3]}" \\
            --group "Configuration" \\
            --group "General" \\
            --key "icon" "\$ICON_PATH"
    fi
fi
EOF

# Make it executable
chmod +x "$ENV_SCRIPT"

echo "   ✅ Injection script installed."
echo "   ℹ️  NOTE: The Launcher Icon will update automatically on your NEXT REBOOT."
echo "✅ Branding Applied."