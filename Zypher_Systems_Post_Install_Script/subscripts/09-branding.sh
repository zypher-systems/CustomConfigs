#!/bin/bash
echo "🎨 [9/? ] Applying ZypherOS Branding..."

# --- Variables ---
# We are currently in /subscripts, so images are in ../images
SOURCE_DIR="../images"
DEST_DIR="$HOME/.local/share/zypher/branding"
CONFIG_FILE="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

WALLPAPER="zypher_os_wallpaper.png"
ICON="zypher_os_launcher_icon.png"

# --- 1. Setup Storage ---
echo "   Creating permanent asset storage..."
mkdir -p "$DEST_DIR"

# Copy the images from the repo to the local user folder
cp "$SOURCE_DIR/$WALLPAPER" "$DEST_DIR/"
cp "$SOURCE_DIR/$ICON" "$DEST_DIR/"

# --- 2. Apply Wallpaper ---
echo "   Setting Wallpaper..."
# This command talks to the running Plasma session to change the wallpaper instantly
plasma-apply-wallpaperimage "$DEST_DIR/$WALLPAPER"

# --- 3. Apply Launcher Icon (The Tricky Part) ---
echo "   Setting Launcher Icon..."

# We need to find the Applet ID for the launcher (usually 'org.kde.plasma.kickoff')
# We look for the section that has the kickoff plugin, then grab the ID.
LAUNCHER_ID=$(grep -B 1 "plugin=org.kde.plasma.kickoff" "$CONFIG_FILE" | head -n 1 | sed 's/^\[//;s/\]$//')

if [ -n "$LAUNCHER_ID" ]; then
    echo "   Found Launcher at ID: $LAUNCHER_ID"
    
    # We use kwriteconfig6 to safely write the icon path to that specific ID
    # Structure: [Containments][*][Applets][ID][Configuration][General] -> icon=...
    
    # Extract the group hierarchy from the ID string we found (e.g., Containments][1][Applets][5)
    # Note: kwriteconfig expects groups separated by spaces or flags. 
    # Since the ID string is complex, we will use kwriteconfig's ability to parse the group.
    
    # Actually, simpler: Use the ID we found to construct the group path.
    # The ID line in the file looks like: [Containments][1][Applets][5]
    
    # Let's break it down for kwriteconfig6
    CONTAINMENT=$(echo "$LAUNCHER_ID" | awk -F'][' '{print $2}')
    APPLET=$(echo "$LAUNCHER_ID" | awk -F'][' '{print $4}')
    
    kwriteconfig6 \
        --file "$CONFIG_FILE" \
        --group "Containments" \
        --group "$CONTAINMENT" \
        --group "Applets" \
        --group "$APPLET" \
        --group "Configuration" \
        --group "General" \
        --key "icon" "$DEST_DIR/$ICON"
        
    echo "   ✅ Icon configuration written."
    
    # Restart Plasma Shell to apply the icon change
    # (We run this in background so it doesn't block the script)
    kquitapp6 plasmashell || true
    kstart6 plasmashell &>/dev/null &
else
    echo "   ⚠️  Could not find Launcher widget in config. Icon not set."
fi

echo "   ✅ Branding Applied."