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

# --- 3. Apply Launcher Icon (Bulletproof Method) ---
echo "   Injecting Launcher Icon via DBus..."

# This JS script tries .applets, .widgets, AND .appletIds to ensure it works
cat > /tmp/zypher_icon_update.js <<EOF
// Helper function to apply the icon
function applyIcon(w) {
    if (!w) return;
    if (w.type === "org.kde.plasma.kickoff" || w.type === "org.kde.plasma.kicker" || w.type === "org.kde.plasma.kickerdash") {
        w.currentConfigGroup = ["General"];
        w.writeConfig("icon", "$ICON_PATH");
        w.reloadConfig();
    }
}

// Get all desktops and panels
var all = desktops().concat(panels());

for (var i = 0; i < all.length; i++) {
    var c = all[i];
    
    // Strategy 1: Try '.applets' (Standard)
    var widgets = c.applets;
    
    // Strategy 2: Try '.widgets' (Alternative name)
    if (!widgets) widgets = c.widgets;
    
    if (widgets) {
        // If we found a list of objects, iterate them
        for (var j = 0; j < widgets.length; j++) {
            applyIcon(widgets[j]);
        }
    } else if (c.appletIds) {
        // Strategy 3: Try '.appletIds' and look them up manually
        var ids = c.appletIds;
        for (var k = 0; k < ids.length; k++) {
            var w = c.appletById(ids[k]);
            applyIcon(w);
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