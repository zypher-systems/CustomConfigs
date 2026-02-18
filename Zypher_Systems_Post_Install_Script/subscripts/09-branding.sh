#!/bin/bash
echo "🎨 [9/9] Applying ZypherOS Branding..."

# --- Variables ---
SOURCE_DIR="../images"
DEST_DIR="$HOME/.local/share/zypher/branding"
CONFIG_FILE="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
WALLPAPER="zypher_os_wallpaper.png"
ICON="zypher_os_launcher_icon.png"

# --- 1. Setup Storage ---
echo "   Creating permanent asset storage..."
mkdir -p "$DEST_DIR"
cp "$SOURCE_DIR/$WALLPAPER" "$DEST_DIR/"
cp "$SOURCE_DIR/$ICON" "$DEST_DIR/"

# --- 2. Apply Wallpaper ---
echo "   Setting Wallpaper..."
plasma-apply-wallpaperimage "$DEST_DIR/$WALLPAPER"

# --- 3. Force Icon Config (The Sysadmin Method) ---
echo "   Locating Launcher in Config File..."

# Use the robust AWK search to find the correct Section Header
# This ignores junk lines like 'immutability=1' and grabs the real [Header]
LAUNCHER_GROUP=$(awk '/^\[/{last=$0} /plugin=org.kde.plasma.kickoff|plugin=org.kde.plasma.kicker|plugin=org.kde.plasma.kickerdash/{print last; exit}' "$CONFIG_FILE")

if [ -n "$LAUNCHER_GROUP" ]; then
    echo "   Targeting: $LAUNCHER_GROUP"

    # Clean the header: [Containments][1][Applets][5] -> Containments 1 Applets 5
    CLEAN_PATH=$(echo "$LAUNCHER_GROUP" | sed 's/^\[//;s/\]$//;s/\]\[/ /g')
    read -r -a GROUPS <<< "$CLEAN_PATH"

    # Force write the icon path to disk
    kwriteconfig6 \
        --file "$CONFIG_FILE" \
        --group "${GROUPS[0]}" \
        --group "${GROUPS[1]}" \
        --group "${GROUPS[2]}" \
        --group "${GROUPS[3]}" \
        --group "Configuration" \
        --group "General" \
        --key "icon" "$DEST_DIR/$ICON"

    echo "   ✅ Config file patched."
    
    # --- 4. Reload Desktop (The Safe Way) ---
    echo "   Restarting Plasma Shell..."
    
    # Method A: Systemd (Preferred on Arch)
    if systemctl --user list-units | grep -q "plasma-plasmashell.service"; then
        systemctl --user restart plasma-plasmashell
    else
        # Method B: Fallback for non-systemd setups
        kquitapp6 plasmashell || true
        nohup kstart6 plasmashell > /dev/null 2>&1 &
    fi
    
else
    echo "   ⚠️  CRITICAL: Could not find any Launcher widget in config."
    echo "      (Make sure you are logged into a full Plasma session)"
fi

echo "✅ Branding Applied."