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

# --- 2. Apply Wallpaper ---
echo "   Setting Wallpaper..."
plasma-apply-wallpaperimage "$DEST_DIR/$WALLPAPER"

# --- 3. Apply Launcher Icon (Plasma 6 Property Fix) ---
echo "   Injecting Launcher Icon via DBus..."

# Create the Javascript payload
# FIX 1: Use desktops() and panels() instead of containments()
# FIX 2: Use 'c.applets' (property) instead of 'c.applets()' (function)
cat > /tmp/zypher_icon_update.js <<EOF
var allContainments = desktops().concat(panels());

for (var i = 0; i < allContainments.length; i++) {
    var c = allContainments[i];
    var widgets = c.applets; // <--- The Fix: No parentheses!
    
    for (var j = 0; j < widgets.length; j++) {
        var w = widgets[j];
        // Check for common launcher types (Kickoff, Kicker, etc.)
        if (w.type === "org.kde.plasma.kickoff" || w.type === "org.kde.plasma.kicker" || w.type === "org.kde.plasma.kickerdash") {
            w.currentConfigGroup = ["General"];
            w.writeConfig("icon", "$ICON_PATH");
            w.reloadConfig();
        }
    }
}
EOF

# Execute the script inside the running Plasma Shell
if command -v qdbus-qt6 &> /dev/null; then
    RUNNER="qdbus-qt6"
elif command -v qdbus6 &> /dev/null; then
    RUNNER="qdbus6"
else
    RUNNER="qdbus" 
fi

$RUNNER org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat /tmp/zypher_icon_update.js)"

# Cleanup
rm /tmp/zypher_icon_update.js

echo "   ✅ Icon configuration injected."
echo "✅ Branding Applied."