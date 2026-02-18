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

# --- 2. Apply Wallpaper (Requires Running Plasma) ---
echo "   Setting Wallpaper..."
# We do this BEFORE killing Plasma, because this tool talks to the running desktop
plasma-apply-wallpaperimage "$DEST_DIR/$WALLPAPER"

# --- 3. The "Nuclear" Icon Swap ---
echo "   Applying Icon (Restarting Plasma)..."

# Step A: Kill Plasma gracefully to force it to save its current state
kquitapp6 plasmashell || true

# Step B: Wait for it to actually die (prevents overwrite race condition)
echo "   Waiting for Plasma to shutdown..."
while pgrep -u "$USER" -x plasmashell > /dev/null; do
    sleep 1
done

# Step C: Patch the Config File (Now safe to edit)
# Find the Launchers Group ID using the robust awk method
LAUNCHER_GROUP=$(awk '/^\[/{last=$0} /plugin=org.kde.plasma.kickoff/{print last; exit}' "$CONFIG_FILE")

if [ -n "$LAUNCHER_GROUP" ]; then
    echo "   Found Launcher Group: $LAUNCHER_GROUP"
    
    # Parse the group structure
    CLEAN_PATH=$(echo "$LAUNCHER_GROUP" | sed 's/^\[//;s/\]$//;s/\]\[/ /g')
    read -r -a GROUPS <<< "$CLEAN_PATH"
    
    # Write the icon path directly to the file
    kwriteconfig6 \
        --file "$CONFIG_FILE" \
        --group "${GROUPS[0]}" \
        --group "${GROUPS[1]}" \
        --group "${GROUPS[2]}" \
        --group "${GROUPS[3]}" \
        --group "Configuration" \
        --group "General" \
        --key "icon" "$DEST_DIR/$ICON"
        
    echo "   ✅ Icon configuration patched."
else
    echo "   ⚠️  Could not find Launcher widget. Icon not set."
fi

# Step D: Resurrect Plasma (Bulletproof Method)
echo "   Restarting Desktop..."

# 'nohup' prevents the desktop from closing when this script ends
# '>/dev/null 2>&1' silences all the debug text output
nohup kstart6 plasmashell > /dev/null 2>&1 &

echo "✅ Branding Applied."