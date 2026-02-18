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

# --- 3. Apply Launcher Icon (Robust Method) ---
echo "   Setting Launcher Icon..."

# 🧠 The Fix: Use awk to track the [Section] header properly
# This ignores 'immutability=1' or other junk lines between the header and the plugin
LAUNCHER_GROUP=$(awk '/^\[/{last=$0} /plugin=org.kde.plasma.kickoff/{print last; exit}' "$CONFIG_FILE")

if [ -n "$LAUNCHER_GROUP" ]; then
    echo "   Found Launcher Group: $LAUNCHER_GROUP"

    # Convert "[Containments][1][Applets][5]" -> "Containments 1 Applets 5"
    # This allows us to feed it to kwriteconfig dynamically
    CLEAN_PATH=$(echo "$LAUNCHER_GROUP" | sed 's/^\[//;s/\]$//;s/\]\[/ /g')
    
    # Read into an array so we can access parts by index (0, 1, 2, 3)
    read -r -a GROUPS <<< "$CLEAN_PATH"
    
    # Write the icon config
    kwriteconfig6 \
        --file "$CONFIG_FILE" \
        --group "${GROUPS[0]}" \
        --group "${GROUPS[1]}" \
        --group "${GROUPS[2]}" \
        --group "${GROUPS[3]}" \
        --group "Configuration" \
        --group "General" \
        --key "icon" "$DEST_DIR/$ICON"
        
    echo "   ✅ Icon configuration written."
    
    # Restart Plasma safely to show changes
    kquitapp6 plasmashell || true
    kstart6 plasmashell &>/dev/null &
else
    echo "   ⚠️  Could not find Launcher widget in config. Icon not set."
fi

echo "✅ Branding Applied."